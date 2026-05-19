import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationService {
  Future<bool> isPermissionGranted();
  Future<bool> requestPermission();
  Future<String?> getCurrentLocationName();
  Future<List<String>> getAddressSuggestions(String query);
}

class GeolocatorLocationService implements LocationService {
  final HttpClient _httpClient;

  GeolocatorLocationService({HttpClient? httpClient})
      : _httpClient = httpClient ?? HttpClient();

  @override
  Future<bool> isPermissionGranted() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  @override
  Future<String?> getCurrentLocationName() async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      final hasPermission = await requestPermission();
      if (!hasPermission) {
        debugPrint('Location permission denied.');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      return await reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1',
      );
      final request = await _httpClient.getUrl(uri);
      request.headers.set('User-Agent', 'DiaryApp/1.0 (contact@example.com)');
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final displayName = data['display_name'] as String?;
        if (displayName != null) {
          final address = data['address'] as Map<String, dynamic>?;
          if (address != null) {
            final city = address['city'] ?? address['town'] ?? address['village'] ?? address['suburb'] ?? address['county'];
            final road = address['road'];
            if (road != null && city != null) {
              return '$road, $city';
            }
            final landmark = address['amenity'] ?? address['building'] ?? address['shop'] ?? address['tourism'] ?? address['historic'];
            if (landmark != null && city != null) {
              return '$landmark, $city';
            }
            if (city != null) {
              return city as String;
            }
          }
          // Fallback to split parts
          final parts = displayName.split(',');
          if (parts.length > 2) {
            return '${parts[0].trim()}, ${parts[1].trim()}';
          }
          return displayName.trim();
        }
      }
    } catch (e) {
      debugPrint('Error in reverse geocoding: $e');
    }
    // Fallback coordinates string
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  @override
  Future<List<String>> getAddressSuggestions(String query) async {
    if (query.trim().isEmpty) return const [];
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=5',
      );
      final request = await _httpClient.getUrl(uri);
      request.headers.set('User-Agent', 'DiaryApp/1.0 (contact@example.com)');
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final List<dynamic> data = jsonDecode(body);
        return data
            .map((item) {
              final displayName = item['display_name'] as String? ?? '';
              final parts = displayName.split(',');
              if (parts.length > 3) {
                // Shorten displayed name to city, region, country for better UX
                return parts.take(3).join(',').trim();
              }
              return displayName.trim();
            })
            .where((name) => name.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('Error getting address suggestions: $e');
    }
    return const [];
  }
}
