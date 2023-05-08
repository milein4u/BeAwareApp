class Users {
  String? email;
  String? phone;

  Users();

  Users.fromSnapshot(snapshot)
      : email = snapshot.data()['email'],
        phone = snapshot.data()['phone'];

  Map<String, dynamic> toFirestore() {
    return {
      if (email != null) "email": email,
      if (phone != null) "last name": phone,
    };
  }


}
