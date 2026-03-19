import 'package:flutter/material.dart';
import 'package:flutter_application_1/buttons/mycard.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 3,

        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),

            child: Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Mycards(
                  cardTitle: "This is a card",
                  localimage: "assets/greenary.jpg",
                  imgreurl:
                      "https://images.pexels.com/photos/36211085/pexels-photo-36211085.jpeg ",
                ),
                Mycards(
                  cardTitle: "This is the second",
                  imgreurl: "assets/wheat.jpg",
                  localimage: "assets/bedafarm.jpg",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
