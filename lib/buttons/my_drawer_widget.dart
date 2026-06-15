import 'package:flutter/material.dart';

class MyWiget extends StatelessWidget {
  const MyWiget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Column(
              children: [CircleAvatar(), Text("manjanshahi@gmail.com")],
            ),
          ),
          ListTile(
            title: Text("setting"),
            leading: Icon(Icons.settings),
            subtitle: Text("data"),
          ),
          ListTile(
            title: Text("profile"),
            leading: Icon(Icons.person),
            subtitle: Text("data"),
          ),
          ListTile(
            title: Text("mark"),
            leading: Icon(Icons.mode_sharp),
            subtitle: Text("data"),
          ),
        ],
      ),
    );
  }
}
