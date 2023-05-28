import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sms/sms.dart';
import 'EmergencyContactsPage.dart';
import 'MarkHistoryPage.dart';

class MapHomePageWidget extends StatefulWidget {
  const MapHomePageWidget({Key? key}) : super(key: key);

  @override
  _MapHomePageWidgetState createState() => _MapHomePageWidgetState();
}

class _MapHomePageWidgetState extends State<MapHomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late Timer logoutTimer;
  late GoogleMapController mapController;
  late LatLng googleMapsCenter;
  late Marker marker;
  late LocationData _currentPosition;
  late LocationData _liveLocation;
  final Completer<GoogleMapController> _cntr = Completer();
  List<Marker> _markersList =[];
  Location location = Location();
  LatLng _initialcameraposition = LatLng(45.760696, 21.226788);
  String mapTheme = '';
  final markersSnapshot = FirebaseFirestore.instance.collection('markers').get();

  @override
  void initState(){
    super.initState();
    logoutTimer = Timer(Duration.zero, handleLogout);
    logoutTimerStart();
    fetchMarkersFromFirestore();
    getLoc();
    DefaultAssetBundle.of(context).loadString('assets/maptheme/silver.json').then((string) {
      mapTheme = string;
      print(mapTheme);
    }).catchError((error) {
      print('here');
      log(error.toString());
    });

  }

  Future logoutTimerStart() async{
    const inactivityDuration = Duration(hours: 72);

    if (logoutTimer != null) {
      logoutTimer.cancel();
    }

    logoutTimer = Timer(inactivityDuration, handleLogout);

  }

  void resetLogoutTimer() {
    if(logoutTimer!=null) {
      logoutTimer.cancel();
    }
    logoutTimerStart();
  }

  void handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, 'start_page');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<void> fetchMarkersFromFirestore() async {
    final markersSnapshot =
    await FirebaseFirestore.instance.collection('markers').get();

    setState(() {
      _markersList = markersSnapshot.docs.map((doc) {
        final markerData = doc.data();
        final LatLng position =
        LatLng(markerData['latitude'], markerData['longitude']);

        return Marker(
          markerId: MarkerId(doc.id),
          position: position,
        );
      }).toList();
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
          LatLng(event.latitude!,event.longitude!),zoom: 20),
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

  void addMarker(LatLng position) async{
    final newMarker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
    );

    setState(() {
      _markersList.add(newMarker);
    });

    // Save marker data to Firestore
    await saveMarkerToFirestore(newMarker);
  }

  Future<void> saveMarkerToFirestore(Marker marker) async {
    final markerData = {
      'lat': marker.position.latitude,
      'long': marker.position.longitude,
      'marker_uid': FirebaseAuth.instance.currentUser?.uid,
    };

    try {
      await FirebaseFirestore.instance.collection('markers').add(markerData);
      print('Marker saved to Firestore');
    } catch (error) {
      print('Failed to save marker: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
      resetLogoutTimer();
    },
    child: Scaffold(
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
          // _sendLocationSMS();
          print('sent location');
        },
        icon: const Icon(Icons.sos),
      ),
        ),
      body:GoogleMap(
            onMapCreated:_onMapCreated,
            onTap: (LatLng position){addMarker(position);},
            markers: Set<Marker>.from(_markersList),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return EmergencyContactsPageWidget();
                      }));
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return MarkHistoryPageWidget();
                      }));
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
    
  @override
  void dispose() {
    logoutTimer.cancel();
    super.dispose();
  }

  Future<LocationData?> getLiveLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check if location services are enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    // Check if location permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    _liveLocation = await location.getLocation();
    return _liveLocation;
  }

  // void sendLocationSMS(String phoneNumber, LocationData locationData) {
  //   SmsSender sender = SmsSender();
  //   String message = 'My current location: https://www.google.com/maps/place/${locationData.latitude},${locationData.longitude}';
  //   SmsMessage smsMessage = SmsMessage(phoneNumber, message);
  //
  //   sender.sendSms(smsMessage);
  // }

  // Future<void> _sendLocationSMS() async {
  //   LocationData? locationData = await getLiveLocation();
  //   if (locationData != null) {
  //     sendLocationSMS('0755186487', locationData);
  //   } else {
  //     // Handle the case where the location data is null
  //     print('Unable to retrieve location data');
  //   }
  // }

}
