import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  int counter = 0;

  StreamController<int> counterController = StreamController.broadcast();

  AppState() {
    counterController.stream.listen((value) {
      setState(() {
        counter = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fun with Streams',
        home: Column(
          children: [
            Text('$counter'),
            ElevatedButton(
                child: Text('Press me!'),
                onPressed: () => counterController.add(counter + 1))
          ],
        ));
  }
}
