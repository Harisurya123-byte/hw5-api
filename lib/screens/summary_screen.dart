import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final int score;
  final int total;
  final List<Map<String, dynamic>> questions;
  final List<String> userAnswers;

  const SummaryScreen({
    Key? key,
    required this.score,
    required this.total,
    required this.questions,
    required this.userAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Score: $score / $total",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final correctAnswer = question['correct_answer'];
                  final userAnswer = userAnswers[index];
                  return ListTile(
                    title: Text(question['question']),
                    subtitle: Text(
                      userAnswer == correctAnswer
                          ? "Your answer: $userAnswer (Correct)"
                          : "Your answer: $userAnswer (Incorrect)\nCorrect answer: $correctAnswer",
                    ),
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to setup screen
                },
                child: const Text("Retake Quiz"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
