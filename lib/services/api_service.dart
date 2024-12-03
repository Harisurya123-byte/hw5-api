import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Fetches questions from the Open Trivia API
  static Future<List<Map<String, dynamic>>> fetchQuestions({
    required int categoryId,
    required int numberOfQuestions,
    required String difficulty,
    required String questionType,
  }) async {
    final url =
        "https://opentdb.com/api.php?amount=$numberOfQuestions&category=$categoryId&difficulty=$difficulty&type=$questionType";

    // HTTP GET request
    final response = await http.get(Uri.parse(url));

    // Check response status
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['response_code'] == 0) {
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception("No questions available for the selected parameters.");
      }
    } else {
      throw Exception("Failed to fetch questions from API.");
    }
  }
}
