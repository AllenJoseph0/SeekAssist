import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'help_page.dart';

class SettingsDrawer extends StatefulWidget {
  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isSoundEffectsEnabled = true;

  void toggleSoundEffects() async {
    setState(() {
      isSoundEffectsEnabled = !isSoundEffectsEnabled;
    });

    //   if (isSoundEffectsEnabled) {
    //     // Enable sound effects
    //     int result = await audioPlayer.resume();
    //     if (result == 1) {
    //       // Playback resumed successfully
    //     } else {
    //       // Failed to resume playback
    //     }
    //   } else {
    //     // Disable sound effects
    //     int result = await audioPlayer.pause();
    //     if (result == 1) {
    //       // Playback paused successfully
    //     } else {
    //       // Failed to pause playback
    //     }
    //   }
    // }
    if (isSoundEffectsEnabled) {
      // Enable sound effects
      await audioPlayer.resume();
    } else {
      // Disable sound effects
      await audioPlayer.pause();
    }
  }

  void goToHelpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => helppage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
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
            title: Text('Sound Effects'),
            trailing: Switch(
              value: isSoundEffectsEnabled,
              onChanged: (value) {
                toggleSoundEffects();
              },
            ),
          ),
          ListTile(
            title: Text('Help'),
            onTap: () {
              goToHelpPage();
            },
          ),
        ],
      ),
    );
  }
}
