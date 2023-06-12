import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:woman_safety_app/Pages/flutter_flow/flutter_flow_theme.dart';


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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                      color: Colors.red,
                      child: Icon(Icons.delete),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 16.0),
                    ),
                    child: Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(documentSnapshot['category']),
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
