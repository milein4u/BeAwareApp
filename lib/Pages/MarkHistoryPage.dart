import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:woman_safety_app/Pages/Cards/emergencyContactCard.dart';

import '../Model/EmergencyNumber.dart';
import 'MapHomePage.dart';
import 'StartPage.dart';
import 'flutter_flow/flutter_flow_icon_button.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class MarkHistoryPageWidget extends StatefulWidget {
  const MarkHistoryPageWidget({Key? key}) : super(key: key);

  @override
  _MarkHistoryPageWidgetState createState() => _MarkHistoryPageWidgetState();
}

class _MarkHistoryPageWidgetState extends State<MarkHistoryPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<MarkerData> _markerList = [];

  @override
  void initState() {
    super.initState();
    fetchMarkersFromFirestore();
  }

  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    String address = '';

    try {
      List<geocoding.Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        geocoding.Placemark placemark = placemarks.first;
        address = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
      }
    } catch (e) {
      print('Error fetching address: $e');
    }

    return address;
  }


  void fetchMarkersFromFirestore() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('markers')
        .where("marker_uid",isEqualTo: userId.toString())
        .get();

    List<MarkerData> markers = []; // Temporary list to store fetched markers

    querySnapshot.docs.forEach((document) {
      double latitude = document['lat'];
      double longitude = document['long'];
      //String adress = getAddressFromLatLng(latitude, longitude) as String;
      String category = document['category'];
      // Fetch address based on position using geocoding APIs or other methods

      MarkerData markerData = MarkerData(
        markerId: document.id,
        category: category,
        address: "Adress", // Replace with actual address
      );

      markers.add(markerData);
    });

    setState(() {
      _markerList = markers; // Update the marker list state
    });
    print(_markerList);
  }

  Future<void> deleteMarker(String markerId) async {
    await FirebaseFirestore.instance
        .collection('markers')
        .doc(markerId)
        .delete();

    setState(() {
      _markerList.removeWhere((marker) => marker.markerId == markerId);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: true,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,

        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            title: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                        color: Colors.black,
                        icon: Icon(Icons.arrow_back),
                        iconSize: 38,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [],
            centerTitle: true,
            elevation: 0,
          ),
        ),
        body: ListView.builder(
        itemCount: _markerList.length,
        itemBuilder: (context, index) {
          MarkerData markerData = _markerList[index];
          return Dismissible(
            key: Key(markerData.markerId),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              deleteMarker(markerData.markerId);
            },
            background: Container(
              color: Colors.red,
              child: Icon(Icons.delete),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 16.0),
            ),
            child: ListTile(
              title: Text(markerData.category),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(markerData.address),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}

class MarkerData {
  final String markerId;
  final String category;
  final String address;


  MarkerData({
    required this.markerId,
    required this.category,
    required this.address,
  });
}