import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: TextStyle(color: Colors.black),
          shadowColor: Colors.amber,
          backgroundColor: Colors.green,
          title: Text('HELP')
      ),
    );
  }
}
