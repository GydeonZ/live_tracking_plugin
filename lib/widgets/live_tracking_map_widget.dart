import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/location_point.dart';
import '../models/tracking_session.dart';

/// Widget untuk menampilkan tracking pada OpenStreetMap
class LiveTrackingMapWidget extends StatefulWidget {
  /// Session yang akan ditampilkan
  final TrackingSession session;

  /// List of location points
  final List<LocationPoint> points;

  /// Current location jika sedang tracking
  final LocationPoint? currentLocation;

  /// Callback ketika map dibuat
  final Function(MapController)? onMapCreated;

  /// Custom polyline color
  final Color polylineColor;

  /// Color untuk start marker
  final Color startMarkerColor;

  /// Color untuk end marker
  final Color endMarkerColor;

  /// Color untuk current marker
  final Color currentMarkerColor;

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
    this.startMarkerColor = Colors.green,
    this.endMarkerColor = Colors.red,
    this.currentMarkerColor = Colors.blue,
    this.showPolyline = true,
    this.showMarkers = true,
    this.initialZoom = 15.0,
  }) : super(key: key);

  @override
  State<LiveTrackingMapWidget> createState() => _LiveTrackingMapWidgetState();
}

class _LiveTrackingMapWidgetState extends State<LiveTrackingMapWidget> {
  late MapController mapController;
  late List<Polyline> polylines;
  late List<Marker> markers;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _initializeMapElements();
  }

  void _initializeMapElements() {
    polylines = [];
    markers = [];

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

    polylines.add(Polyline(points: polylinePoints, color: widget.polylineColor, strokeWidth: 4.0, isDotted: false));
  }

  /// Create markers untuk start, end, dan current location
  void _createMarkers() {
    // Start marker
    if (widget.points.isNotEmpty) {
      final startPoint = widget.points.first;
      markers.add(
        Marker(
          point: LatLng(startPoint.latitude, startPoint.longitude),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showMarkerInfo('Start Point', 'Started at ${startPoint.timestamp.toString().split('.')[0]}'),
            child: Container(
              decoration: BoxDecoration(
                color: widget.startMarkerColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
            ),
          ),
        ),
      );

      // End marker
      final endPoint = widget.points.last;
      markers.add(
        Marker(
          point: LatLng(endPoint.latitude, endPoint.longitude),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showMarkerInfo('End Point', 'Ended at ${endPoint.timestamp.toString().split('.')[0]}'),
            child: Container(
              decoration: BoxDecoration(
                color: widget.endMarkerColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(Icons.stop_circle, color: Colors.white, size: 20),
            ),
          ),
        ),
      );
    }

    // Current location marker
    if (widget.currentLocation != null) {
      markers.add(
        Marker(
          point: LatLng(widget.currentLocation!.latitude, widget.currentLocation!.longitude),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showMarkerInfo(
              'Current Location',
              'Accuracy: ${widget.currentLocation!.accuracy.toStringAsFixed(1)}m',
            ),
            child: Container(
              decoration: BoxDecoration(
                color: widget.currentMarkerColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(Icons.my_location, color: Colors.white, size: 20),
            ),
          ),
        ),
      );
    }
  }

  void _showMarkerInfo(String title, String description) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(description),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Calculate bounds untuk zoom ke semua points
  LatLngBounds _getBounds(List<LocationPoint> points) {
    if (points.isEmpty) {
      return LatLngBounds(const LatLng(0, 0), const LatLng(0, 0));
    }

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

    return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Zoom to fit all points setelah first frame
      if (widget.points.length > 1) {
        final bounds = _getBounds(widget.points);
        mapController.fitBounds(bounds, options: const FitBoundsOptions(padding: EdgeInsets.all(100)));
      }
      widget.onMapCreated?.call(mapController);
    });

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(initialLocation.latitude, initialLocation.longitude),
        initialZoom: widget.initialZoom,
        minZoom: 5.0,
        maxZoom: 19.0,
      ),
      children: [
        // OpenStreetMap tiles
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'live_tracking_plugin',
          // attribution: 'OpenStreetMap contributors',
        ),
        // Polylines
        if (widget.showPolyline) PolylineLayer(polylines: polylines),
        // Markers
        if (widget.showMarkers) MarkerLayer(markers: markers),
      ],
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

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
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
