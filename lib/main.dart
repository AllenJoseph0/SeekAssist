import 'dart:io';
import 'package:SeekAssist/screens/splashscreen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
// import 'package:alan_voice/alan_voice.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

// _MyHomePageState() {
//   /// Init Alan Button with project key from Alan AI Studio
//   AlanVoice.addButton(
//       "3ffc15af71da3f6c1b6df6d9f830c5b82e956eca572e1d8b807a3e2338fdd0dc/stage");

//   /// Handle commands from Alan AI Studio
//   AlanVoice.onCommand.add((command) {
//     debugPrint("got new command ${command.toString()}");
//   });
// }
