import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:diary/services/location_service.dart';

class MockHttpClient extends Mock implements HttpClient {}
class MockHttpClientRequest extends Mock implements HttpClientRequest {}
class MockHttpHeaders extends Mock implements HttpHeaders {}
class MockHttpClientResponse extends Mock implements HttpClientResponse {}

void main() {
  late MockHttpClient mockHttpClient;
  late MockHttpClientRequest mockRequest;
  late MockHttpHeaders mockHeaders;
  late MockHttpClientResponse mockResponse;
  late GeolocatorLocationService locationService;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockRequest = MockHttpClientRequest();
    mockHeaders = MockHttpHeaders();
    mockResponse = MockHttpClientResponse();
    locationService = GeolocatorLocationService(httpClient: mockHttpClient);

    when(() => mockRequest.headers).thenReturn(mockHeaders);
    when(() => mockRequest.close()).thenAnswer((_) async => mockResponse);
  });

  group('GeolocatorLocationService - reverseGeocode', () {
    test('returns formatted location string on success (road and city)', () async {
      final jsonResponse = jsonEncode({
        'display_name': '123 Main St, Seattle, WA, USA',
        'address': {
          'road': 'Main St',
          'city': 'Seattle',
        }
      });

      when(() => mockHttpClient.getUrl(any())).thenAnswer((_) async => mockRequest);
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.transform(utf8.decoder)).thenAnswer(
        (_) => Stream.value(jsonResponse),
      );

      final result = await locationService.reverseGeocode(47.6062, -122.3321);

      expect(result, 'Main St, Seattle');
    });

    test('returns landmark on success when road is missing', () async {
      final jsonResponse = jsonEncode({
        'display_name': 'Space Needle, Seattle, WA, USA',
        'address': {
          'tourism': 'Space Needle',
          'city': 'Seattle',
        }
      });

      when(() => mockHttpClient.getUrl(any())).thenAnswer((_) async => mockRequest);
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.transform(utf8.decoder)).thenAnswer(
        (_) => Stream.value(jsonResponse),
      );

      final result = await locationService.reverseGeocode(47.6205, -122.3493);

      expect(result, 'Space Needle, Seattle');
    });

    test('falls back to coordinates string on HTTP error', () async {
      when(() => mockHttpClient.getUrl(any())).thenAnswer((_) async => mockRequest);
      when(() => mockResponse.statusCode).thenReturn(500);

      final result = await locationService.reverseGeocode(47.6062, -122.3321);

      expect(result, '47.6062, -122.3321');
    });

    test('falls back to coordinates string on exception', () async {
      when(() => mockHttpClient.getUrl(any())).thenThrow(const SocketException('No Internet'));

      final result = await locationService.reverseGeocode(47.6062, -122.3321);

      expect(result, '47.6062, -122.3321');
    });
  });

  group('GeolocatorLocationService - getAddressSuggestions', () {
    test('returns list of suggestions on success', () async {
      final jsonResponse = jsonEncode([
        {'display_name': 'Seattle, WA, USA'},
        {'display_name': 'Portland, OR, USA'},
      ]);

      when(() => mockHttpClient.getUrl(any())).thenAnswer((_) async => mockRequest);
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.transform(utf8.decoder)).thenAnswer(
        (_) => Stream.value(jsonResponse),
      );

      final result = await locationService.getAddressSuggestions('Seattle');

      expect(result, ['Seattle, WA, USA', 'Portland, OR, USA']);
    });

    test('returns empty list on empty query', () async {
      final result = await locationService.getAddressSuggestions('');
      expect(result, isEmpty);
      verifyNever(() => mockHttpClient.getUrl(any()));
    });

    test('returns empty list on API error', () async {
      when(() => mockHttpClient.getUrl(any())).thenAnswer((_) async => mockRequest);
      when(() => mockResponse.statusCode).thenReturn(400);

      final result = await locationService.getAddressSuggestions('Seattle');

      expect(result, isEmpty);
    });
  });
}
