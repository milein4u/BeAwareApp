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

class EmergencyContactsPageWidget extends StatefulWidget {
  const EmergencyContactsPageWidget({Key? key}) : super(key: key);

  @override
  _EmergencyContactsPageWidgetState createState() => _EmergencyContactsPageWidgetState();
}

class _EmergencyContactsPageWidgetState extends State<EmergencyContactsPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  late EmergencyNumber emergencyNumber = EmergencyNumber();
  final CollectionReference collectionRef =
  FirebaseFirestore.instance.collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('emergency_number');
  bool isDescending = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  }

  Future<void> editContact([DocumentSnapshot? documentSnapshot]) async {
    if(documentSnapshot != null){
      nameController.text = documentSnapshot['name'];
      phoneController.text = documentSnapshot['phone'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone number',),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text( 'Update'),
                  onPressed: () async {
                    final String name = nameController.text;
                    final String phone = phoneController.text;
                    await collectionRef
                        .doc(documentSnapshot!.id)
                        .update({"name": name, "phone": phone});
                    nameController.text = '';
                    phoneController.text = '';
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> addContact([DocumentSnapshot? documentSnapshot]) async {

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone number'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Add'),
                  onPressed: () async {
                    final String name = nameController.text;
                    final String phone = phoneController.text;
                    await collectionRef.add({"name": name, "phone": phone,'created': DateTime.now()});

                    nameController.text = '';
                    phoneController.text = '';
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );

        });
  }

  Future<void> deleteContact(String contactId) async {
    await collectionRef.doc(contactId).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a contact')));
  }
  
  Future sort() async{
    await collectionRef
        .orderBy('name', descending: true)
        .get();
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
            TextButton.icon(
              onPressed: () {
                setState(() =>
                isDescending = !isDescending);
                sort();
              },
              icon: RotatedBox(
                quarterTurns: 1,
                child: Icon(Icons.compare_arrows, size: 26,),
              ),
              label: Text(
                isDescending ? 'Descending' : 'Ascending'
              ),
            ),
            SizedBox(height: 16),
        Expanded(
            child:StreamBuilder(
              stream: collectionRef.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot){
                if(streamSnapshot.hasData){
                  return ListView.builder(
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index){
                      final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(documentSnapshot['name']),
                          subtitle: Text(documentSnapshot['phone']),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: () => editContact(documentSnapshot),
                                    icon: const Icon(Icons.edit)),
                                IconButton(
                                    onPressed: () => deleteContact(documentSnapshot.id),
                                    icon: const Icon(Icons.delete))
                              ],

                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
        ),
      ],
      ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => addContact(),
            child: const Icon(Icons.add),

          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }

}