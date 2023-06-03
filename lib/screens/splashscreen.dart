import 'dart:async';

import 'package:SeekAssist/main.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Container(
    //     height: (MediaQuery.of(context).size.height),
    //     width: (MediaQuery.of(context).size.width),
    //     decoration: BoxDecoration(
    //         image: DecorationImage(
    //       image: AssetImage('assets\images\bg.png'),
    //       fit: BoxFit.cover,
    //     )));
    Timer(
        const Duration(seconds: 04),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          height: (MediaQuery.of(context).size.height),
          width: (MediaQuery.of(context).size.width),
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('assets/images/bggreens.png'),
            fit: BoxFit.cover,
          )),
              // child: Text('SeekAssist',
              //     textScaleFactor: 2,
              //     style: GoogleFonts.openSans(
              //       textStyle: TextStyle(color: Colors.green),
              //       fontWeight: FontWeight.w500,
              //     ))

          ),
        ),

    );
  }
}
