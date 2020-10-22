import 'package:flutter/material.dart';
import 'dart:async';

//Would use MediaQuery for ensuring respectable sizes of elements on different devices
//Initialize variables, could also create seperate dart file for handling Time variable declaration & methods
class Time {
  final int minutes;
  final int seconds;
  final int centiseconds;

  Time({
    this.minutes,
    this.seconds,
    this.centiseconds,
  });
}

class Dependencies {
  final List<ValueChanged<Time>> timerListeners = <ValueChanged<Time>>[];
  final Stopwatch stopwatch = new Stopwatch();
  final int timerRefresh = 10;
  final TextStyle kTimeText = const TextStyle(fontSize: 94.0);
}

class TimerPage extends StatefulWidget {
  TimerPage({Key key}) : super(key: key);

  TimerPageState createState() => new TimerPageState();
}

class TimerPageState extends State<TimerPage> {
  final Dependencies dependencies = new Dependencies();

  void rightButtonPressed() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        print("${dependencies.stopwatch.elapsedMilliseconds}");
      } else {
        dependencies.stopwatch.reset();
      }
    });
  }

  void leftButtonPressed() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        dependencies.stopwatch.stop();
      } else {
        dependencies.stopwatch.start();
      }
    });
  }

  Widget stopwatchButtons(String text, VoidCallback callback) {
    //normally create a constant file for all pre-defined values good for DRY implementation
    TextStyle roundTextStyle =
        const TextStyle(fontSize: 20.0, color: Colors.black);
    return new RaisedButton(
        padding: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: Colors.white)),
        //Reactive Colour buttons based on simple bool check
        color: dependencies.stopwatch.isRunning ? Colors.red : Colors.green,
        child: new Text(text, style: roundTextStyle),
        onPressed: callback);
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Expanded(
          child: new TimerText(dependencies: dependencies),
        ),
        new Expanded(
          flex: 0,
          child: new Padding(
            padding: const EdgeInsets.only(bottom: 350.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                stopwatchButtons(
                    dependencies.stopwatch.isRunning ? "Pause" : "Start",
                    leftButtonPressed),
                stopwatchButtons("Reset", rightButtonPressed),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TimerText extends StatefulWidget {
  TimerText({this.dependencies});

  final Dependencies dependencies;

  TimerTextState createState() =>
      new TimerTextState(dependencies: dependencies);
}

class TimerTextState extends State<TimerText> {
  TimerTextState({this.dependencies});

  final Dependencies dependencies;
  Timer timer;
  int milliseconds;

  @override
  void initState() {
    // * A count-down timer that can be configured to fire once or repeatedly.
    timer = new Timer.periodic(
        // 1000 microseconds in a centisecond
        new Duration(microseconds: dependencies.timerRefresh * 100),
        callback);
    super.initState();
  }

  //Reset timer state
  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  void callback(Timer timer) {
    if (milliseconds != dependencies.stopwatch.elapsedMilliseconds) {
      milliseconds = dependencies.stopwatch.elapsedMilliseconds;
      final int centiseconds = (milliseconds / 10).truncate();
      final int seconds = (centiseconds / 100).truncate();
      final int minutes = (seconds / 60).truncate();
      final Time elapsedTime = new Time(
        centiseconds: centiseconds,
        seconds: seconds,
        minutes: minutes,
      );
      for (final listener in dependencies.timerListeners) {
        listener(elapsedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //Required to display seconds on refresh/rebuild
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new RepaintBoundary(
          child: new SizedBox(
            height: 100.0,
            child: new DisplayTime(dependencies: dependencies),
          ),
        ),
      ],
    );
  }
}

class DisplayTime extends StatefulWidget {
  DisplayTime({this.dependencies});

  final Dependencies dependencies;

  DisplayTimeState createState() =>
      new DisplayTimeState(dependencies: dependencies);
}

class DisplayTimeState extends State<DisplayTime> {
  DisplayTimeState({this.dependencies});

  final Dependencies dependencies;
  int minutes = 0;
  int seconds = 0;
  int centiseconds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  //Ticker logic
  void onTick(Time elapsed) {
    if (elapsed.minutes != minutes ||
        elapsed.seconds != seconds ||
        elapsed.centiseconds != centiseconds) {
      setState(() {
        minutes = elapsed.minutes;
        seconds = elapsed.seconds;
        centiseconds = elapsed.centiseconds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String centisecondsLabel = (centiseconds % 100).toString().padLeft(2, '0');
    String secondsLabel = (seconds % 60).toString().padLeft(2, '0');
    String minutesLabel = (minutes % 60).toString().padLeft(2, '0');

    return Container(
        child: new Text('$minutesLabel:$secondsLabel.$centisecondsLabel',
            style: dependencies.kTimeText));
  }
}
