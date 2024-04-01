import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductListTile extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductListTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Assuming `product['createdAt']` is a DateTime object
    if(product['createdAt'] == null){
      return SizedBox();
    }
    DateTime createdAt = product['createdAt'].toDate();

// Define the date and time format
    final dateFormat = DateFormat('dd MMM yy');
    final timeFormat = DateFormat('hh:mm a');

    String formattedDate = dateFormat.format(createdAt);
    String formattedTime = timeFormat.format(createdAt);
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(right: 8.0),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(Icons.energy_savings_leaf_outlined),
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${product['seller']}",
                style: TextStyle(fontSize: 15.0, color: Colors.grey.shade600),
              ),
              Text(
                "${product['name'].toString().toUpperCase()}",
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(
                height: 16.0,
              ),
              Row(
                children: [
                  Icon(Icons.shopping_cart_checkout),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    "x ${product['quantity']} ",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ],
              )
            ],
          )),
          Center(
            child: Column(
              children: [
                Text(
                  "${product['price']}",
                  style: TextStyle(fontSize: 20.0, color: Colors.blue.shade600),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "$formattedDate\n$formattedTime",
                  style: TextStyle(fontSize: 15.0, color: Colors.grey.shade600),
                )
              ],
            ),
          )
        ],
      ),
    ));
  }
}
