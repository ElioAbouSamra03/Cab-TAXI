import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geo;

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(33.8938, 35.5018), // Beirut
    zoom: 14,
  );

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();

  String _routeInfo = 'N/A';
  String _estimatedTime = 'N/A';
  String _estimatedFare = 'N/A';
  String _selectedVehicle = 'Economy';

  final Set<Polyline> _polylines = {};
  bool _showInputCard = true;

  bool get _isDarkMode =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;

  Future<LatLng?> _geocodeAddress(String address) async {
    try {
      List<geo.Location> locations = await geo.locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        return LatLng(loc.latitude, loc.longitude);
      }
    } catch (e) {
      _showError('Geocoding failed: $e');
    }
    return null;
  }

  Future<void> _calculateFare() async {
    final pickupText = _pickupController.text.trim();
    final dropText = _dropoffController.text.trim();

    if (pickupText.isEmpty || dropText.isEmpty) {
      _showError('Please enter both pickup and drop-off');
      return;
    }

    final p = await _geocodeAddress(pickupText);
    final d = await _geocodeAddress(dropText);

    if (p == null || d == null) {
      _showError('Could not find one or both locations');
      return;
    }

    await _drawRoadPolyline(p, d);
    _moveCameraToBounds(p, d);

    final distance = _calculateDistance(p.latitude, p.longitude, d.latitude, d.longitude);

    // Fare based on vehicle type
    const baseFares = {
      'Economy': 100000,
      'Premium': 150000,
      'XL': 200000,
    };
    const perKmRates = {
      'Economy': 50000,
      'Premium': 75000,
      'XL': 90000,
    };

    final baseFare = baseFares[_selectedVehicle]!;
    final perKmFare = perKmRates[_selectedVehicle]!;
    var fare = baseFare + (distance * perKmFare).round();
    fare = (fare / 250).round() * 250;

    final estimatedTime = '${(distance / 30 * 60).round()} mins';

    setState(() {
      _routeInfo = '$pickupText → $dropText';
      _estimatedTime = estimatedTime;
      _estimatedFare = '$fare LBP';
    });
  }

  Future<void> _drawRoadPolyline(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=polyline',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final geometry = data['routes'][0]['geometry'];
      final points = _decodePolyline(geometry);

      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            width: 6,
            color: Colors.green,
          ),
        );
      });
    } else {
      _showError('Failed to load route from OSRM');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth radius in km
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) => deg * pi / 180;

  void _moveCameraToBounds(LatLng p1, LatLng p2) {
    final bounds = LatLngBounds(
      northeast: LatLng(max(p1.latitude, p2.latitude), max(p1.longitude, p2.longitude)),
      southwest: LatLng(min(p1.latitude, p2.latitude), min(p1.longitude, p2.longitude)),
    );
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isDarkMode ? Colors.black : Colors.white;
    final boxColor = _isDarkMode ? Colors.grey.shade900 : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            polylines: _polylines,
          ),

          // Edit Button (always visible)
          Positioned(
            top: 20,
            left: 20,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _showInputCard = true),
              icon: const Icon(Icons.edit_location_alt, color: Colors.white),
              label: const Text('Edit Route'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Input Card
          if (_showInputCard)
            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: boxColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _pickupController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Pickup Location',
                            prefixIcon: Icon(Icons.my_location, color: Colors.black),
                            hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                            filled: true,
                            fillColor: _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _dropoffController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Drop-off Location',
                            prefixIcon: Icon(Icons.flag, color: Colors.black),
                            hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                            filled: true,
                            fillColor: _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedVehicle,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          dropdownColor: _isDarkMode ? Colors.grey.shade900 : Colors.white,
                          style: TextStyle(color: textColor),
                          items: ['Economy', 'Premium', 'XL']
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _selectedVehicle = value!),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _calculateFare,
                                icon: const Icon(Icons.calculate),
                                label: const Text('Calculate Fare'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () => setState(() => _showInputCard = false),
                              icon: Icon(Icons.close, color: Colors.redAccent),
                              tooltip: 'Hide Input',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Fare Summary Bottom Card
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Card(
              color: backgroundColor,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Estimated Fare',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Route: $_routeInfo'),
                    const SizedBox(height: 4),
                    Text('Estimated Time: $_estimatedTime'),
                    const SizedBox(height: 4),
                    Text('Estimated Fare: $_estimatedFare'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.local_taxi),
                      label: const Text('Book Ride'),
                      onPressed: () => _showError('Ride booked!'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
