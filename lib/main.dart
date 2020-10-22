import 'package:flutter/material.dart';
import 'timer_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      //First thing every OCD dev must do.
      debugShowCheckedModeBanner: false,
      //////////////////////////////////
      title: 'Stopwatch',
      theme: new ThemeData(
        //Reactive background Green for Start / Orange for stop - however not possible due to limits with my StateManagement approach
        primarySwatch: Dependencies().stopwatch.isRunning
            ? Colors.green
            : Colors.orange,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text("Stopwatch"),
      ),
      body: new Container(
        //Reactive background Green for Start / Orange for stop - however not possible due to limits with my StateManagement approach
      color: Colors.orange,
          child: new TimerPage(
      )),
    );
  }
}
