import 'package:http/http.dart' as http;
import 'dart:convert';

class TomatoApi {
  static Future<Map<String, dynamic>> fetchData() async {
    try {
      // Make the HTTP GET request
      final response = await http.get(Uri.parse('https://marcconrad.com/uob/banana/api.php'));

      // Check if the HTTP response is successful
      if (response.statusCode == 200) {
        // Parse the response body as JSON
        final data = jsonDecode(response.body);
        print('API Response: $data'); // Debug: Print API response

        // Validate the presence of required keys
        if (data is Map<String, dynamic> && data.containsKey('question') && data.containsKey('solution')) {
          final question = data['question'] ?? '';
          final solution = data['solution'] ?? 0;

          // Additional validation for "question" and "solution" values
          if (question is String && solution is int) {
            return {
              'question': question,
              'solution': solution,
            };
          } else {
            throw Exception('Invalid data types for "question" or "solution".');
          }
        } else {
          throw Exception('Invalid API Response: Missing "question" or "solution".');
        }
      } else {
        // Handle non-200 HTTP responses
        throw Exception('Failed to load data: HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Log and rethrow the exception for further handling
      print('Error fetching API data: $e');
      throw Exception('Failed to load data');
    }
  }
}
