import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'vector_map_tiles Example',
      theme: ThemeData.light(),
      home: const MyHomePage(title: 'Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MapController _controller = MapController();
  Style? _style;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _initStyle();
  }

  void _initStyle() async {
    try {
      _style = await _readStyle();
    } catch (e, stack) {
      // ignore: avoid_print
      print(e);
      // ignore: avoid_print
      print(stack);
      _error = e;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (_error != null) {
      children.add(Expanded(child: Text(_error!.toString())));
    } else if (_style == null) {
      children.add(const Center(child: CircularProgressIndicator()));
    } else {
      children.add(Flexible(child: _map(_style!)));
      children.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_statusText()]));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children),
      ),
    );
  }

  Future<Style> _readStyle() => StyleReader(
        uri: 'http://192.168.29.221:8080/styles/basic-preview/style.json',
      ).read();

  Widget _map(Style style) => FlutterMap(
        mapController: _controller,
        options: MapOptions(
            center: const LatLng(13.11869, 77.61308),
            zoom: 10,
            maxZoom: 22,
            interactiveFlags: InteractiveFlag.all),
        children: [
          VectorTileLayer(
            tileProviders: style.providers,
            theme: style.theme,
            sprites: style.sprites,
            maximumZoom: 22,
            tileOffset: TileOffset.mapbox,
            layerMode: VectorTileLayerMode.vector,
          ),
          CurrentLocationLayer(
            followOnLocationUpdate: FollowOnLocationUpdate.once,
            turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
            style: const LocationMarkerStyle(
              marker: DefaultLocationMarker(
                child: Icon(
                  Icons.navigation,
                  color: Colors.white,
                ),
              ),
              markerSize: Size(40, 40),
              markerDirection: MarkerDirection.heading,
            ),
          ),
        ],
      );

  Widget _statusText() => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: StreamBuilder(
          stream: _controller.mapEventStream,
          builder: (context, snapshot) {
            return Text(
                'Zoom: ${_controller.zoom.toStringAsFixed(2)} Center: ${_controller.center.latitude.toStringAsFixed(4)},${_controller.center.longitude.toStringAsFixed(4)}');
          },
        ),
      );
}
