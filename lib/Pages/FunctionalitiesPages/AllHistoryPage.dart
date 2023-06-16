import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:woman_safety_app/Pages/flutter_flow/flutter_flow_theme.dart';

import '../MainPages/MapHomePage.dart';
import 'MarkHistoryPage.dart';


typedef MarkerDeletedCallback = void Function(DocumentSnapshot markerId);

class AllHistoryPageWidget extends StatefulWidget {
  const AllHistoryPageWidget({Key? key}) : super(key: key);

  @override
  _AllHistoryPageWidgetState createState() => _AllHistoryPageWidgetState();
}

class _AllHistoryPageWidgetState extends State<AllHistoryPageWidget> {
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
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return const MarkHistoryPageWidget();
                        }));
                      },
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      child: const Text('All markers',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ), onPressed: () {  },
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
                  return Card(
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
                  );
                },
              )
          ),
        ],
      ),
    );
  }
}
