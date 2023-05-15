import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:woman_safety_app/Model/EmergencyNumber.dart';

class ContactCard extends StatelessWidget{
  final EmergencyNumber number;
  final CollectionReference collectionRef =
  FirebaseFirestore.instance.collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('emergency_number');

  ContactCard(this.number, {super.key});

  Future deleteNumber(String id) async{
    try {
      await collectionRef
          .doc(id)
          .delete();
    }catch (e){
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(number.name.toString())
                ),
                Expanded(
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.edit),
                    )
                )
              ],

            ),
            Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(number.phone.toString())
                ),
                Expanded(
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text('Are you sure you want to delete this number?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // deleteNumber();
                                    Navigator.pop(context);
                                  },
                                  child: Text('Yes'),
                                ),
                              ],
                            ));
                      },
                      icon: Icon(Icons.delete),
                    )
                )
              ],
            )

          ],
        ),
      )
    );
  }
}