import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final DateTime newYear = DateTime(DateTime.now().year + 1, 1, 1);

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        body: Center(
          child: CountdownTimer(newYear: newYear),
        ),
      ),
    );
  }
}

class CountdownTimer extends StatefulWidget {
  final DateTime newYear;

  const CountdownTimer({super.key, required this.newYear});

  @override
  // ignore: library_private_types_in_public_api
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  int _start = 0;
  List<String> phrases = [
    "Check out later",
    "Come back tomorrow",
    "See you soon"
  ];
  String _currentPhrase = "";

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start++;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _start = DateTime.now().difference(widget.newYear).inSeconds;
    var rng = Random();
    var index = rng.nextInt(phrases.length);
    _currentPhrase = phrases[index];
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Modified twoDigits function
  String twoDigits(int n, [int length = 2]) =>
      n.toString().padLeft(length, "0");

  // Modified build method
  @override
  Widget build(BuildContext context) {
    int hours = _start.abs() ~/ 3600;
    int minutes = (_start.abs() % 3600) ~/ 60;
    int seconds = _start.abs() % 60;

    String twoDigitHours = twoDigits(hours);
    String twoDigitMinutes = twoDigits(minutes);
    String twoDigitSeconds = twoDigits(seconds);

    if (DateTime.now().day == 31 && DateTime.now().month == 12) {
      return Text(
        "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds",
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      );
    } else if (DateTime.now().day == 1 && DateTime.now().month == 1) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double maxWidth = constraints.maxWidth * 0.75;
          double maxHeight = constraints.maxHeight * 0.75;
          return Image.asset(
            'assets/icon/icon.png',
            width: maxWidth,
            height: maxHeight,
            fit: BoxFit.contain, // or BoxFit.cover depending on your needs
          );
        },
      );
    } else {
      return Text(
        _currentPhrase,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      );
    }
  }
}
