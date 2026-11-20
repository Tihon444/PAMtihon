# Laborator 4 — HealthCare: Flutter + server REST propriu

Designul și funcționalitățile lab3 sunt păstrate: filtre orizontale, căutare,
sortare, carduri și profiluri, favorite. Datele sunt cerute de la serverul propriu.

## Pornire pe calculator și telefon USB

În primul terminal, din rădăcina proiectului:

```powershell
python server/server.py
```

În al doilea terminal:

```powershell
D:/Android/Sdk/platform-tools/adb.exe -s RZ8N21QT2EY reverse tcp:8080 tcp:8080
D:/flutter/bin/flutter.bat run -d RZ8N21QT2EY
```

Alternativ: `./server/start-server.ps1` și `./server/run-phone.ps1`.
Serverul trebuie să rămână pornit. După reconectarea USB, repetă `adb reverse`.
Pentru emulator Android folosește:
`flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1`.
Adresa implicită este `http://127.0.0.1:8080/api/v1`.
HTTP local este permis numai în manifestul Android debug. Un server remote pentru
release trebuie să folosească HTTPS și o adresă transmisă prin API_BASE_URL.

## Serverul creat

`server/server.py` folosește Python 3 și biblioteca standard: http.server pentru
HTTP, json pentru serializare și sqlite3 pentru persistența programărilor.
Nu necesită pip install. Este un server local pentru demonstrarea laboratorului.

Datele inițiale sunt în `server/data`: medicii sunt preluați din datele lab3,
iar structura feed/detalii pornește de la API-ul oferit în enunț. Nu am creat
serverul extern de pe Render; am creat acest server local separat.
Flutter nu citește aceste fișiere: doar serverul le citește și răspunde prin HTTP.
Programările se păstrează în `server/appointments.sqlite3`, ignorat de Git.

| Metodă | Rută | Rezultat |
| --- | --- | --- |
| GET | /health | Starea serverului |
| GET | /api/v1/feed | Antet și lista celor 4 medici |
| GET | /api/v1/feed/details | Detalii pentru primul medic |
| GET | /api/v1/doctors/doctor-002/details | Detalii pentru medicul selectat |
| GET | /api/v1/appointments | Programările salvate |
| POST | /api/v1/appointments | Creează și persistă o programare, status 201 |
| GET | /api/v1/appointments/{id} | Citește o programare |
| PUT | /api/v1/appointments/{id} | Modifică medicul/data/ora |
| DELETE | /api/v1/appointments/{id} | Șterge programarea, status 204 |

POST și PUT primesc JSON:

```json
{"doctorId":"doctor-001","dateId":"sun-4","hourId":"11am"}
```

Răspunsul conține id, doctorId, dateId, hourId, status și createdAt.
Serverul validează medicul și intervalele. Răspunde cu 400 pentru date invalide,
404 pentru resurse inexistente, 409 pentru interval deja rezervat și 415 pentru
Content-Type greșit. SQLite are o constrângere unică pentru medic + dată + oră.

## Clean Architecture și fluxul datelor

- Domain: entități, MedicalRepository și cazurile GetMedicalFeed, GetAppointmentDetails, BookAppointment.
- Data: MedicalApi, DTO-uri JSON și ApiMedicalRepository.
- Presentation: ecranele lab3, DoctorsCubit și LoadController; încărcare/eroare/succes, reîncercare și salvare asincronă.
- main.dart: compunerea dependențelor și tema originală.

Citire: HomeScreen → DoctorsCubit → GetMedicalFeed → MedicalRepository →
MedicalApi GET → server Python → JSON → FeedDto → entități → Cubit → interfață.

Scriere: ecranul programării → BookAppointment → repository → BookingRequestDto.toJson
→ jsonEncode → HTTP POST → server validează JSON → INSERT SQLite → răspuns 201 cu id
→ repository deserializă id-ul → interfața confirmă salvarea.
Butonul este dezactivat pe durata cererii și după succes. Un conflict afișează
mesajul serverului. Aplicația utilizează GET și POST; PUT și DELETE sunt disponibile
pe server pentru demonstrare din PowerShell/Postman, fără a adăuga butoane în designul lab3.

## Demonstrație pentru prezentare

1. Arată `server/server.py`: make_server pornește ThreadingHTTPServer pe portul 8080.
2. Arată Handler.dispatch: metoda HTTP și ruta aleg operația.
3. Deschide http://127.0.0.1:8080/api/v1/feed în browser pentru JSON.
4. În aplicație deschide un medic, apasă „Programează o consultație”, alege data/ora și salvează.
5. Deschide http://127.0.0.1:8080/api/v1/appointments: apare programarea cu id.
6. Repornește serverul: programarea rămâne în SQLite.
7. Explică separarea Presentation/Domain/Data folosind fluxul de mai sus.

Exemplu PowerShell pentru întregul CRUD (creează și șterge doar propria înregistrare demo):

```powershell
$apiUrl = 'http://127.0.0.1:8080/api/v1'
$payload = @{ doctorId='doctor-004'; dateId='mon-5'; hourId='10am' } | ConvertTo-Json
$booking = Invoke-RestMethod "$apiUrl/appointments" -Method Post -ContentType 'application/json' -Body $payload
Invoke-RestMethod "$apiUrl/appointments/$($booking.id)"
$updated = @{ doctorId='doctor-004'; dateId='mon-5'; hourId='12pm' } | ConvertTo-Json
Invoke-RestMethod "$apiUrl/appointments/$($booking.id)" -Method Put -ContentType 'application/json' -Body $updated
Invoke-RestMethod "$apiUrl/appointments/$($booking.id)" -Method Delete
```

## Verificări

```powershell
python -m unittest discover -s server -v
flutter analyze
flutter test
```

Testele serverului pornesc un server HTTP real pe port temporar și verifică GET,
CRUD, persistența după repornire, conflictele, JSON invalid și validarea datelor.
Testele Flutter verifică serializarea, HTTP, erorile, navigarea și comportamentele lab3.
