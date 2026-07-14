import 'package:flutter/material.dart';
//import 'package:flutter_practice/screens/main_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int isTotal = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Text("Press Me"),
      ),
      appBar: AppBar(title: Text("Product Screen"), centerTitle: true),
      //drawer: MyWiget(),
      body: Column(
        children: [
          Center(child: Text("MY sum is $isTotal")),
          ElevatedButton(
            onPressed: () {
              increment();
            },
            child: Text("Increment"),
          ),
          Text('$isTotal'),
          ElevatedButton(
            onPressed: () {
              decrement();
            },
            child: Text("decrement"),
          ),
          Text(
            "My Name is Manjan Shahi. I am a developer who can developer mobile app",
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Text(
            "Computer Engineer",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight(500),
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  void increment() {
    setState(() {
      isTotal++;
    });
  }

  void decrement() {
    setState(() {
      isTotal--;
    });
  }
}
