import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:confetti/confetti.dart';

void main() {
  // Lock screen orientation to portrait mode only on mobile devices
  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final DateTime newYear = DateTime(DateTime.now().year + 1, 1, 1);

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    WakelockPlus.enable();
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
  late ConfettiController _controller;

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
    _controller = ConfettiController(duration: const Duration(seconds: 10));
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  String twoDigits(int n, [int length = 2]) =>
      n.toString().padLeft(length, "0");

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
      _controller.play(); // Start the confetti effect
      return Stack(
        children: [
          Positioned(
            top: -100,
            left: MediaQuery.of(context).size.width / 2,
            child: ConfettiWidget(
              confettiController: _controller,
              //blastDirection: pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 10,
              colors: const [
                Colors.red,
                Color(0xFFFFD700), // Gold color
                Colors.green
              ], // New Year's Day theme colors
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double maxWidth = constraints.maxWidth * 0.75;
                double maxHeight = constraints.maxHeight * 0.75;
                return Image.asset(
                  'assets/icon/icon.png',
                  width: maxWidth,
                  height: maxHeight,
                  fit:
                      BoxFit.contain, // or BoxFit.cover depending on your needs
                );
              },
            ),
          ),
        ],
      );
    } else {
      return Text(
        _currentPhrase,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      );
    }
  }
}
