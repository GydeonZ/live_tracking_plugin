import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location_point.dart';
import '../models/tracking_session.dart';

/// Widget untuk menampilkan tracking pada Google Maps
class LiveTrackingMapWidget extends StatefulWidget {
  /// Session yang akan ditampilkan
  final TrackingSession session;

  /// List of location points
  final List<LocationPoint> points;

  /// Current location jika sedang tracking
  final LocationPoint? currentLocation;

  /// Callback ketika map dibuat
  final Function(GoogleMapController)? onMapCreated;

  /// Custom polyline color
  final Color polylineColor;

  /// Custom marker color untuk start
  final BitmapDescriptor? startMarkerIcon;

  /// Custom marker color untuk end
  final BitmapDescriptor? endMarkerIcon;

  /// Custom marker color untuk current
  final BitmapDescriptor? currentMarkerIcon;

  /// Show atau hide polyline
  final bool showPolyline;

  /// Show atau hide markers
  final bool showMarkers;

  /// Initial zoom level
  final double initialZoom;

  const LiveTrackingMapWidget({
    Key? key,
    required this.session,
    required this.points,
    this.currentLocation,
    this.onMapCreated,
    this.polylineColor = Colors.blue,
    this.startMarkerIcon,
    this.endMarkerIcon,
    this.currentMarkerIcon,
    this.showPolyline = true,
    this.showMarkers = true,
    this.initialZoom = 15.0,
  }) : super(key: key);

  @override
  State<LiveTrackingMapWidget> createState() => _LiveTrackingMapWidgetState();
}

class _LiveTrackingMapWidgetState extends State<LiveTrackingMapWidget> {
  late GoogleMapController mapController;
  late Set<Polyline> polylines;
  late Set<Marker> markers;

  @override
  void initState() {
    super.initState();
    _initializeMapElements();
  }

  void _initializeMapElements() {
    polylines = <Polyline>{};
    markers = <Marker>{};

    if (widget.showPolyline && widget.points.isNotEmpty) {
      _createPolylines();
    }

    if (widget.showMarkers && widget.points.isNotEmpty) {
      _createMarkers();
    }
  }

  /// Create polylines untuk tracking path
  void _createPolylines() {
    if (widget.points.isEmpty) return;

    final List<LatLng> polylinePoints = widget.points.map((p) => LatLng(p.latitude, p.longitude)).toList();

    polylines.add(
      Polyline(
        polylineId: PolylineId('tracking_path'),
        points: polylinePoints,
        color: widget.polylineColor,
        width: 5,
        geodesic: true,
      ),
    );
  }

  /// Create markers untuk start, end, dan current location
  void _createMarkers() async {
    // Start marker
    if (widget.points.isNotEmpty) {
      final startPoint = widget.points.first;
      markers.add(
        Marker(
          markerId: const MarkerId('start_marker'),
          position: LatLng(startPoint.latitude, startPoint.longitude),
          infoWindow: InfoWindow(
            title: 'Start Point',
            snippet: 'Started at ${startPoint.timestamp.toString().split('.')[0]}',
          ),
          icon: widget.startMarkerIcon ?? await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      // End marker
      final endPoint = widget.points.last;
      markers.add(
        Marker(
          markerId: const MarkerId('end_marker'),
          position: LatLng(endPoint.latitude, endPoint.longitude),
          infoWindow: InfoWindow(
            title: 'End Point',
            snippet: 'Ended at ${endPoint.timestamp.toString().split('.')[0]}',
          ),
          icon: widget.endMarkerIcon ?? await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    // Current location marker
    if (widget.currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_marker'),
          position: LatLng(widget.currentLocation!.latitude, widget.currentLocation!.longitude),
          infoWindow: InfoWindow(
            title: 'Current Location',
            snippet: 'Accuracy: ${widget.currentLocation!.accuracy.toStringAsFixed(1)}m',
          ),
          icon: widget.currentMarkerIcon ?? await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    setState(() {
      // Update markers
    });
  }

  /// Get bounds untuk zoom ke semua points
  LatLngBounds _getBounds(List<LocationPoint> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat > point.latitude ? point.latitude : minLat;
      maxLat = maxLat < point.latitude ? point.latitude : maxLat;
      minLng = minLng > point.longitude ? point.longitude : minLng;
      maxLng = maxLng < point.longitude ? point.longitude : maxLng;
    }

    return LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.location_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No tracking data available'),
          ],
        ),
      );
    }

    final initialLocation = widget.currentLocation ?? widget.points.last;

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(initialLocation.latitude, initialLocation.longitude),
        zoom: widget.initialZoom,
      ),
      onMapCreated: (controller) {
        mapController = controller;

        // Zoom to fit all points
        if (widget.points.length > 1) {
          final bounds = _getBounds(widget.points);
          mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
        }

        widget.onMapCreated?.call(controller);
      },
      polylines: polylines,
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      mapToolbarEnabled: true,
    );
  }

  @override
  void didUpdateWidget(LiveTrackingMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Rebuild polylines and markers jika points berubah
    if (oldWidget.points != widget.points || oldWidget.currentLocation != widget.currentLocation) {
      _initializeMapElements();
      setState(() {});
    }
  }
}

/// Widget untuk menampilkan tracking statistics
class TrackingStatsWidget extends StatelessWidget {
  final TrackingSession session;
  final LocationPoint? currentLocation;

  const TrackingStatsWidget({Key? key, required this.session, this.currentLocation}) : super(key: key);

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours h ${minutes.toString().padLeft(2, '0')} m';
    } else if (minutes > 0) {
      return '$minutes m ${seconds.toString().padLeft(2, '0')} s';
    } else {
      return '${seconds.toString().padLeft(2, '0')} s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = session.getDuration();
    final distance = session.distanceMeters ?? 0.0;
    final avgSpeed = session.averageSpeed ?? 0.0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(session.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (session.description != null) ...[
              const SizedBox(height: 8),
              Text(session.description!, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
            const SizedBox(height: 16),
            _StatRow(label: 'Duration', value: _formatDuration(duration), icon: Icons.schedule),
            _StatRow(label: 'Distance', value: '${(distance / 1000).toStringAsFixed(2)} km', icon: Icons.straighten),
            _StatRow(label: 'Average Speed', value: '${(avgSpeed * 3.6).toStringAsFixed(1)} km/h', icon: Icons.speed),
            _StatRow(label: 'Points Recorded', value: session.pointCount.toString(), icon: Icons.pin_drop),
            if (currentLocation != null) ...[
              const SizedBox(height: 8),
              _StatRow(
                label: 'Current Accuracy',
                value: '${currentLocation!.accuracy.toStringAsFixed(1)} m',
                icon: Icons.my_location,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
