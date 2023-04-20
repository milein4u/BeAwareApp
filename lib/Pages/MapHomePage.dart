import 'dart:async';

import 'package:location/location.dart';
import 'package:intl/intl.dart';
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
  Location location = Location();

  late LocationData _currentPosition;
  late String _adress, _dateTime;

  LatLng _initialcameraposition = LatLng(45.760696, 21.226788);

  @override
  void initState(){
    super.initState();
    getLoc();
  }

  void _onMapCreated(GoogleMapController controller) {

    mapController = mapController;
    location.onLocationChanged.listen((event) {
      mapController.animateCamera(
          CameraUpdate.newCameraPosition(
          CameraPosition(target:
          LatLng(event.latitude!,event.longitude!),zoom: 10),
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
      body:GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: _initialcameraposition, zoom: 10),
        mapType: MapType.normal,
        myLocationEnabled: true,

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
      print("${currentLocation.longitude} : ${currentLocation.longitude}");
      setState(() {
        _currentPosition = currentLocation;
        _initialcameraposition = LatLng(_currentPosition.latitude!,_currentPosition.longitude!);

          });
        });
  }

}
