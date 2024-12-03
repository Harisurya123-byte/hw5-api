import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int? selectedCategoryId;
  int numberOfQuestions = 10;
  String selectedDifficulty = "easy";
  String selectedQuestionType = "multiple";

  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse('https://opentdb.com/api_category.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = List<Map<String, dynamic>>.from(data['trivia_categories']);
        });
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Setup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Number of Questions"),
            DropdownButton<int>(
              value: numberOfQuestions,
              items: [5, 10, 15, 20].map((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (int? value) {
                setState(() {
                  numberOfQuestions = value!;
                });
              },
            ),
            const SizedBox(height: 16.0),

            const Text("Select Category"),
            categories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : DropdownButton<int>(
                    value: selectedCategoryId,
                    hint: const Text("Select a Category"),
                    items: categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setState(() {
                        selectedCategoryId = value!;
                      });
                    },
                  ),
            const SizedBox(height: 16.0),

            const Text("Select Difficulty"),
            DropdownButton<String>(
              value: selectedDifficulty,
              items: ["easy", "medium", "hard"].map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.capitalize()),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 16.0),

            const Text("Select Question Type"),
            DropdownButton<String>(
              value: selectedQuestionType,
              items: ["multiple", "boolean"].map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.capitalize()),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedQuestionType = value!;
                });
              },
            ),
            const SizedBox(height: 32.0),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedCategoryId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select a category")),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          categoryId: selectedCategoryId!,
                          numberOfQuestions: numberOfQuestions,
                          difficulty: selectedDifficulty,
                          questionType: selectedQuestionType,
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Start Quiz"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension for capitalizing strings
extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
