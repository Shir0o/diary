// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() async {
  final mockClient = MockClient((request) async {
    print('--- Request Method: ${request.method} ---');
    print('--- Request Headers ---');
    request.headers.forEach((key, val) => print('$key: $val'));
    print('--- Request Body ---');
    print(request.body);
    return http.Response(
      '{"id": "test-id"}',
      200,
      headers: {'content-type': 'application/json'},
    );
  });

  final driveApi = drive.DriveApi(mockClient);

  final bytes = utf8.encode('line 1\nline 2\n');
  final media = drive.Media(Stream.value(bytes), bytes.length);
  final driveFile = drive.File()
    ..name = 'diary.jsonl'
    ..mimeType = 'text/plain';

  await driveApi.files.create(driveFile, uploadMedia: media);
}
