import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async { 
      SharedPreferences sp = await SharedPreferences.getInstance();
      // final eml = sp.getString("eml");
      // final pass  = sp.getString("password");
      final name = sp.getString("name");
      if(name != null && name.isNotEmpty){
           Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return HomeScreen(name: name);
                        }));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Login Page"),
         //  backgroundColor: Colors.blue,
         backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10.0,
                ),
                SizedBox(
                  height: 190.0,
                  width: 250,
                  child: Image.asset("assets/easy.png"),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(
                          RegExp('[ ]')), // Disallow spaces
                    ],
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                Container(
                  height: 50.0,
                  width: 150.0,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                    ),
                    onPressed: _loginClick,
                    child: Text(
                      "Login", // login button
                      // style: TextStyle(
                      //   color: Colors.white,
                      //   fontSize: 20,
                      // ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _loginClick() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference usersCollection = firestore.collection('users');
    print("user ${emailController.text}");
    // Fetch the first document in the collection
    // Perform a query to find the user with the specific email
    usersCollection
        .where('email', isEqualTo: emailController.text)
        .get()
        .then((QuerySnapshot querySnapshot) async{
      if (querySnapshot.docs.isNotEmpty) {
        // The user with the specified email exists
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        print('User found: ${userDoc.data()}');
        final user = userDoc.data() as Map<String, dynamic>;
        final firebasePassword = user['password'];

        if (firebasePassword == passwordController.text) {
          SharedPreferences sp = await SharedPreferences.getInstance();
          sp.setString("name", user['name']);
          Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return HomeScreen(name: user['name']);
                        }));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Wrong Password")),
          );
        }
      } else {
        // The user with the specified email doesn't exist
        print('User not found');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not found")),
        );
      }
    }).catchError((error) {
      print('Error searching for user: $error');
    });
  }
}
