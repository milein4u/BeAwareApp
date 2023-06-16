import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:woman_safety_app/Pages/FunctionalitiesPages/AllHistoryPage.dart';
import 'package:woman_safety_app/Pages/flutter_flow/flutter_flow_theme.dart';

import '../MainPages/MapHomePage.dart';


typedef MarkerDeletedCallback = void Function(DocumentSnapshot markerId);

class MarkHistoryPageWidget extends StatefulWidget {
  const MarkHistoryPageWidget({Key? key}) : super(key: key);

  @override
  _MarkHistoryPageWidgetState createState() => _MarkHistoryPageWidgetState();
}

class _MarkHistoryPageWidgetState extends State<MarkHistoryPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<DocumentSnapshot> _markerList = [];

  @override
  void initState() {
    super.initState();
    fetchMarkers().then((docs) {
      setState(() {
        _markerList = docs;
      });
    });
  }

  Future<List<DocumentSnapshot>> fetchMarkers() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('markers')
        .where("marker_uid", isEqualTo: userId.toString())
        .get();
    return snapshot.docs;
  }
  
  int selectedColor(String category){
    if(category == 'Unsafe physical spaces'){
      return 0xFF34A6BF;
    }else if(category == 'Verbal or psychological harassment'){
      return 0xFFF28705;
    }else
      return 0xFFBF491F;
  }

  Future<void> deleteMarker(String markerId) async {
    DocumentSnapshot? deletedMarker;
    int deletedMarkerIndex = -1;

    for (int i = 0; i < _markerList.length; i++) {
      if (_markerList[i].id == markerId) {
        deletedMarker = _markerList[i];
        deletedMarkerIndex = i;
        break;
      }
    }

    if (deletedMarker == null || deletedMarkerIndex == -1) return;

    await FirebaseFirestore.instance.collection('markers').doc(markerId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marker deleted'),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await FirebaseFirestore.instance.collection('markers').add({
              'lat': deletedMarker!['lat'],
              'long': deletedMarker['long'],
              'category': deletedMarker['category'],
              'marker_uid': FirebaseAuth.instance.currentUser!.uid,
            });
            fetchMarkers().then((docs){
              setState(() {
                _markerList = docs;
              });
            });
          },
        ),
      ),
    );

    setState(() {
      _markerList.removeAt(deletedMarkerIndex);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Color(0xFF0B508C),
          automaticallyImplyLeading: false,
          title: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.arrow_back_ios_new_rounded),
                    iconSize: 34,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const MapHomePageWidget();
                      }));
                    },
                  ),
                  Expanded(
                    child: TextButton(
                      child: const Text('Your markers',
                         style: TextStyle(
                          color: Colors.white,
                        ),
                      ), onPressed: () {  },
                    ),
                  ),
                  Expanded(
                      child: TextButton(
                        child: const Text('All markers',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return AllHistoryPageWidget();
                          }));
                          },
                      ),
                  )
                ],
              ),
            ],
          ),
          actions: [],
          centerTitle: true,
          elevation: 0,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _markerList.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot = _markerList[index] as DocumentSnapshot<Object?>;
                  return Dismissible(
                    key: Key(documentSnapshot.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Marker'),
                            content: Text('Are you sure you want to delete this marker?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      deleteMarker(documentSnapshot.id);
                    },
                    background: Container(
                      color: Colors.redAccent,
                      child: Icon(Icons.delete,
                        color: Colors.white),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20.0),
                    ),
                    child: Card(
                      margin: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Color(selectedColor(documentSnapshot['category'])),
                      child: ListTile(
                        trailing: Text(documentSnapshot['time'].toString(), style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                          fontSize: 12
                      ),
                      ),
                        title: Text(documentSnapshot['category'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            fontSize: 18
                          ),
                        ),
                        subtitle: Text(documentSnapshot['address'], style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            fontSize: 12
                         ),
                        ),
                      ),
                    ),
                  );
                },
              )
          ),
        ],
      ),
    );
  }
}
