import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapHomePageWidget extends StatefulWidget {
  const MapHomePageWidget({Key? key}) : super(key: key);

  @override
  _MapHomePageWidgetState createState() => _MapHomePageWidgetState();
}

class _MapHomePageWidgetState extends State<MapHomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late GoogleMapController mapController;
  late LatLng googleMapsCenter;
  late Marker marker;
  late LocationData _currentPosition;
  final Completer<GoogleMapController> _cntr = Completer();
  Set<Marker> _markers = {};
  Location location = Location();
  LatLng _initialcameraposition = LatLng(45.760696, 21.226788);
  String mapTheme = '';

  @override
  void initState(){
    super.initState();
    FirebaseFirestore.instance.collection('markers').snapshots().listen((snapshot) async {
      // Clear the current markers.
      setState(() {
        _markers.clear();
      });

      // Add a new marker for each document in the collection.
      for (var doc in snapshot.docs) {
        Marker newMarker = Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(doc['lat'], doc['lng']),
          icon: BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/custom_marker_blue.png', 48)),
        );
        setState(() {
          _markers.add(newMarker);
        });
      }
    });
    getLoc();
    DefaultAssetBundle.of(context).loadString('assets/maptheme/silver.json').then((string) {
      mapTheme = string;
      print(mapTheme);
    }).catchError((error) {
      print('here');
      log(error.toString());
    });

  }

  void _onMapCreated(GoogleMapController controller) {

    mapController = controller;
    mapController.setMapStyle(mapTheme);
    _cntr.complete(mapController);
    location.onLocationChanged.listen((event) {
      mapController.animateCamera(
          CameraUpdate.newCameraPosition(
          CameraPosition(target:
          LatLng(event.latitude!,event.longitude!),zoom: 15),
          ),
      );
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {

    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();

  }

  void _addMarker(LatLng latLng) async{

    Marker newMarker = Marker(
      markerId: MarkerId(DateTime.now().toString()),
      position: latLng,
      icon: BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/markers/custom_marker_blue.png', 48)),
    );

    // Add the new marker to the set.
    setState(() {
      _markers.add(newMarker);
    });

    // Add the new marker to Firestore.
    await FirebaseFirestore.instance.collection('markers').add({
      'lat': latLng.latitude,
      'lng': latLng.longitude,
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFEFEFEF),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.large(
        onPressed:(){},
        backgroundColor: Colors.redAccent,
        child: IconButton(
        color: Colors.white,
        onPressed: () {
          print("sos pressed");
        },
        icon: const Icon(Icons.sos),
      ),
        ),
      body:GoogleMap(
        onMapCreated:_onMapCreated,
        onTap: _addMarker,
        initialCameraPosition: CameraPosition(target: _initialcameraposition, zoom: 15),
        myLocationEnabled: true,
        zoomControlsEnabled: true,
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 3.0,
        shape: const CircularNotchedRectangle(),
        color: Colors.indigoAccent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding:const EdgeInsets.only(right: 130.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    color: Colors.white,
                    onPressed: () {
                      print("emergency contacts pressed");
                    },
                    icon: const Icon(Icons.phone),
                  ),
                  const Text(
                    "Emergency contacts",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
            Padding(
              padding:const EdgeInsets.only(right: 20.0, left: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                verticalDirection: VerticalDirection.down,
                children: [
                  IconButton(
                    color: Colors.white,
                    onPressed: () {
                      print("mark place pressed");
                    },
                    icon: const Icon(Icons.pin_drop_sharp),
                  ),
                  const Text(
                    "Mark history",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            )
          ],
        ),
      ),

    );
  }

  getLoc() async{
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    _initialcameraposition = LatLng(_currentPosition.latitude!,_currentPosition.longitude!);
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentPosition = currentLocation;
        _initialcameraposition = LatLng(_currentPosition.latitude!,_currentPosition.longitude!);
          });
        });
  }

}
