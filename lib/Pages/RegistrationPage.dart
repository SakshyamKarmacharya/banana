import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tomato/Pages/HomePage.dart';
import 'package:tomato/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // Controllers for user input fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Form key for form validation
  final _formKey = GlobalKey<FormState>();

  // Firebase authentication instance
  final _auth = FirebaseAuth.instance;

  // Error message to display if registration fails
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // TextFormField for First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // TextFormField for Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // TextFormField for Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // TextFormField for Password
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (!RegExp(
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$')
                        .hasMatch(value)) {
                      return 'Password should contain at least:\n'
                          'One Uppercase Letter\n'
                        'One Lowercase Letter\n'
                        'One Number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // TextFormField for Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    } else if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // ElevatedButton for registration
                ElevatedButton(
                  onPressed: () {
                    _register(
                      _firstNameController.text,
                      _lastNameController.text,
                      _emailController.text,
                      _passwordController.text,
                    );
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to handle user registration
  void _register(String firstName, String lastName, String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Creating a user with email and password
        await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) => {postDetailsToFirestore()})
            .catchError((e) {
          Fluttertoast.showToast(msg: e!.message);
        });
      } on FirebaseAuthException catch (error) {
        // Handling different registration error cases
        switch (error.code) {
          case "email-already-in-use":
            errorMessage = "The account already exists for that email.";
            break;
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "weak-password":
            errorMessage = "Your password is too weak.";
            break;
          case "operation-not-allowed":
            errorMessage = "Account creation with email and password is not enabled.";
            break;
          default:
            errorMessage = "An undefined error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
        print(error.code);
      }
    }
  }

  // Function to post user details to Firestore after successful registration
  postDetailsToFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    // Writing all the values to the user model
    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.firstName = _firstNameController.text;
    userModel.lastName = _lastNameController.text;
    userModel.password = _passwordController.text;

    // Adding the user details to Firestore
    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());

    // Displaying a toast message for successful account creation
    Fluttertoast.showToast(msg: "Account created successfully :) ");

    // Navigating to the home page and removing all previous routes
    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false);
  }
}

