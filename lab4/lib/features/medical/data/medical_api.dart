import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/entities.dart';
import '../domain/medical_repository.dart';
import 'medical_dto.dart';

class MedicalApi {
  MedicalApi(
    this.client, {
    this.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8080/api/v1',
    ),
  });
  final http.Client client;
  final String baseUrl;
  Future<Json> get(String path) => _request(path);
  Future<Json> post(String path, Json body) => _request(path, body: body);
  Future<Json> _request(String path, {Json? body}) async {
    try {
      final uri = Uri.parse('$baseUrl/$path');
      final r =
          await (body == null
                  ? client.get(uri, headers: {'Accept': 'application/json'})
                  : client.post(
                      uri,
                      headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                      },
                      body: jsonEncode(body),
                    ))
              .timeout(const Duration(seconds: 60));
      if (r.statusCode < 200 || r.statusCode >= 300) {
        String? message;
        try {
          final error = jsonDecode(utf8.decode(r.bodyBytes));
          if (error is Json && error['message'] is String) {
            message = error['message'] as String;
          }
        } on FormatException {
          /* Non-JSON HTTP errors use the status below. */
        }
        throw MedicalFailure(
          message ?? 'Serverul a răspuns cu eroarea HTTP ${r.statusCode}.',
        );
      }
      final decoded = jsonDecode(utf8.decode(r.bodyBytes));
      if (decoded is! Json) throw const FormatException('Expected object');
      return decoded;
    } on TimeoutException {
      throw const MedicalFailure('Serverul răspunde prea lent. Reîncearcă.');
    } on HandshakeException {
      throw const MedicalFailure(
        'Certificatul HTTPS nu poate fi validat. Încearcă datele mobile sau '
        'o altă rețea Wi-Fi și verifică data telefonului.',
      );
    } on SocketException {
      throw const MedicalFailure(
        'Conexiunea a eșuat. Verifică accesul la internet.',
      );
    } on http.ClientException {
      throw const MedicalFailure(
        'Conexiunea a eșuat. Verifică accesul la internet.',
      );
    } on FormatException {
      throw const MedicalFailure('Serverul a trimis date JSON invalide.');
    }
  }
}

class ApiMedicalRepository implements MedicalRepository {
  ApiMedicalRepository(this.api);
  final MedicalApi api;
  Future<T> _decode<T>(Future<Json> request, T Function(Json) parse) async {
    final json = await request;
    try {
      return parse(json);
    } on TypeError {
      throw const MedicalFailure('Structura datelor primite nu este validă.');
    } on FormatException {
      throw const MedicalFailure('Datele primite nu pot fi interpretate.');
    }
  }

  @override
  Future<MedicalFeed> getFeed() =>
      _decode(api.get('feed'), (j) => FeedDto.fromJson(j).toEntity());
  @override
  Future<AppointmentDetails> getDetails({String? doctorId}) => _decode(
    api.get(
      doctorId == null
          ? 'feed/details'
          : 'doctors/${Uri.encodeComponent(doctorId)}/details',
    ),
    (j) => DetailsDto.fromJson(j).toEntity(),
  );

  @override
  Future<String> bookAppointment(BookingRequest request) => _decode(
    api.post('appointments', BookingRequestDto(request).toJson()),
    (json) => json['id'] as String,
  );
}
