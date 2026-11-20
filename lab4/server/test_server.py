import json
import tempfile
import threading
import unittest
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import HTTPError
from server import make_server

class ApiTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.db = Path(self.temp.name) / 'test.sqlite3'
        self.start()

    def start(self):
        self.server = make_server(port=0, database=self.db)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.base = f'http://127.0.0.1:{self.server.server_port}/api/v1'

    def stop(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()

    def tearDown(self):
        self.stop()
        self.temp.cleanup()

    def request(self, path, method='GET', body=None):
        data = json.dumps(body).encode() if body is not None else None
        request = Request(self.base + path, data=data, method=method,
                          headers={'Content-Type': 'application/json'})
        try:
            response = urlopen(request, timeout=3)
        except HTTPError as error:
            response = error
        with response:
            content = response.read()
            return response.status, json.loads(content) if content else None

    def booking(self):
        return {'doctorId': 'doctor-001', 'dateId': 'sun-4', 'hourId': '11am'}

    def test_feed_and_individual_details(self):
        status, feed = self.request('/feed')
        self.assertEqual(status, 200)
        self.assertEqual(len(feed['nearbyDoctors']), 4)
        status, details = self.request('/doctors/doctor-002/details')
        self.assertEqual(status, 200)
        self.assertEqual(details['doctor']['name'], 'Dr. Sonja Litel')
        self.assertEqual(details['details']['description'], feed['nearbyDoctors'][1]['about'])

    def test_crud_and_persistence(self):
        status, created = self.request('/appointments', 'POST', self.booking())
        self.assertEqual(status, 201)
        path = '/appointments/' + created['id']
        self.stop()
        self.start()
        self.assertEqual(self.request(path)[1]['id'], created['id'])
        self.assertEqual(len(self.request('/appointments')[1]['appointments']), 1)
        updated = self.booking() | {'hourId': '12pm'}
        self.assertEqual(self.request(path, 'PUT', updated)[1]['hourId'], '12pm')
        self.assertEqual(self.request(path, 'DELETE')[0], 204)
        self.assertEqual(self.request(path)[0], 404)

    def test_duplicate_rejected(self):
        self.assertEqual(self.request('/appointments', 'POST', self.booking())[0], 201)
        self.assertEqual(self.request('/appointments', 'POST', self.booking())[0], 409)

    def test_validation_and_unknown_doctor(self):
        self.assertEqual(self.request('/appointments', 'POST', {})[0], 400)
        self.assertEqual(self.request('/appointments', 'POST', [1])[0], 400)
        self.assertEqual(self.request('/appointments', 'POST', self.booking() | {'hourId': 'bad'})[0], 400)
        self.assertEqual(self.request('/doctors/missing/details')[0], 404)
        self.assertEqual(self.request('/missing')[0], 404)

    def test_malformed_json(self):
        request = Request(self.base + '/appointments', data=b'{bad', method='POST',
                          headers={'Content-Type': 'application/json'})
        with self.assertRaises(HTTPError) as result:
            urlopen(request, timeout=3)
        self.assertEqual(result.exception.code, 400)
        result.exception.close()

if __name__ == '__main__':
    unittest.main()
