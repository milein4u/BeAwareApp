class Users {
  String? firstName;
  String? lastName;
  int? age;

  Users();

  Users.fromSnapshot(snapshot)
      : firstName = snapshot.data()['first name'],
        lastName = snapshot.data()['last name'],
        age = snapshot.data()['age'];

  Map<String, dynamic> toFirestore() {
    return {
      if (firstName != null) "first name": firstName,
      if (lastName != null) "last name": lastName,
      if (age != null) "age": age,
    };
  }


}
