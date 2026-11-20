"""Local REST API for the Flutter laboratory. Python standard library only."""
import argparse
import json
import sqlite3
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit
from uuid import uuid4

ROOT = Path(__file__).resolve().parent
PREFIX = '/api/v1'


class ApiError(Exception):
    def __init__(self, status, message):
        self.status, self.message = status, message


class Store:
    def __init__(self, path):
        self.path = str(path)
        self.feed = json.loads((ROOT / 'data/feed.json').read_text(encoding='utf-8-sig'))
        self.template = json.loads((ROOT / 'data/details.json').read_text(encoding='utf-8-sig'))
        with self.connect() as db:
            db.execute('''CREATE TABLE IF NOT EXISTS appointments (
                id TEXT PRIMARY KEY, doctor_id TEXT NOT NULL, date_id TEXT NOT NULL,
                hour_id TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'confirmed',
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(doctor_id, date_id, hour_id))''')

    def connect(self):
        db = sqlite3.connect(self.path)
        db.row_factory = sqlite3.Row
        return db

    def doctor(self, doctor_id):
        for doctor in self.feed['nearbyDoctors']:
            if doctor['id'] == doctor_id:
                return doctor
        raise ApiError(404, 'Medicul nu există.')

    def details(self, doctor_id=None):
        result = json.loads(json.dumps(self.template))
        doctor = self.doctor(doctor_id or self.feed['nearbyDoctors'][0]['id'])
        result['doctor'] = doctor
        result['details']['description'] = doctor['about']
        return result

    def validate(self, body):
        if not isinstance(body, dict):
            raise ApiError(400, 'Corpul cererii trebuie să fie un obiect JSON.')
        for key in ('doctorId', 'dateId', 'hourId'):
            if not isinstance(body.get(key), str) or not body[key]:
                raise ApiError(400, f'Câmp obligatoriu: {key}.')
        details = self.details(body['doctorId'])
        if body['dateId'] not in [s['id'] for s in details['date']['slots']]:
            raise ApiError(400, 'Data selectată nu este validă.')
        if body['hourId'] not in [s['id'] for s in details['workingHours']['slots']]:
            raise ApiError(400, 'Ora selectată nu este validă.')

    @staticmethod
    def serialize(row):
        return dict(id=row['id'], doctorId=row['doctor_id'], dateId=row['date_id'],
                    hourId=row['hour_id'], status=row['status'], createdAt=row['created_at'])

    def list_appointments(self):
        with self.connect() as db:
            return [self.serialize(r) for r in db.execute('SELECT * FROM appointments ORDER BY created_at, id')]

    def get_appointment(self, appointment_id):
        with self.connect() as db:
            row = db.execute('SELECT * FROM appointments WHERE id=?', (appointment_id,)).fetchone()
        if row is None:
            raise ApiError(404, 'Programarea nu există.')
        return self.serialize(row)

    def save(self, body, appointment_id=None):
        self.validate(body)
        if appointment_id:
            self.get_appointment(appointment_id)
        identifier = appointment_id or str(uuid4())
        try:
            with self.connect() as db:
                if appointment_id:
                    db.execute('UPDATE appointments SET doctor_id=?, date_id=?, hour_id=? WHERE id=?',
                               (body['doctorId'], body['dateId'], body['hourId'], identifier))
                else:
                    db.execute('INSERT INTO appointments(id, doctor_id, date_id, hour_id) VALUES(?,?,?,?)',
                               (identifier, body['doctorId'], body['dateId'], body['hourId']))
        except sqlite3.IntegrityError:
            raise ApiError(409, 'Acest interval este deja rezervat pentru medicul selectat.')
        return self.get_appointment(identifier)

    def delete(self, appointment_id):
        with self.connect() as db:
            if db.execute('DELETE FROM appointments WHERE id=?', (appointment_id,)).rowcount == 0:
                raise ApiError(404, 'Programarea nu există.')


def make_server(host='127.0.0.1', port=8080, database=None):
    store = Store(database or ROOT / 'appointments.sqlite3')

    class Handler(BaseHTTPRequestHandler):
        def respond(self, status, data=None):
            content = json.dumps(data, ensure_ascii=False).encode('utf-8') if data is not None else b''
            self.send_response(status)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Content-Length', str(len(content)))
            self.end_headers()
            self.wfile.write(content)

        def body(self):
            try:
                size = int(self.headers.get('Content-Length', '0'))
                if not 0 < size <= 16384:
                    raise ApiError(400, 'Corpul JSON lipsește sau depășește limita de 16 KB.')
                if self.headers.get_content_type() != 'application/json':
                    raise ApiError(415, 'Folosește Content-Type: application/json.')
                return json.loads(self.rfile.read(size).decode('utf-8'))
            except (ValueError, UnicodeError):
                raise ApiError(400, 'JSON invalid.')

        def dispatch(self):
            path = urlsplit(self.path).path.rstrip('/')
            try:
                if self.command == 'GET' and path == '/health':
                    return self.respond(200, {'status': 'ok'})
                if not path.startswith(PREFIX + '/'):
                    raise ApiError(404, 'Ruta nu există.')
                route = path[len(PREFIX):]
                if self.command == 'GET':
                    if route == '/feed':
                        return self.respond(200, store.feed)
                    if route == '/feed/details':
                        return self.respond(200, store.details())
                    if route.startswith('/doctors/') and route.endswith('/details'):
                        return self.respond(200, store.details(route.split('/')[2]))
                    if route == '/appointments':
                        return self.respond(200, {'appointments': store.list_appointments()})
                    if route.startswith('/appointments/'):
                        return self.respond(200, store.get_appointment(route.split('/')[2]))
                if self.command == 'POST' and route == '/appointments':
                    return self.respond(201, store.save(self.body()))
                if route.startswith('/appointments/'):
                    identifier = route.split('/')[2]
                    if self.command == 'PUT':
                        return self.respond(200, store.save(self.body(), identifier))
                    if self.command == 'DELETE':
                        store.delete(identifier)
                        return self.respond(204)
                raise ApiError(404, 'Ruta sau metoda nu există.')
            except ApiError as error:
                self.respond(error.status, {'message': error.message})
            except Exception:
                import traceback
                traceback.print_exc()
                self.respond(500, {'message': 'Eroare internă de server.'})

        do_GET = do_POST = do_PUT = do_DELETE = dispatch

    return ThreadingHTTPServer((host, port), Handler)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--host', default='127.0.0.1')
    parser.add_argument('--port', type=int, default=8080)
    parser.add_argument('--db', type=Path)
    args = parser.parse_args()
    server = make_server(args.host, args.port, args.db)
    print(f'HealthCare API: http://{args.host}:{server.server_port}{PREFIX}', flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
