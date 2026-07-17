import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practice/app_theme/app_text_style.dart';
import 'package:flutter_practice/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_practice/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_practice/models/user_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
//import 'package:flutter_practice/route/AppRoutes.dart';
// import 'package:flutter_practice/core/router/app_router.dart';
// import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  bool _loading = false;

  String? _name;

  String? _address;
  String? _college;
  Future<void> signOut() async {
    setState(() => _loading = true);
    final result = await ref.read(authRepositoryProvider).signOut();
    if (!mounted) return;
    setState(() => _loading = false);
    result.fold(
      (l) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.message))),
      (User) => context.go('/login'),
    );
  }

  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("My First App")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _form,
            child: Column(
              spacing: 15,
              children: [
                TextFormField(
                  onSaved: (newvalue) {
                    _name = newvalue;
                    print('Name is $_name');
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    label: Text("Name", style: AppTextStyle.mediumText),
                    hintText: "Please enter the name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                kTextFormField(
                  hintText: "enter the second email",
                  emailTextEditingController: _emailTextEditingController,
                  prefixIcon: Icon(Icons.email),
                  label: 'second email',
                ),
                kTextFormField(
                  hintText: "enter the email",
                  emailTextEditingController: _emailTextEditingController,
                  prefixIcon: Icon(Icons.hotel),
                  label: 'email',
                ),
                TextFormField(
                  onSaved: (newvalue) {
                    _address = newvalue;
                    print('Address $_address');
                  },

                  decoration: InputDecoration(
                    hint: Text("address", style: AppTextStyle.smallText),
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
                      var name = _name;
                      var email = _emailTextEditingController.value.text;
                      var address = _address;
                      var college = _college;
                      print(
                        "Print final value of form $name, $address, $email",
                      );
                      UserModels user = UserModels(
                        address: _address!,
                        name: _name!,
                        email: email,
                        college: _college!,
                      );
                      // context.push(AppRoute.kyc, extra: user);
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
                _loading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: signOut,
                        child: Row(
                          children: [
                            Text("LogOut"),
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
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight(600),
                      ),
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
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight(600),
                      ),
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
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight(600),
                      ),
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
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight(600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class kTextFormField extends StatelessWidget {
  const kTextFormField({
    super.key,
    required TextEditingController emailTextEditingController,
    required this.hintText,
    required this.prefixIcon,
    required this.label,
  }) : _emailTextEditingController = emailTextEditingController;

  final TextEditingController _emailTextEditingController;
  final String label;
  final String hintText;
  final Icon prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _emailTextEditingController,
      onSaved: (newvalue) {
        print("New value is $newvalue");
      },
      decoration: InputDecoration(
        label: Text(label),
        hintText: '',
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "please enter your email";
        } else if (value.contains("@gmail.com")) {
          return 'Enter you correct email';
        }
        return null;
      },
    );
  }
}
