import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:tomato/Tomato_api/tomato_api.dart';

/// A Flutter widget representing the Time Challenge game.
class TimeChallenge extends StatefulWidget {
  @override
  _TimeChallengeState createState() => _TimeChallengeState();
}

/// The state class for the TimeChallenge widget.
class _TimeChallengeState extends State<TimeChallenge> {
  String question = '';
  int solution = 0;
  int guess = 0;
  int points = 0;
  int questions = 1; // Changed from round to questions
  final controller = TextEditingController();
  int remainingTime = 120; // 2 minutes in seconds
  late DateTime startTime;

  @override
  void initState() {
    super.initState();
    fetchData();
    startTime = DateTime.now();
    startTimer();
  }

  /// Fetches data for a new question from the Tomato API.
  Future<void> fetchData() async {
    try {
      final data = await TomatoApi.fetchData();
      setState(() {
        question = data['question'];
        solution = data['solution'];
      });
    } catch (e) {
      print('Failed to fetch data: $e');
    }
  }

  /// Checks the user's guess and updates points accordingly.
  void checkGuess() {
    if (guess == solution) {
      setState(() {
        points += 10;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Congratulations!'),
            content: Text('Your guess is correct!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.clear();
                  if (questions == 10) {
                    endGame();
                  } else {
                    setState(() {
                      questions += 1;
                    });
                    fetchData();
                  }
                },
                child: Text('Next Question'),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        points -= 5;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sorry!'),
            content: Text('Your guess is incorrect. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.clear();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  /// Skips the current question and fetches a new one.
  void skipQuestion() {
    fetchData();
    controller.clear();
  }

  /// Ends the game and displays the final score.
  void endGame() {
    int elapsedTime = DateTime.now().difference(startTime).inSeconds;
    remainingTime -= elapsedTime;
    if (remainingTime < 0) {
      remainingTime = 0;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Column(
            children: [
              Text('Total Points: $points'),
              Text('Remaining Time: ${remainingTime}s'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  /// Resets the game to its initial state.
  void resetGame() {
    setState(() {
      questions = 1;
      points = 0;
      remainingTime = 120;
    });
    fetchData();
    startTime = DateTime.now();
    startTimer();
  }

  /// Starts the timer that counts down the remaining time.
  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    Timer.periodic(oneSecond, (timer) {
      if (remainingTime <= 0) {
        timer.cancel();
        endGame();
      } else {
        setState(() {
          remainingTime -= 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Challenge'),
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Rules'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1. You will be shown an image of a tomato.'),
                        Text('2. You have to guess the number of the tomato.'),
                        Text('3. You will get 10 points for each correct guess.'),
                        Text('4. You will lose 5 points for each incorrect guess.'),
                        Text('5. You can skip a question.'),
                        Text('6. The game has a time limit of 2 minutes (120 seconds).'),
                        Text('7. Your score will be calculated at the end.'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.skip_next),
            onPressed: skipQuestion,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.timer),
                SizedBox(width: 8),
                Text('Time Left: ${remainingTime}s'),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Question: $questions', // Changed from Round to Question
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 16),
                Text(
                  'Points: $points',
                  style: TextStyle(fontSize: 24),
                ),
                Image.network(question),
                SizedBox(height: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildButton(1),
                        buildButton(2),
                        buildButton(3),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildButton(4),
                        buildButton(5),
                        buildButton(6),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildButton(7),
                        buildButton(8),
                        buildButton(9),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildButton(0),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an elevated button for the user to make a guess.
  ElevatedButton buildButton(int value) {
    return ElevatedButton(
      onPressed: () {
        guess = value;
        checkGuess();
      },
      child: Text('$value'),
    );
  }
}