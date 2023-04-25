import 'dart:async';
import 'dart:developer';

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
  Location location = Location();
  LatLng _initialcameraposition = LatLng(45.760696, 21.226788);
  String mapTheme = '';

  @override
  void initState(){
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFEFEFEF),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.large(
        onPressed:(){},
        backgroundColor: Colors.indigoAccent,
        child: Icon(Icons.photo_camera),
        ),
      body:GoogleMap(
        onMapCreated:_onMapCreated,
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
              padding:const EdgeInsets.only(left: 0.0),
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
                    "Emergency",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
            Padding(
              padding:const EdgeInsets.only(left: 10.0),
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
                    "Mark",
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
