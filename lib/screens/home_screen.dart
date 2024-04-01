import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewj_account_manage/login/login_page.dart';
import 'package:ewj_account_manage/models/product_model.dart';
import 'package:ewj_account_manage/screens/firebase_test_screen.dart';
import 'package:ewj_account_manage/widgets/product_list_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'name_screen.dart';

class HomeScreen extends StatefulWidget {
  final String name;

  const HomeScreen({super.key, required this.name});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int productCount = 1;

  List<Product> products = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  void addProduct() async {
    FocusScope.of(context).unfocus();
    String name = nameController.text;
    int price = int.tryParse(priceController.text) ?? 0;

    if (name.isNotEmpty && price > 0) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('products').add({
        'name': name,
        'price': price,
        'quantity': productCount,
        'createdAt': FieldValue.serverTimestamp(),
        'seller' : widget.name,
      });

      // firebase er total sale ta update koro

      updateServerSaleInfo(count: productCount, price: price);

      setState(() {
        products.add(Product(name, price, productCount));
        nameController.clear();
        priceController.clear();
        productCount = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EWJ Account Manager'),
        actions: [
            IconButton(
                onPressed: () async{
                  print("Tab");
                   SharedPreferences sp = await SharedPreferences.getInstance();
                  await sp.remove("name");
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                },
                icon: Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.blue,
                margin: const EdgeInsets.all(0.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('sale_summary')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          "Loading",
                          style: TextStyle(color: Colors.white),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return Text('No data available');
                      }

                      final data = snapshot.data?.docs.first.data()
                          as Map<String, dynamic>;
                      // Use data to display the document information in your widget.
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${widget.name}"),
                          Text(
                            "Total: ${data['count']}",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "${data['amount']}.00৳",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: 15.0,
            ),
            Row(
              children: [
                Expanded(
                    child: Text(
                  "Quantity: $productCount",
                  style: TextStyle(fontSize: 16.0),
                )),
                ElevatedButton(
                  onPressed: () {
                    if (productCount == 1) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Min Quanitity must be 1"),
                        backgroundColor: Colors.red,
                      ));
                      return;
                    }
                    setState(() {
                      productCount--;
                    });
                  },
                  child: Icon(Icons.remove),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700),
                ),
                SizedBox(
                  width: 10.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      productCount++;
                    });
                  },
                  child: Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700),
                )
              ],
            ),
            SizedBox(
              height: 15.0,
            ),
            ElevatedButton(
              onPressed: addProduct,
              child: Text('Add Sale'),
              style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0)),
            ),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final products = snapshot.data?.docs ?? [];

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product =
                        products[index].data() as Map<String, dynamic>;
                    return ProductListTile(product: product);
                  },
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  void updateServerSaleInfo({required int count, required int price}) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the SalesSummary collection
    CollectionReference salesSummaryCollection = firestore.collection('sale_summary');

    // Fetch the first document in the collection
    salesSummaryCollection
        .limit(1)  // Limit the query to the first document
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // Retrieve the first document
        DocumentSnapshot document = querySnapshot.docs.first;

        // Update the document with the new count and price values
        int currentCount = document['count'] ?? 0;
        int currentPrice = document['amount'] ?? 0;

        // Calculate the updated values
        int updatedCount = currentCount + count;
        int updatedPrice = currentPrice + price;

        // Update the document with the new values
        document.reference.update({
          'count': updatedCount,
          'amount': updatedPrice,
        }).then((_) {
          print('Document updated successfully.');
        }).catchError((error) {
          print('Error updating document: $error');
        });
      } else {
        // Handle the case when no documents are found in the collection
        print('No documents found in SalesSummary collection.');
      }
    }).catchError((error) {
      print('Error fetching document: $error');
    });
  }
}
