import 'dart:convert'; // For base64 decoding if needed
import 'package:flutter/material.dart';
import 'dart:io' show Platform; // To check platform
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../Tomato_api/tomato_api.dart';

/// A Flutter widget representing the Tomato Classic game.
class TomatoClassic extends StatefulWidget {
  @override
  _TomatoClassicState createState() => _TomatoClassicState();
}

/// The state class for the TomatoClassic widget.
class _TomatoClassicState extends State<TomatoClassic> {
  String question = ''; // Should contain a valid image URL
  int solution = 0;
  int guess = 0;
  int points = 0;
  int round = 1;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  /// Validates if a URL returns a valid image.
  Future<bool> isValidImageUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200 &&
          (response.headers['content-type']?.startsWith('image/') ?? false);
    } catch (e) {
      print('Error validating image URL: $e');
      return false;
    }
  }

  /// Fetches data for a new question from the Tomato API.
  Future<void> fetchData() async {
    try {
      final data = await TomatoApi.fetchData();
      final imageUrl = data['question']; // Assuming this is the image URL

      if (kIsWeb) {
        // Skip validation for web environment due to CORS restrictions
        setState(() {
          question = imageUrl;
          solution = data['solution'];
        });
      } else {
        // Validate image URL for other platforms
        final isValid = await isValidImageUrl(imageUrl);
        setState(() {
          question = isValid ? imageUrl : '';
          solution = data['solution'];
        });
        if (!isValid) {
          print('Invalid image URL: $imageUrl');
        }
      }
    } catch (e) {
      print('Failed to fetch data: $e');
      setState(() {
        question = '';
      });
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
                  if (round == 10) {
                    endGame();
                  } else {
                    setState(() {
                      round += 1;
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
    setState(() {
      points -= 2;
    });
    fetchData();
  }

  /// Ends the game and displays the final score.
  void endGame() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Total Points: $points'),
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
      round = 1;
      points = 0;
    });
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tomato Classic'),
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
                        Text('5. You can skip a question, but you will lose 2 points.'),
                        Text('6. The game consists of 10 rounds.'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Round: $round',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            Text(
              'Points: $points',
              style: TextStyle(fontSize: 24),
            ),
            question.isNotEmpty
                ? Image.network(
              question,
              errorBuilder: (context, error, stackTrace) {
                return Text('Unable to load image.');
              },
            )
                : Text('Loading image or invalid URL.'),
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
