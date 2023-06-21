// import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class helppage extends StatefulWidget {
//   @override
//   _helpPageState createState() => _helpPageState();
// }
import 'package:flutter/material.dart';

class helppage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the Help Page!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Here you can find useful information and instructions on how to use our app.\n To capture -Click the shutter Button\n  \t \t  \t \t  \t  \t \t   -  Give voice command(capture image)  \n  \n Upload image  -Click upload button ',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'If you have any questions or need further assistance, please feel free to contact our support team. \n Annu Mary Abraham \n annukba@gmail.com ',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            // Add more Text widgets or other content as needed
          ],
        ),
      ),
    );
  }
}
