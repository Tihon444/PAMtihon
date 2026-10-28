# Laborator 3 – HealthCare

Aplicație Flutter pentru găsirea medicilor, construită cu arhitectură modulară și **BLoC/Cubit**.

## Funcționalități

- date locale JSON încărcate asincron prin `rootBundle`;
- stări BLoC: Loading, Success, Empty și Error;
- căutare după nume sau specialitate;
- filtrare după serviciu medical;
- sortare după rating, nume sau distanță;
- adăugare/eliminare din favorite;
- pagină reutilizabilă de detalii și solicitare de programare;
- componente UI reutilizabile: `DoctorCard` și mesaje de stare.

## Organizare

- `lib/models` – modelul de date;
- `lib/data` – repository-ul care citește JSON-ul;
- `lib/cubit` – state management;
- `lib/screens` – ecrane;
- `lib/widgets` – componente reutilizabile;
- `assets/data/doctors.json` – datele aplicației.

## Rulare

```bash
flutter pub get
flutter run
```
