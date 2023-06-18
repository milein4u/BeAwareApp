import '../../icons/custom_icons_icons.dart';
import '../FunctionalitiesPages/emergency_contacts_page.dart';
import '../FunctionalitiesPages/mark_history_page.dart';
import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


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
  final markersSnapshot =
      FirebaseFirestore.instance.collection('markers').get();
  List<Marker> _markersList = [];
  List<String> recipents = [];
  Location location = Location();
  LatLng _initialcameraposition = const LatLng(45.760696, 21.226788);
  String mapTheme = '';
  String message = '';
  String address = "";
  String dateTime = "";
  String key = "AIzaSyAY8euc6uR3PwJ-UdfIv7R1rINBiXsiT4Y";

  @override
  void initState() {
    super.initState();
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


  getLoc() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
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

  Future<void> fetchMarkersFromFirestore() async {
    final markersSnapshot =
    await FirebaseFirestore.instance.collection('markers').get();

    List<Marker> markers = [];

    for (var doc in markersSnapshot.docs) {
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
    }

    setState(() {
      _markersList = markers;
    });
  }

  Future<void> saveMarkerToFirestore(Marker marker, String category) async {
    final markerData = {
      'lat': marker.position.latitude,
      'long': marker.position.longitude,
      'marker_uid': FirebaseAuth.instance.currentUser?.uid,
      'category': category,
      'address': await convertToAddress(
          marker.position.latitude, marker.position.longitude, key),
      'time': dateTimeDisplay(),
      'timestamp': DateTime.now(),
    };

    try {
      await FirebaseFirestore.instance.collection('markers').add(markerData);
      if (kDebugMode) {
        print('Marker saved to Firestore');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Failed to save marker: $error');
      }
    }
  }

  Future<String> convertToAddress(
      double lat, double long, String apikey) async {
    Dio dio = Dio();
    String apiref =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$apikey";

    Response response = await dio.get(apiref); //send get request to API URL

    if (response.statusCode == 200) {
      Map data = response.data;
      if (data["status"] == "OK") {
        if (data["results"].length > 0) {
          Map result = data["results"][0];
          address = result["formatted_address"];
        }
      } else {
        if (kDebugMode) {
          print(data["error_message"]);
        }
      }
    } else {
      if (kDebugMode) {
        print("error while fetching geoconding data");
      }
    }

    return address;
  }

  Future<List<String>> getRecipients() async {
    List<String> contacts = [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('emergency_number')
        .get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('phone')) {
        contacts.add(data['phone'].toString());
      }
    }

    return contacts;
  }

  Future<void> _sendSMS(String message, List<String> recipents) async {
    recipents = await getRecipients();
    await sendSMS(message: message, recipients: recipents);
  }

  Future logoutTimerStart() async {
    const inactivity = Duration(hours: 72);
    logoutTimer.cancel();
    logoutTimer = Timer(inactivity, handleLogout);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(mapTheme);
    _cntr.complete(mapController);
    location.onLocationChanged.listen((event) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(event.latitude!, event.longitude!), zoom: 20),
        ),
      );
    });
  }

  void addMarker(LatLng position) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedCategory;
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: const Text('Choose one of the following categories'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    RadioListTile(
                      title: const Text('Unsafe physical spaces'),
                      subtitle: const Text('Poor lighting/Lack of Surveillance'),
                      value: 'Unsafe physical spaces',
                      groupValue: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    RadioListTile(
                      title: const Text('Verbal or psychological harassment'),
                      subtitle: const Text(
                          'Catcalling/Verbal Threats/Hate Speech/Stalking'),
                      value: 'Verbal or psychological harassment',
                      groupValue: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    RadioListTile(
                      title: const Text('Physical harassment'),
                      subtitle: const Text('Assault/Robbery/Sexual harassment'),
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
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    if (selectedCategory != null) {
                      Navigator.of(context).pop(selectedCategory);
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content:
                            const Text('Please choose one of the categories.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
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

  void resetLogoutTimer() {
    logoutTimer.cancel();
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

  BitmapDescriptor selectedItem(String category) {
    if (category == 'Unsafe physical spaces') {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    } else if (category == 'Verbal or psychological harassment') {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  String dateTimeDisplay() {
    dateTime =
        "${DateTime.now().day}-${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute}";
    return dateTime;
  }

  String smsTextLocation(String message, LocationData locationData) {
    message =
        'Hello, I feel I could be in possible danger, this is my current location: https://www.google.com/maps/place/${locationData.latitude},${locationData.longitude}';
    return message;
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
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            actions: const [],
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
              _sendSMS(smsTextLocation(message, _currentPosition), recipents);
            },
            icon: const Icon(CustomIcons.welcome_logo),
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              markers: Set<Marker>.from(_markersList),
              onTap: (LatLng position) {
                addMarker(position);
              },
              initialCameraPosition:
                  CameraPosition(target: _initialcameraposition, zoom: 15),
              myLocationEnabled: true,
              zoomControlsEnabled: true,
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          notchMargin: 3.0,
          shape: const CircularNotchedRectangle(),
          color: const Color(0xFF0B508C),
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
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const EmergencyContactsPageWidget();
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
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const MarkHistoryPageWidget();
                        }));
                      },
                      icon: const Icon(Icons.list),
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

}


