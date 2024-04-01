import 'package:ewj_account_manage/firebase_options.dart';
import 'package:ewj_account_manage/screens/firebase_test_screen.dart';
import 'package:ewj_account_manage/screens/home_screen.dart';
import 'package:ewj_account_manage/screens/name_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login/login_page.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(EasyWearJunctionApp());
}

class EasyWearJunctionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EWJ Account Manager',
      theme: ThemeData(
        primaryColor: Colors.teal,
      ),
      home: LoginScreen(),
    );
  }
}

