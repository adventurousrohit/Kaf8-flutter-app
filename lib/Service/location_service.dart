import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LocationAccessStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  error,
}

class LocationFetchResult {
  final LocationAccessStatus status;
  final Position? position;

  const LocationFetchResult({required this.status, this.position});
}

class LocationService {
  static const _lastLatKey = 'lastKnownLatitude';
  static const _lastLngKey = 'lastKnownLongitude';

  /// ✅ Detailed fetch result used for permission-aware UX.
  static Future<LocationFetchResult> getCurrentPositionWithStatus() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return const LocationFetchResult(
          status: LocationAccessStatus.serviceDisabled,
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return const LocationFetchResult(status: LocationAccessStatus.denied);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return const LocationFetchResult(
          status: LocationAccessStatus.deniedForever,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await saveLastKnownPosition(position);
      return LocationFetchResult(
        status: LocationAccessStatus.granted,
        position: position,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return const LocationFetchResult(status: LocationAccessStatus.error);
    }
  }

  /// ✅ Check permissions and fetch current position
  static Future<Position?> getCurrentPosition() async {
    final result = await getCurrentPositionWithStatus();
    return result.position;
  }

  static Future<void> saveLastKnownPosition(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_lastLatKey, position.latitude);
      await prefs.setDouble(_lastLngKey, position.longitude);
    } catch (e) {
      debugPrint('Error saving last known position: $e');
    }
  }

  static Future<Position?> getLastKnownPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_lastLatKey);
      final lng = prefs.getDouble(_lastLngKey);
      if (lat == null || lng == null) return null;
      return Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    } catch (e) {
      debugPrint('Error loading last known position: $e');
      return null;
    }
  }

  /// ✅ Get Address from Lat/Lng
  static Future<String?> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Construct a readable address string
        String address = "${place.street}, ${place.locality}, ${place.country}";
        return address;
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
    return null;
  }

  /// ✅ Get Lat/Lng from Address (Manual Search)
  static Future<Position?> getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location loc = locations[0];
        return Position(
          latitude: loc.latitude,
          longitude: loc.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    } catch (e) {
      debugPrint('Error getting lat/lng from address: $e');
    }
    return null;
  }

  /// ✅ Get Suggestions from Address
  static Future<List<String>> getSuggestions(String query) async {
    if (query.length < 3) return [];
    try {
      List<Location> locations = await locationFromAddress(query);
      List<String> suggestions = [];

      // Get up to 5 suggestions
      int count = locations.length > 5 ? 5 : locations.length;
      for (int i = 0; i < count; i++) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          locations[i].latitude,
          locations[i].longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark p = placemarks[0];
          String addr =
              "${p.street ?? ''}, ${p.locality ?? ''}, ${p.country ?? ''}";
          if (!suggestions.contains(addr)) suggestions.add(addr);
        }
      }
      return suggestions;
    } catch (e) {
      debugPrint('Error getting suggestions: $e');
      return [];
    }
  }
}
