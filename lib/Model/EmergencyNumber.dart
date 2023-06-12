class EmergencyNumber {
  String? name;
  String? phone;
  DateTime? created;

  EmergencyNumber({required String name, required String phone});

  EmergencyNumber.fromSnapshot(snapshot)
      : name = snapshot.data()['name'],
        phone = snapshot.data()['phone'],
        created = snapshot.data()['created'].toDate();

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (phone != null) "phone": phone,
      if (created != null) "created": created,
    };
  }


}
