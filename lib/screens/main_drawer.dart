import 'package:SeekAssist/screens/help_screen.dart';
import 'package:SeekAssist/screens/settings_screen.dart';
import 'package:SeekAssist/screens/share_screen.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,

            ),
            child: Text('SeekAssist'),
          ),
          ListTile(
            title: const Text('Help'),
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => HelpScreen() ));

              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => SettingsScreen() ));


              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('Share'),
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => ShareScreen() ));

              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('Feedback'),
            onTap: () {
              Navigator.pop(context);



              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }
}
