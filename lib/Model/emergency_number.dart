class EmergencyNumber {
  String? name;
  String? phone;

  EmergencyNumber({required String name, required String phone});

  EmergencyNumber.fromSnapshot(snapshot)
      : name = snapshot.data()['name'],
        phone = snapshot.data()['phone'];

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (phone != null) "phone": phone
    };
  }


}
