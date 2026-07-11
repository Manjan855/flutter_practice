import 'package:flutter/material.dart';

class NewClass extends StatefulWidget {
  const NewClass({super.key});

  @override
  State<NewClass> createState() => _NewClassState();
}

class _NewClassState extends State<NewClass> {
  final List<int> number = [1, 2, 3, 4, 5, 6, 7];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("List Items")),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: number.length,
              itemBuilder: (context, index) {
                return Text(number[index].toString());
              },
            ),
          ),

          SizedBox(
            height: 300,
            child: ListView.separated(
              itemBuilder: (context, index) {
                return Text(number[index].toString());
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemCount: number.length,
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      "Item $index",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
