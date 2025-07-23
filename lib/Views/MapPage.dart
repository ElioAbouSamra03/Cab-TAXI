import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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

  final Set<Polyline> _polylines = {};
  final List<LatLng> _polylineCoordinates = [];

  final String _googleApiKey = 'AIzaSyDg5cETuPmoR49dv4K3l3_jxNcH2hlphrU'; // Replace with your API key

  Future<LatLng?> _geocodeAddress(String address) async {
    try {
      print('Geocoding: $address');
      List<geo.Location> locations = await geo.locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        return LatLng(loc.latitude, loc.longitude);
      }
    } catch (e) {
      print('Geocoding failed ($address): $e');
    }
    return null;
  }

  void _calculateFare() async {
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

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${p.latitude},${p.longitude}'
      '&destination=${d.latitude},${d.longitude}'
      '&mode=driving'
      '&key=$_googleApiKey',
    );

    print('Requesting directions from: $url');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      _showError('Directions API error: ${response.statusCode}');
      return;
    }

    final data = json.decode(response.body);
    final status = data['status'];
    if (status != 'OK') {
      _showError('Directions error: $status\n${data['error_message'] ?? ""}');
      return;
    }

    if (data['routes'] == null || data['routes'].isEmpty) {
      _showError('No route found');
      return;
    }

    final route = data['routes'][0];
    final leg = route['legs'][0];
    final distanceMeters = leg['distance']['value'] as num;
    final durationText = leg['duration']['text'] as String;
    final encodedPoly = route['overview_polyline']['points'] as String;

    _drawPolyline(encodedPoly);
    _moveCameraToBounds(route);

    final double distanceKm = distanceMeters / 1000;
    const int baseFare = 100000;
    const int perKmFare = 50000;
    var fare = baseFare + (distanceKm * perKmFare).round();
    fare = (fare / 250).round() * 250;

    setState(() {
      _routeInfo = '$pickupText → $dropText';
      _estimatedTime = durationText;
      _estimatedFare = '$fare LBP';
    });
  }

  void _drawPolyline(String encoded) {
    final List<PointLatLng> points = PolylinePoints.decodePolyline(encoded); // ✅ FIXED

    _polylineCoordinates.clear();
    for (var point in points) {
      _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    }

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: _polylineCoordinates,
          width: 5,
          color: Colors.deepPurple,
        ),
      );
    });
  }

  void _moveCameraToBounds(Map<String, dynamic> route) {
    final b = route['bounds'];
    final ne = b['northeast'];
    final sw = b['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(ne['lat'], ne['lng']),
      southwest: LatLng(sw['lat'], sw['lng']),
    );
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cab Map'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              polylines: _polylines,
            ),
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _pickupController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Pickup Location',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _dropoffController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Drop-off Location',
                          prefixIcon: Icon(Icons.flag),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        onPressed: _calculateFare,
                        child: const Text('Calculate Fare'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Estimated Fare',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
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
      ),
    );
  }
}
