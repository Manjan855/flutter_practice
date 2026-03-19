import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_models.dart';
//import 'package:flutter_application_1/route/AppRoutes.dart';
import 'package:flutter_application_1/route/app_router.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key,});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _emailTextEditingController =
      TextEditingController();

  String? _name;

  String? _address;

  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("My First App")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            key: _form,
            spacing: 15,
            children: [
              TextFormField(
                onSaved: (newvalue) {
                  _name = newvalue;
                  print('Name is $_name');
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),

                  hintText: "Please enter the name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              TextFormField(
                controller: _emailTextEditingController,
                onSaved: (newvalue) {
                  print("New value is $newvalue");
                },
                decoration: InputDecoration(
                  hint: Text("email"),
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "please enter your email";
                  } else if (!value.contains("@")) {
                    return 'Enter you correct email';
                  }
                  return null;
                },
              ),
              TextFormField(
                onSaved: (newvalue) {
                  _address = newvalue;
                  print('Address $_address');
                },
                decoration: InputDecoration(
                  hint: Text("address"),
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    _form.currentState!.save();
                    var name = "_name";
                    var email = "_emailTextEditingController.value.text";
                    var address = "_address";
                    print("Print final value of form $name, $address, $email");
                    UserModels user = UserModels(
                      address: _address!,
                      name: _name!,
                      email: email,
                    );
                    context.push(AppRoute.kyc, extra: user);
                  }
                },
                child: Text("Press Me"),
              ),
              SizedBox(height: 20),
              Text("Name"),
              SizedBox(height: 20),
              Text("Address"),
              SizedBox(height: 20),
              Text("College"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Text("Login"),
                    SizedBox(width: 20),
                    Icon(Icons.settings),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF868868),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Text(
                    "It is  gray color",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight(600)),
                  ),
                ),
              ),

              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  height: 30,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 157, 37, 111),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Text(
                    "It is  pink color",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight(600)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  height: 30,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 17, 174, 75),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Text(
                    "It is  green color",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight(600)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Container(
                        height: 30,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 222, 230, 123),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Text(
                          "It is  yellowish color",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight(600),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 134, 142, 29),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Text(
                    "It is  gray color",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight(600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
