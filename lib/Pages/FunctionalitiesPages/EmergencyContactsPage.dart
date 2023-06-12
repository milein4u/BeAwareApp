import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../Model/EmergencyNumber.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyContactsPageWidget extends StatefulWidget {
  const EmergencyContactsPageWidget({Key? key}) : super(key: key);

  @override
  _EmergencyContactsPageWidgetState createState() => _EmergencyContactsPageWidgetState();
}

class _EmergencyContactsPageWidgetState extends State<EmergencyContactsPageWidget> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  late EmergencyNumber emergencyNumber = EmergencyNumber(name: '', phone: '');
  final CollectionReference collectionRef =
  FirebaseFirestore.instance.collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('emergency_number');
  List<DocumentSnapshot> items = [];
  bool ascendingOrder = true;


  @override
  void initState() {
    super.initState();
    fetchItems().then((docs) {
      setState(() {
        items = docs;
      });
    });
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

  Future<List<DocumentSnapshot>> fetchItems() async {
    final QuerySnapshot snapshot = await collectionRef
        .get();

    return snapshot.docs;
  }

  void sortItems() {
    setState(() {
      if (ascendingOrder) {
        items.sort((a, b) => a['name'].compareTo(b['name']));
      } else {
        items.sort((a, b) => b['name'].compareTo(a['name']));
      }
      ascendingOrder = !ascendingOrder;
    });
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
    DocumentSnapshot? deletedContact;
    int deletedContactIndex = -1;

    for (int i = 0; i < items.length; i++) {
      if (items[i].id == contactId) {
        deletedContact = items[i];
        deletedContactIndex = i;
        break;
      }
    }

    if (deletedContact == null || deletedContactIndex == -1) return;

    await collectionRef.doc(contactId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact deleted'),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await collectionRef.add({
              'name': deletedContact!['name'],
              'phone': deletedContact['phone'],
              'created': DateTime.now(),
            });
            fetchItems().then((docs) {
              setState(() {
                items = docs;
              });
            });
          },
        ),
      ),
    );

    setState(() {
      items.removeAt(deletedContactIndex);
    });
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
              onPressed: sortItems,
              icon: RotatedBox(
                quarterTurns: 1,
                child: Icon(Icons.compare_arrows, size: 26,),
              ),
              label: Text(
                ascendingOrder ? 'Sort A-Z' : 'Sort Z-A'
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot = items[index];
                  return Dismissible(
                    key: Key(documentSnapshot.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      deleteContact(documentSnapshot.id);
                    },
                    child: Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(documentSnapshot['name']),
                        subtitle: Text(documentSnapshot['phone']),
                        trailing: IconButton(
                          onPressed: () => editContact(documentSnapshot),
                          icon: const Icon(Icons.edit),
                        ),
                      ),
                    ),
                  );
                },
                scrollDirection: Axis.vertical,
              ),
            ),
            SizedBox(height: 100),
      ],
      ),

          floatingActionButton: FloatingActionButton(
            onPressed: () => addContact(),
            child: const Icon(Icons.add),

          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }

}