import 'package:ewj_account_manage/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NameScreen extends StatefulWidget {

  final bool isFirstTime;

  const NameScreen({super.key,  this.isFirstTime = true});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  String name = "";
  bool isLoading = true;

  @override
  void initState() {
    if(widget.isFirstTime){
      loadData();
    }
    else{
      isLoading = false;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(

          child: isLoading ? Column(
            children: [
              Image.asset("assets/easyWearLogo.jpg"),
              SizedBox(height: 10,),
              CircularProgressIndicator(),
            ],
          ) : Padding(

            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Who are you"),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Short Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (name.trim() == "") {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please enter your name")));
                      return;
                    }

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('name', name);
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return HomeScreen(name: name);
                        }));
                  },
                  child: Text("Save"),

                ),
              ],
            ),
          )),
    );
  }

  void loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final n = prefs.getString('name');
    if (n == null) {
      setState(() {
        isLoading = false;
      });
    }
    else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return HomeScreen(name: n);
        }
        ),
      );
    }
  }
}
