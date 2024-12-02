/// A model class representing a user with essential attributes.
class UserModel {
  String? uid;
  String? email;
  String? firstName;
  String? lastName;
  String? password;

  /// Constructor for creating a UserModel instance.
  UserModel({this.uid, this.email, this.firstName, this.lastName, this.password});

  /// Factory constructor to create a UserModel instance from a map.
  ///
  /// Used for receiving data from the server.
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      password: map['password'],
    );
  }

  /// Method to convert the UserModel instance to a map.
  ///
  /// Used for sending data to the server.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'secondName': lastName,
      'password':password,
    };
  }
}