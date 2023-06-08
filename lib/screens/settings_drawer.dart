import 'package:flutter/material.dart';

class SettingsDrawer extends StatefulWidget {
  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Setting 1'),
            onTap: () {
              // Handle setting 1 tap
            },
          ),
          ListTile(
            title: Text('Setting 2'),
            onTap: () {
              // Handle setting 2 tap
            },
          ),
          // Add more ListTile widgets for additional settings
        ],
      ),
    );
  }
}
