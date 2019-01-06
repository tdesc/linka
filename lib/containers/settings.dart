import 'package:flutter/material.dart';
import 'package:linka/globals.dart' as globals;

class SettingsScreen extends StatefulWidget {
  
  SettingsScreen();

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Number of cards ${globals.gridSize.round()}'),
                Slider(
                  value: globals.gridSize,
                  min: 1,
                  max: 4,
                  divisions: 3,
                  label: '${globals.gridSize.round()}',
                  onChanged: (double value) {
                    setState(() {
                      print("new value $value");
                      setState(() {
                        globals.gridSize = value;                      
                      }); 
                    });
                  },
                ),
          
              ],
            ),
          ])
      ),
    );
  }
}