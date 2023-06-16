import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../FunctionalitiesPages/EmergencyContactsPage.dart';
import '../FunctionalitiesPages/MarkHistoryPage.dart';


class MapHomePageWidget extends StatefulWidget {
  const MapHomePageWidget({Key? key}) : super(key: key);

  @override
  _MapHomePageWidgetState createState() => _MapHomePageWidgetState();
}

class _MapHomePageWidgetState extends State<MapHomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late LatLng googleMapsCenter;
  late LocationData _currentPosition;
  late GoogleMapController mapController;
  late Marker marker;
  late Timer logoutTimer;
  final Completer<GoogleMapController> _cntr = Completer();
  final markersSnapshot = FirebaseFirestore.instance.collection('markers').get();
  List<Marker> _markersList = [];
  List<String> recipents = [];
  Location location = Location();
  LatLng _initialcameraposition = LatLng(45.760696, 21.226788);
  String mapTheme = '';
  String message = '';
  String address = "";
  String dateTime = "";
  String key = "AIzaSyAY8euc6uR3PwJ-UdfIv7R1rINBiXsiT4Y";

  static const platform = const MethodChannel('com.example.volumeButtonHandler');
  int volumeDownCount = 0;


  @override
  void initState() {
    super.initState();
    enableVolumeButtonHandler();
    logoutTimer = Timer(Duration.zero, handleLogout);
    logoutTimerStart();
    fetchMarkersFromFirestore();
    getLoc();
    DefaultAssetBundle.of(context)
        .loadString('assets/maptheme/silver.json')
        .then((string) {
      mapTheme = string;
    }).catchError((error) {
      log(error.toString());
    });
  }

  @override
  void dispose() {
    logoutTimer.cancel();
    super.dispose();
  }

  Future<void> enableVolumeButtonHandler() async {
    try {
      await platform.invokeMethod('enableVolumeButtonHandler');
    } on PlatformException catch (e) {
      print("Failed to enable volume button handler: ${e.message}");
    }
  }

  Future<void> handleVolumeButtonPress() async {
    volumeDownCount++;
    if (volumeDownCount == 3) {
      _sendSMS(smsTextLocation(message, _currentPosition),recipents);
      print("Volume down button pressed three times");
    }
  }

  Future logoutTimerStart() async {
    const inactivity = Duration(hours: 72);
    logoutTimer.cancel();
    logoutTimer = Timer(inactivity, handleLogout);
  }

  void resetLogoutTimer() {
    if (logoutTimer != null) {
      logoutTimer.cancel();
    }
    logoutTimerStart();
  }

  void handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, 'start_page');
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(mapTheme);
    _cntr.complete(mapController);
    location.onLocationChanged.listen((event) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target:
          LatLng(event.latitude!, event.longitude!), zoom: 20),
        ),
      );
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer
        .asUint8List();
  }

  void addMarker(LatLng position) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedCategory;
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text('Choose one of the following categories'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    RadioListTile(
                      title: Text('Unsafe physical spaces'),
                      subtitle: Text('Poor lighting/Lack of Surveillance'),
                      value: 'Unsafe physical spaces',
                      groupValue: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('Verbal or psychological harassment'),
                      subtitle: Text('Catcalling/Verbal Threats/Hate Speech/Stalking'),
                      value: 'Verbal or psychological harassment',
                      groupValue: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('Physical harassment'),
                      subtitle: Text('Assault/Robbery/Sexual harassment'),
                      value: 'Physical harassment',
                      groupValue: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    if (selectedCategory != null) {
                      Navigator.of(context).pop(selectedCategory);
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text('Please choose one of the categories.'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((selectedCategory) async {
      if (selectedCategory != null) {
        final newMarker = Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          icon: selectedItem(selectedCategory),
          infoWindow: InfoWindow(title: selectedCategory),
        );

        setState(() {
          _markersList.add(newMarker);
        });

        await saveMarkerToFirestore(newMarker, selectedCategory);
        // Update the marker data in Firestore with the selected category

        // Zoom in on the marker
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(position, 20),
        );
      }
    });
  }


  BitmapDescriptor selectedItem(String category){
    if(category == 'Unsafe physical spaces'){
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }else if(category == 'Verbal or psychological harassment'){
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }else
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  }

  Future<String> convertToAddress(double lat, double long, String apikey) async {
    Dio dio = Dio();  //initilize dio package
    String apiurl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$apikey";

    Response response = await dio.get(apiurl); //send get request to API URL

    if(response.statusCode == 200){ //if connection is successful
      Map data = response.data; //get response data
      if(data["status"] == "OK"){ //if status is "OK" returned from REST API
        if(data["results"].length > 0){ //if there is atleast one address
          Map firstresult = data["results"][0]; //select the first address

          address = firstresult["formatted_address"]; //get the address
        }
      }else{
        print(data["error_message"]);
      }
    }else{
      print("error while fetching geoconding data");
    }

    return address;
  }

  String dateTimeDisplay(){

    dateTime = "${DateTime.now().day}-${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute}";
    return dateTime;
  }

  Future<void> saveMarkerToFirestore(Marker marker, String category) async {
    final markerData = {
      'lat': marker.position.latitude,
      'long': marker.position.longitude,
      'marker_uid': FirebaseAuth.instance.currentUser?.uid,
      'category': category,
      'address': await convertToAddress(marker.position.latitude, marker.position.longitude, key),
      'time': dateTimeDisplay(),
    };

    try {
      await FirebaseFirestore.instance.collection('markers').add(markerData);
      print('Marker saved to Firestore');
    } catch (error) {
      print('Failed to save marker: $error');
    }
  }

  Future<void> fetchMarkersFromFirestore() async {
    final markersSnapshot =
    await FirebaseFirestore.instance.collection('markers').get();

    List<Marker> markers = [];

    markersSnapshot.docs.forEach((doc) {
      double latitude = doc['lat'];
      double longitude = doc['long'];
      String category = doc['category'];

      markers.add(
        Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title: category),
          icon: selectedItem(category),
        ),
      );
    });

    setState(() {
      _markersList = markers;
    });
  }

  void _handleMarkerDeleted(String markerId) {
    setState(() {
      // Remove the marker from the _markers set based on the markerId
      _markersList.where((marker) => marker.markerId.value != markerId).toSet();
    });
  }

  String smsTextLocation(String message, LocationData locationData){
    message = 'Hello, I feel I could be in possible danger, this is my current location: https://www.google.com/maps/place/${locationData.latitude},${locationData.longitude}';
    return message;
  }

  Future<List<String>> getRecipients() async {
    List<String> contacts = [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('emergency_number')
        .get();

    snapshot.docs.forEach((doc) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('phone')) {
        contacts.add(data['phone'].toString());
      }
    });

    return contacts;
  }

  Future<void> _sendSMS(String message, List<String> recipents) async {
    recipents = await getRecipients();
    await sendSMS(message: message, recipients: recipents);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        resetLogoutTimer();
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            actions: [],
            centerTitle: true,
            elevation: 0,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton.large(
          onPressed: () {},
          backgroundColor: Colors.redAccent,
          child: IconButton(
            color: Colors.white,
            onPressed: () {
              // _sendLocationSMS();
              _sendSMS(smsTextLocation(message, _currentPosition),recipents);
            },
            icon: const Icon(Icons.sos),
          ),
        ),
        body: Stack(
        children:  [
          GoogleMap(
          onMapCreated: _onMapCreated,
          markers: Set<Marker>.from(_markersList),
          onTap: (LatLng position) {
            addMarker(position);
          },
          initialCameraPosition: CameraPosition(
              target: _initialcameraposition, zoom: 15),
          myLocationEnabled: true,
          zoomControlsEnabled: true,
         ),
          Positioned(
              child: FloatingActionButton(
                onPressed: fetchMarkersFromFirestore,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.refresh,
                  color: Colors.black,
                ),
              ),
            top: 10,
            left: 16,
          ),
        ],
        ),
        bottomNavigationBar: BottomAppBar(
          notchMargin: 3.0,
          shape: const CircularNotchedRectangle(),
          color: Color(0xFF0B508C),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 130.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      color: Colors.white,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (
                            context) {
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
                padding: const EdgeInsets.only(right: 20.0, left: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  verticalDirection: VerticalDirection.down,
                  children: [
                    IconButton(
                      color: Colors.white,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (
                            context) {
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

  getLoc() async {
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
    _initialcameraposition =
        LatLng(_currentPosition.latitude!, _currentPosition.longitude!);
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentPosition = currentLocation;
        _initialcameraposition =
            LatLng(_currentPosition.latitude!, _currentPosition.longitude!);
      });
    });


  }
}