import '../../Model/emergency_number.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmergencyContactsPageWidget extends StatefulWidget {
  const EmergencyContactsPageWidget({Key? key}) : super(key: key);

  @override
  _EmergencyContactsPageWidgetState createState() =>
      _EmergencyContactsPageWidgetState();
}

class _EmergencyContactsPageWidgetState
    extends State<EmergencyContactsPageWidget> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final CollectionReference collectionRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('emergency_number');
  late EmergencyNumber emergencyNumber = EmergencyNumber(name: '', phone: '');
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
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  Future<List<DocumentSnapshot>> fetchItems() async {
    final QuerySnapshot snapshot = await collectionRef
        .orderBy("created", descending: true)
        .get();

    return snapshot.docs;
  }

  Future<void> addContact([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 30,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.person, color: Color(0xFF0B508C), size: 22),
                    hintText: 'Name',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF0B508C),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.phone, color: Color(0xFF0B508C), size: 22),
                    hintText: 'Phone number',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF0B508C),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B508C),
                  ),
                  onPressed: () async {
                    final String name = nameController.text;
                    final String phone = phoneController.text;
                    if (phoneConfirmed()) {
                      await collectionRef.add({
                        "name": name,
                        "phone": phone,
                        'created': DateTime.now()
                      });

                      nameController.text = '';
                      phoneController.text = '';
                      Navigator.of(context).pop();
                    } else {
                      errorMessage("Incorect number format");
                    }fetchItems().then((docs) {
                      setState(() {
                        items = docs;
                      });
                    });
                  },
                  child: const Text('Add'),
                )
              ],
            ),
          );
        });
  }

  Future<void> editContact([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
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
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.person, color: Color(0xFF0B508C), size: 22),
                    hintText: 'Name',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF0B508C),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.phone, color: Color(0xFF0B508C), size: 22),
                    hintText: 'Phone number',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF0B508C),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B508C),
                  ),
                  onPressed: () async {
                    final String name = nameController.text;
                    final String phone = phoneController.text;
                    if (phoneConfirmed()) {
                      await collectionRef
                          .doc(documentSnapshot!.id)
                          .update({"name": name, "phone": phone});

                      nameController.text = '';
                      phoneController.text = '';
                      Navigator.of(context).pop();
                    } else {
                      errorMessage("Incorect number format");
                    }
                    fetchItems().then((docs) {
                      setState(() {
                        items = docs;
                      });
                    });
                  },
                  child: const Text('Update')
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
        content: const Text('Contact deleted'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await collectionRef.add({
              'name': deletedContact!['name'],
              'phone': deletedContact['phone'],
              'created': deletedContact['created']

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

  Future sort() async {
    await collectionRef.orderBy('name', descending: true).get();
  }

  Future errorMessage(String message) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text(
            message,
            style: const TextStyle(
                color: Colors.grey, fontFamily: 'Poppins', fontSize: 16),
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ]),
    );
  }

  bool isValidPhoneNumber(String phone) {
    String pattern = r'^(?:\+40|0)[ ]?7\d{2}[ ]?\d{3}[ ]?\d{3}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(phone);
  }

  bool phoneConfirmed() {
    if (phoneController.text.isEmpty) {
      errorMessage("Please write your phone number!");
      return false;
    }
    if (isValidPhoneNumber(phoneController.text) == false) {
      errorMessage("Please write a valid phone number!");
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            backgroundColor: const Color(0xFF0B508C),
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
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      iconSize: 34,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: sortItems,
                        icon: const RotatedBox(
                          quarterTurns: 1,
                          child: Icon(
                            Icons.compare_arrows,
                            size: 26,
                            color: Colors.white,
                          ),
                        ),
                        label: Text(
                          ascendingOrder ? 'Sort A-Z' : 'Sort Z-A',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: const [],
            centerTitle: true,
            elevation: 0,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot = items[index];
                  return Dismissible(
                    key: Key(documentSnapshot.id),
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      deleteContact(documentSnapshot.id);
                    },
                    child: Card(
                      margin: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                      color: const Color(0xFFB3E7F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Color(0xFF0B508C),
                          size: 36,
                        ),
                        title: Text(
                          documentSnapshot['name'],
                          style: const TextStyle(
                              color: Color(0xFF0B508C),
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins",
                              fontSize: 18),
                        ),
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
            const SizedBox(height: 20),
            Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsetsDirectional.fromSTEB(50, 25, 50, 25),
                  ),
                  onPressed: () {
                    addContact();
                  },
                  icon: const Icon(
                    Icons.add_box_outlined,
                    size: 24,
                    color: Color(0xFFB3E7F2),
                  ),
                  label: const Text(
                    " Add new emergency contact",
                    style: TextStyle(
                        color: Color(0xFF0B508C),
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                        fontSize: 18),
                  ),
                )),
            const SizedBox(height: 20),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
