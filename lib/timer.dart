class Timer {
  var timer = {"pomodoro": 25, "interval": 5,};

  int pomodoro = 25;
  int interval = 5;
  int longBreakInterval = 4;
  String mode = "pomodoro";
  Map<String, int> remainingTime = {"total": 25 * 60};

  int getModeTime(String mode) {
    if (mode == "pomodoro") {
      return 25;
    }
    if (mode == "interval") {
      return 5;
    }
    return 0;
  }
}
