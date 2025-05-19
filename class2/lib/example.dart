
import 'package:flutter/material.dart';

class ExampleClass extends StatefulWidget {
  const ExampleClass({super.key});

  @override
  State<ExampleClass> createState() => _ExampleClassState();
}

class _ExampleClassState extends State<ExampleClass> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Hello "),
      ),
      body: Padding(
        padding:  EdgeInsets.only(left:20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello im in a column "),
            Text("Hello im in a column "),
            Text("Hello im in a column "),
            Text("Hello im in a column "),
            Text("Hello im in a column "),
            Text("Hello im in a column "),
            Text("Hello im in a column "),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.fingerprint),
                Icon(Icons.fingerprint),
                Icon(Icons.fingerprint),
              ],
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    ));
  }
}
