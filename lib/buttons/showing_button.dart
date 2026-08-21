import 'package:flutter/material.dart';
import 'package:flutter_practice/buttons/button_icon.dart';
//import 'package:flutter_practice/product_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowingButton extends StatefulWidget {
  const ShowingButton({super.key});

  @override
  State<ShowingButton> createState() => _ShowingButtonState();
}

class _ShowingButtonState extends State<ShowingButton> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "WELCOME TO RATERS",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text("Movie lovers network", style: TextStyle(color: Colors.grey)),

            SizedBox(height: 40),
            ButtonIcon(
              onTap: () {

                //Navigator.pushNamed(context, AppRoute.display, arguments: 'Manjan');
              },
              icon: FontAwesomeIcons.gauge,
              text: "Google",
              color: Colors.red,
            ),

            ButtonIcon(
              onTap: () {
               // var productId = "pd1243";

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ProductScreen(productId: productId),
                //   ),
                // );
                context.go('/product');
              },

              icon: FontAwesomeIcons.facebook,
              text: "Facebook",
              color: Colors.blue,
            ),

            ButtonIcon(
              onTap: () {},
              icon: FontAwesomeIcons.google,
              text: "Google",
              color: Colors.red,
            ),

            ButtonIcon(
              icon: FontAwesomeIcons.maxcdn,
              text: "Via Email",
              color: Colors.blueGrey,
              onTap: () {},
            ),

            SizedBox(height: 20),

            Text(
              "Continue as Guest",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),

            SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  children: [
                    TextSpan(text: "By registration you agree to "),
                    TextSpan(
                      text: "Terms of Use",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(text: " and "),
                    TextSpan(
                      text: "Privacy Policy",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
