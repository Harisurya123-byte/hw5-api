import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizScreen extends StatefulWidget {
  final int categoryId;
  final int numberOfQuestions;
  final String difficulty;
  final String questionType;

  const QuizScreen({
    Key? key,
    required this.categoryId,
    required this.numberOfQuestions,
    required this.difficulty,
    required this.questionType,
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> questions = [];
  int currentIndex = 0;
  int score = 0;
  bool isLoading = true;

  Timer? _timer;
  int _timeRemaining = 15;
  List<String> currentOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Clean up the timer when the screen is disposed
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    try {
      final url =
          'https://opentdb.com/api.php?amount=${widget.numberOfQuestions}&category=${widget.categoryId}&difficulty=${widget.difficulty}&type=${widget.questionType}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          questions = data['results'];
          isLoading = false;
          _prepareOptions();
          _startTimer(); // Start the timer after loading the questions
        });
      } else {
        throw Exception("Failed to fetch questions.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _prepareOptions() {
    final currentQuestion = questions[currentIndex];
    final options = List<String>.from(currentQuestion['incorrect_answers']);
    options.add(currentQuestion['correct_answer']);
    options.shuffle(); // Shuffle once for the current question
    setState(() {
      currentOptions = options;
    });
  }

  void _startTimer() {
    _timeRemaining = 15;
    _timer?.cancel(); // Cancel any previous timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          timer.cancel();
          _handleTimeOut();
        }
      });
    });
  }

  void _handleTimeOut() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Time's up!")),
    );
    _nextQuestion(isCorrect: false);
  }

  void _nextQuestion({required bool isCorrect}) {
    if (isCorrect) {
      score++;
    }

    setState(() {
      if (currentIndex < questions.length - 1) {
        currentIndex++;
        _prepareOptions(); // Prepare options for the next question
        _startTimer(); // Restart the timer for the next question
      } else {
        _endQuiz();
      }
    });
  }

  void _endQuiz() {
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Quiz Completed"),
          content: Text("Your Score: $score/${questions.length}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to setup screen
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: const Center(child: Text("No questions found. Try a different setup.")),
      );
    }

    final currentQuestion = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Question ${currentIndex + 1}/${questions.length}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentQuestion['question'],
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            Text("Time Remaining: $_timeRemaining seconds",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20.0),
            ..._buildOptions(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions() {
    return currentOptions.map((option) {
      return ElevatedButton(
        onPressed: () {
          _timer?.cancel(); // Stop the timer when an answer is selected
          final isCorrect = option == questions[currentIndex]['correct_answer'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isCorrect ? "Correct!" : "Incorrect!")),
          );
          _nextQuestion(isCorrect: isCorrect);
        },
        child: Text(option),
      );
    }).toList();
  }
}
