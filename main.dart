import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countdown Timer UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 56, 56, 56)),
        useMaterial3: true,
      ),
      home: const CountdownTimerPage(title: 'Countdown Timer'),
    );
  }
}

class CountdownTimerPage extends StatefulWidget {
  const CountdownTimerPage({super.key, required this.title});
  final String title;
  

  @override
  State<CountdownTimerPage> createState() => _CountdownTimerPageState();
}

class _CountdownTimerPageState extends State<CountdownTimerPage> with SingleTickerProviderStateMixin {

  // default countdown values when starting the program
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 30; 

    final TextEditingController _hoursController = TextEditingController();
    final TextEditingController _minutesController = TextEditingController();
    final TextEditingController _secondsController = TextEditingController();

bool _isTimerRunning = false; // to check if the timer is running or not


// hourglass animation function here 
  late AnimationController _hourglassController;

  @override
  void initState() {
    super.initState();
    _hourglassController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _hourglassController.stop(); // paused animation when starting the program
  }

  @override
  void dispose() {
    _hourglassController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
    
  }
  // avoid leaking resources by disposing of the controller when the widget is removed from the widget tree

Timer?_countdownTimer;

// Start countdown
void _startCountdown() {
  if (_countdownTimer != null) return; // Prevent multiple timers
  _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    setState(() {
      if (_hours == 0 && _minutes == 0 && _seconds == 0) {
        _isTimerRunning = false; 
        timer.cancel();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Time's Up!"),
              content: const Text('The countdown has finished.'),
              actions: [
          TextButton(
            onPressed: () {
              _hoursController.clear();
              _minutesController.clear();
              _secondsController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),

          ),
              ],
            );
          },
        );
        _countdownTimer = null;
        _hourglassController.stop();
        _hourglassController.reset(); // completely stop hourglass animation and reset position
      } else {
        if (_seconds > 0) {
          _seconds--;
        } else {
          if (_minutes > 0) {
            _minutes--;
            _seconds = 59;
          } else {
            if (_hours > 0) {
              _hours--;
              _minutes = 59;
              _seconds = 59;
            }
          }
        }
      }
    });
  });
}
void _pauseCountdown() { // Pause countdown and hourglass
  _countdownTimer?.cancel();
  _countdownTimer = null;
}
void _resetCountdown() { // Reset countdown and hourglass 
  _pauseCountdown();
  setState(() {
    _hours = 0;
    _minutes = 0;
    _seconds = 0;
  });
}

