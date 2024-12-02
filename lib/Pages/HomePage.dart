import 'package:flutter/material.dart';
import 'package:tomato/game_modes/TimeChallenge.dart';
import 'package:tomato/game_modes/TomatoClassic.dart';
import 'LoginPage.dart';

/// Flutter widget representing the home page of the Banana Game application.
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banana Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 150,
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                // Navigate to the TomatoClassic game mode
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TomatoClassic()),
                );
              },
              child: Text(
                'Classic',
                style: TextStyle(fontSize: 20),
              ),
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size(250, 60)),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to the TimeChallenge game mode
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimeChallenge()),
                );
              },
              child: Text(
                'Time Challenge',
                style: TextStyle(fontSize: 20),
              ),
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size(250, 60)),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to the LoginPage and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false,
                );
              },
              child: Text(
                'Logout',
                style: TextStyle(fontSize: 20),
              ),
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size(250, 60)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}