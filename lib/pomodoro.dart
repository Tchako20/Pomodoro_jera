import 'dart:async';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Pomodoro",
      debugShowCheckedModeBanner: false,
      home: PomodoroHome(),
    );
  }
}

class PomodoroHome extends StatefulWidget {
  const PomodoroHome({Key? key}) : super(key: key);

  @override
  State<PomodoroHome> createState() => _PomodoroHomeState();
}

class _PomodoroHomeState extends State<PomodoroHome> {
  static const String pomodoro = "pomodoro";
  static const String pause = "longBreak";

  String mainButtonAction = "start";
  String focus = "Mantenha o foco você consegue";
  String message = "Olá, seja muito bem vindo(a)";
  String rest =
      "Pressione Start para iniciar o contador\n que ao chegar ao fim reinicia outra tarefa";

  var timerDetails = {
    "pomodoro": 25,
    "longBreak": 5,
    "Interval": 5,
    "session": 0,
    "mode": "pomodoro",
    "remainingTime": {"total": 25 * 60, "minute": 25, "second": 0}
  };
  late Timer interval = Timer(const Duration(seconds: 1), () {});

  String minutes = "25";
  String seconds = "00";

  void switchMode(String mode) {
    stopTimer();
    timerDetails["mode"] = mode;
    int time = (timerDetails[mode] ?? 0) as int;
    timerDetails["remainingTime"] = {
      "total": time * 60,
      "minute": timerDetails[mode],
      "second": 0
    };

    setState(() {
      if (mode == pomodoro) {
        message = focus;
      } else {
        message = rest;
      }
    });

    updateClock();
  }

  void updateClock() {
    Map remainingTime = timerDetails["remainingTime"] as Map;
    setState(() {
      minutes = "${remainingTime["minute"]}".padLeft(2, "0");
      seconds = "${remainingTime["second"]}".padLeft(2, "0");
    });
  }

  void startTimer() {
    Map remainingTime = timerDetails["remainingTime"] as Map;
    int total = remainingTime["total"];
    var endTime = DateTime.now().add(Duration(seconds: total));

    setState(() {
      mainButtonAction = "stop";
    });

    interval = Timer.periodic(const Duration(seconds: 1), (timer) {
      timerDetails["remainingTime"] = getRemainingTime(endTime);
      updateClock();

      Map remainingTime = timerDetails["remainingTime"] as Map;
      int total = remainingTime["total"];
      if (total <= 0) {
        interval.cancel();
        //  audioPlayer.play();
        HapticFeedback.vibrate();

        switch (timerDetails["mode"]) {
          case pomodoro:
            int timerSession = timerDetails["session"] as int;
            int interval = timerDetails["Interval"] as int;

            if (timerSession % interval == 0) {
              switchMode(pause);
            }
            break;
          default:
            switchMode(pomodoro);
        }
        startTimer();
      }
    });
  }

  void stopTimer() {
    interval.cancel();
    setState(() {
      mainButtonAction = "start";
    });
  }

  Map<String, int> getRemainingTime(DateTime endTime) {
    DateTime currentTime = DateTime.now();
    Duration different = endTime.difference(currentTime);

    int total = different.inSeconds;
    int minute = different.inMinutes;
    int second = total % 60;

    return {"total": total, "minute": minute, "second": second};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffd9d9d9),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Center(
            child: Text(
          "App Pomodoro",
          style: TextStyle(color: Colors.black),
        )),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PomodoroButton(
                        callback: () {
                          switchMode(pomodoro);
                        },
                        buttonText: "Pomodoro",
                        buttonColor: Colors.black),
                    PomodoroButton(
                        callback: () {
                          switchMode(pause);
                        },
                        buttonText: "Intervalo",
                        buttonColor: Colors.black),
                  ],
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18,
                      letterSpacing: 2),
                ),
                Text(
                  "$minutes:$seconds",
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 80),
                ),
                ElevatedButton(
                    onPressed: () {
                      if (mainButtonAction == "start") {
                        startTimer();
                      } else {
                        stopTimer();
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.redAccent),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20))),
                    child: Text(
                      mainButtonAction,
                      style: const TextStyle(fontSize: 28, color: Colors.black),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PomodoroButton extends StatelessWidget {
  VoidCallback callback;
  String buttonText;
  Color buttonColor;
  PomodoroButton(
      {Key? key,
      required this.callback,
      required this.buttonText,
      required this.buttonColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(buttonColor),
        ),
        onPressed: callback,
        child: Text(
          buttonText,
          style: const TextStyle(color: Colors.white),
        ));
  }
}