// functions to allow user to increment time values for hour, minute, and second
  void _incrementHour() {
    setState(() {
      if (_hours < 24) {
        _hours++;
      } else {
        _hours = 0;
        //_incrementMin();
      }
    });
  }
    void _incrementMin() {
      setState(() {

        if (_minutes < 59) {
          _minutes++;
        } else {
          _minutes = 0;
          _incrementHour();
        }
      });
    }
      void _incrementSec() {
    setState(() {

      if (_seconds < 59) {
        _seconds++;
      } else {
        _seconds = 0;
        _incrementMin();
      }
    });
  }

    // functions to allow user to decrement time values for hour, minute, and second
    void _decrementHour() {
    setState(() {
      if (_hours > 0) 
        {_hours--;}
    });
  }
      void _decrementMin() {
    setState(() {
      if (_minutes > 0)  
        {_minutes--;}
    });
  }
      void _decrementSec() {
    setState(() {
      if (_seconds > 0) 
        {_seconds--;}
    });
  }
  
  // transform int values to string for UI display.
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  // padleft is used to transfrom int values less than two digits to two digits by putting 0 before the int value
  // for example 1 becomes 01, 2 becomes 02, and so on
  @override
  Widget build(BuildContext context) {
    String timerDisplay =
        "${twoDigits(_hours)}:${twoDigits(_minutes)}:${twoDigits(_seconds)}";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Color.fromARGB(132, 216, 216, 226),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // all content sa center 
          children: [
            // hourglass icon with rotation for animation only
            // default flutter icon used for hourglass
            // can be replaced with any hourglass icon from the internet
            RotationTransition(
              turns: _hourglassController,
              child: const Icon(
                Icons.hourglass_full_rounded,
                size: 150, // adjust size if needed
                color: Color.fromARGB(255, 48, 48, 48),
              ),
            ),
            const SizedBox(height: 20),

            // these buttons allow user to add values to the timer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              TimeAdjustButton(
                icon: Icons.arrow_upward,
                onPressed: _incrementHour,
                isEnabled: !_isTimerRunning,
              ),
              SizedBox(width: 5),
              TimeAdjustButton(
                icon: Icons.arrow_upward,
                onPressed: _incrementMin,
                isEnabled: !_isTimerRunning,
              ),
              SizedBox(width: 5),
              TimeAdjustButton(
                icon: Icons.arrow_upward,
                onPressed: _incrementSec,
                isEnabled: !_isTimerRunning,
              ),
              ],
            ),
            
            const SizedBox(height: 5),

            // Timer Display
            // display time values in HH:MM:SS format
            Text(
              timerDisplay,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 5),
            // buttons allow user to subtract values to the timer
            // not yet functional but decrements for the sake of UI
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TimeAdjustButton(icon: Icons.arrow_downward, onPressed: _decrementHour, isEnabled: !_isTimerRunning),
                SizedBox(width: 5),
                TimeAdjustButton(icon: Icons.arrow_downward, onPressed: _decrementMin, isEnabled: !_isTimerRunning),
                SizedBox(width: 5),
                TimeAdjustButton(icon: Icons.arrow_downward, onPressed: _decrementSec, isEnabled: !_isTimerRunning),
              ],
            ),

            const SizedBox(height: 10),

            // custom time input
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 35,
                  child: TextField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'HRS'),
                    readOnly: _isTimerRunning,
                    onChanged: (value) {
                      setState(() {
                        int parsed = int.tryParse(value) ?? 0;
                        if (parsed > 24) {
                          parsed = 24;
                          _hoursController.selection = TextSelection.fromPosition( // <-- Keep cursor at end
                            TextPosition(offset: _hoursController.text.length),
                          );
                        }
                        _hours = parsed;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 35,
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'MIN'),
                    readOnly: _isTimerRunning,
                    onChanged: (value) {
                      setState(() {
                        int parsed = int.tryParse(value) ?? 0;
                        if (parsed > 59) {
                          _hours = parsed ~/ 60; // Convert to hours if over 59
                          if (_hours > 24) {_hours = 24 ;} // Limit to 24 hours
                          parsed = parsed % 60; // Keep minutes within 0-59
                          _minutesController.selection = TextSelection.fromPosition( // <-- Keep cursor at end
                            TextPosition(offset: _minutesController.text.length),
                          );
                        }
                        _minutes = parsed;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 35,
                  child: TextField(
                    controller: _secondsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'SEC'),
                    readOnly: _isTimerRunning,
                    onChanged: (value) {
                      setState(() {
                        int parsed = int.tryParse(value) ?? 0;
                        if (parsed > 59) {
                          _minutes = parsed ~/ 60; // Convert to minutes if over 59
                          if (_minutes > 59) {
                            _hours = _minutes ~/ 60;
                            _minutes = _minutes % 60; // Keep minutes within 0-59
                            if (_hours > 24) {
                              _hours = 24; // Limit to 24 hours
                            }
                          }
                          parsed = parsed % 60; // Keep seconds within 0-59
                          _secondsController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _secondsController.text.length),
                          );
                        }
                        _seconds = parsed;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (_hours == 0 && _minutes == 0 && _seconds == 0) {
                      return;
                    }
                    setState(() {
                      _isTimerRunning = true;
                    });
                    _startCountdown();
                    _hourglassController.repeat();
                    }, // start hourglass function
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
                const SizedBox(width: 5),
                ElevatedButton.icon(
                  onPressed: () {
                    _hourglassController.stop(); // pause hourglass function
                    _pauseCountdown(); // pause countdown function
                  },
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                ),
                const SizedBox(width: 5),
                ElevatedButton.icon(
                  onPressed: () {
                    _hourglassController.stop();
                    _hourglassController.reset(); // reset hourglass function
                    _resetCountdown(); // reset countdown function
                        _hoursController.clear();
                        _minutesController.clear();
                        _secondsController.clear();
                        _isTimerRunning = false; // reset timer running state
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom button widget for time adjustment
class TimeAdjustButton extends StatelessWidget {
  final IconData icon;
    final VoidCallback onPressed;
    final bool isEnabled;

    const TimeAdjustButton({
      super.key,
      required this.icon,
      required this.onPressed,
      this.isEnabled = true,
    });

    @override
    Widget build(BuildContext context) {
      return ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        child: Icon(icon),
      );
    }

}
