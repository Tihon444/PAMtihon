import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab4/main.dart';
import 'package:lab4/features/medical/presentation/cubit/doctors_state.dart';
import 'package:lab4/features/medical/data/medical_api.dart';
import 'package:lab4/features/medical/data/medical_dto.dart';
import 'package:lab4/features/medical/domain/entities.dart';
import 'package:lab4/features/medical/domain/medical_repository.dart';
import 'package:lab4/features/medical/presentation/load_controller.dart';

String fixture(String name) =>
    File('test/fixtures/$name.json').readAsStringSync();
MedicalFeed feed() =>
    FeedDto.fromJson(jsonDecode(fixture('feed')) as Json).toEntity();
AppointmentDetails details() =>
    DetailsDto.fromJson(jsonDecode(fixture('details')) as Json).toEntity();

class FakeRepository implements MedicalRepository {
  Future<MedicalFeed> Function() loadFeed = () async => feed();
  int detailCalls = 0;
  @override
  Future<String> bookAppointment(BookingRequest request) async =>
      'test-booking';
  @override
  Future<MedicalFeed> getFeed() => loadFeed();
  @override
  Future<AppointmentDetails> getDetails({String? doctorId}) async {
    detailCalls++;
    return details();
  }
}

void main() {
  test('booking serializes JSON and returns the saved server identifier', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/appointments');
      expect(request.headers['Content-Type'], 'application/json');
      expect(jsonDecode(request.body), {'doctorId': 'doctor-001', 'dateId': 'sun-4', 'hourId': '11am'});
      return http.Response('{"id":"saved-booking"}', 201);
    });
    addTearDown(client.close);
    final repository = ApiMedicalRepository(MedicalApi(client));
    expect(await repository.bookAppointment(const BookingRequest(
      doctorId: 'doctor-001', dateId: 'sun-4', hourId: '11am')), 'saved-booking');
  });

  test('booking conflict displays the server validation message', () async {
    final client = MockClient((_) async => http.Response('{"message":"Interval rezervat"}', 409));
    addTearDown(client.close);
    await expectLater(ApiMedicalRepository(MedicalApi(client)).bookAppointment(
      const BookingRequest(doctorId: 'doctor-001', dateId: 'sun-4', hourId: '11am')),
      throwsA(isA<MedicalFailure>().having((e) => e.message, 'message', 'Interval rezervat')));
  });

  test('individual details uses the selected doctor endpoint', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/doctors/doctor-002/details');
      return http.Response(fixture('details'), 200);
    });
    addTearDown(client.close);
    await ApiMedicalRepository(MedicalApi(client)).getDetails(doctorId: 'doctor-002');
  });
  test('real API fixtures deserialize and serialize', () {
    final json = jsonDecode(fixture('feed')) as Json;
    final dto = FeedDto.fromJson(json);
    expect(jsonDecode(jsonEncode(dto.toJson())), json);
    expect(dto.toEntity().doctors.first.id, 'doctor-001');
    expect(dto.toEntity().services.length, 4);
    final detailDto = DetailsDto.fromJson(
      jsonDecode(fixture('details')) as Json,
    );
    expect(
      jsonDecode(jsonEncode(detailDto.toJson())),
      jsonDecode(fixture('details')),
    );
    expect(detailDto.toEntity().amount, 120.0);
    expect(detailDto.toEntity().hours[1].selected, isTrue);
  });
  test('repository requests both exact endpoints', () async {
    final paths = <String>[];
    final client = MockClient((request) async {
      paths.add(request.url.path);
      expect(request.headers['Accept'], 'application/json');
      return http.Response(
        fixture(request.url.path.endsWith('details') ? 'details' : 'feed'),
        200,
      );
    });
    addTearDown(client.close);
    final repository = ApiMedicalRepository(MedicalApi(client));
    expect((await repository.getFeed()).greeting, 'Hi, Jonathan');
    expect((await repository.getDetails()).doctor.name, 'Dr.Upul');
    expect(paths, ['/api/v1/feed', '/api/v1/feed/details']);
  });
  for (final body in ['not json', '[]', '{}']) {
    test('invalid payload $body becomes a domain failure', () async {
      final client = MockClient((_) async => http.Response(body, 200));
      addTearDown(client.close);
      final repository = ApiMedicalRepository(MedicalApi(client));
      await expectLater(repository.getFeed(), throwsA(isA<MedicalFailure>()));
    });
  }
  test('HTTP error becomes a domain failure', () async {
    final client = MockClient((_) async => http.Response('Unavailable', 503));
    addTearDown(client.close);
    await expectLater(
      ApiMedicalRepository(MedicalApi(client)).getDetails(),
      throwsA(
        isA<MedicalFailure>().having(
          (e) => e.message,
          'message',
          contains('503'),
        ),
      ),
    );
  });
  test('connection and timeout become domain failures', () async {
    for (final error in [
      http.ClientException('offline'),
      TimeoutException('slow'),
      const HandshakeException('self signed certificate in certificate chain'),
      const SocketException('Failed host lookup'),
    ]) {
      final client = MockClient((_) async => throw error);
      await expectLater(
        ApiMedicalRepository(MedicalApi(client)).getFeed(),
        throwsA(isA<MedicalFailure>()),
      );
      client.close();
    }
  });
  test('latest load wins and disposed controllers ignore responses', () async {
    final requests = <Completer<int>>[];
    final controller = LoadController<int>(() {
      final request = Completer<int>();
      requests.add(request);
      return request.future;
    });
    final first = controller.load();
    final second = controller.load();
    requests[1].complete(2);
    await second;
    requests[0].complete(1);
    await first;
    expect(controller.data, 2);
    final third = controller.load();
    controller.dispose();
    requests[2].complete(3);
    await third;
    expect(controller.data, 2);
  });
  testWidgets('loading, error and retry show API feed', (tester) async {
    final pending = Completer<MedicalFeed>();
    final repository = FakeRepository()..loadFeed = () => pending.future;
    await tester.pumpWidget(HealthCareApp(repository: repository));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.completeError(const MedicalFailure('Fără conexiune'));
    await tester.pumpAndSettle();
    expect(find.text('Fără conexiune'), findsOneWidget);
    repository.loadFeed = () async => feed();
    await tester.tap(find.text('Reîncearcă'));
    await tester.pumpAndSettle();
    expect(find.text('Hi, Jonathan'), findsOneWidget);
    expect(find.text('Flutter Demo Home Page'), findsNothing);
  });
  testWidgets('appointment navigates and fetches separate details', (
    tester,
  ) async {
    final repository = FakeRepository();
    await tester.pumpWidget(HealthCareApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dr. Emmly Lestiryno'));
    await tester.pumpAndSettle();
    expect(find.text('Detalii medic'), findsOneWidget);
    expect(find.text('Dr. Emmly Lestiryno'), findsOneWidget);
    expect(repository.detailCalls, 0);
    await tester.ensureVisible(find.text('Programează o consultație'));
    await tester.tap(find.text('Programează o consultație'));
    await tester.pumpAndSettle();
    expect(repository.detailCalls, 1);
    expect(find.text('Dr.Upul'), findsOneWidget);
    expect(find.text(r'$120.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('search has an empty state and refresh remains available', (
    tester,
  ) async {
    await tester.pumpWidget(HealthCareApp(repository: FakeRepository()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'unknown doctor');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Nu am găsit rezultate.'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Nu am găsit rezultate.'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });
  testWidgets('lab3 filters, sort menu and shared favorites are preserved', (
    tester,
  ) async {
    await tester.pumpWidget(HealthCareApp(repository: FakeRepository()));
    await tester.pumpAndSettle();
    expect(find.text('Appointment'), findsNothing);
    expect(find.text('Toate'), findsOneWidget);
    await tester.tap(find.text('Tooth'));
    await tester.pumpAndSettle();
    expect(find.text('1 medici disponibili'), findsOneWidget);
    expect(find.text('Dr. Sonja Litel'), findsOneWidget);
    expect(find.text('Dr. Emmly Lestiryno'), findsNothing);
    await tester.tap(find.byType(PopupMenuButton<SortOption>));
    await tester.pumpAndSettle();
    expect(find.text('Rating'), findsOneWidget);
    expect(find.text('Distanță'), findsOneWidget);
    await tester.tap(find.text('Nume'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dr. Sonja Litel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
