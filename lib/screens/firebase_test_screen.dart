import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseTestScreen extends StatelessWidget {
  const FirebaseTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Test'),
      ),
      body: Column(children: [
        Expanded(
            child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            final products = snapshot.data?.docs ?? [];

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index].data() as Map<String, dynamic>;
                return Card(child: Column(
                  children: [
                    Text("Name: ${product['name']}", style: TextStyle(fontSize: 20.0),),
                    Text("Price: ${product['price']}", style: TextStyle(fontSize: 20.0),),
                    Text("Quantity: ${product['quantity']}", style: TextStyle(fontSize: 20.0),),
                  ],
                ));
              },
            );
          },
        )),
        ElevatedButton(
          child: Text('Firebase Test'),
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Adding..."),
                duration: Duration(seconds: 1),
              ),
            );
            FirebaseFirestore firestore = FirebaseFirestore.instance;

            await firestore.collection('products').add({
              'name': 'pant',
              'price': 200,
              'quantity': Random().nextInt(5),
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("DONE :D"),
                duration: Duration(seconds: 1),
              ),
            );
          },
        )
      ]),
    );
  }
}
