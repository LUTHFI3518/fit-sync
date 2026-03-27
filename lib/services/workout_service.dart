import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/storage/storage_service.dart';

class WorkoutService {
  static const String baseUrl =
      "https://fit-sync-backend-cvhb.onrender.com/api/workout";

  Future<Map<String, String>> _headers() async {
    final storage = await StorageService.getInstance();
    final token = storage.getAuthToken();
    if (token == null) throw Exception("No auth token found");
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<Map<String, dynamic>> getJourney() async {
    final response = await http.get(
      Uri.parse("$baseUrl/journey"),
      headers: await _headers(),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw Exception(data["error"] ?? data["message"] ?? "Failed to load journey");
  }

  Future<Map<String, dynamic>> getTodayWorkout() async {
    final response = await http.get(
      Uri.parse("$baseUrl/today"),
      headers: await _headers(),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw Exception(data["error"] ?? data["message"] ?? "Failed to load today's workout");
  }

  /// Marks a single exercise as complete.
  /// Returns `{ allDone: bool, ... }` from the backend.
  Future<Map<String, dynamic>> completeExercise({
    required String exerciseId,
    required int repsCompleted,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/complete-exercise"),
      headers: await _headers(),
      body: jsonEncode({
        "exerciseId": exerciseId,
        "repsCompleted": repsCompleted,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw Exception(data["error"] ?? data["message"] ?? "Failed to complete exercise");
  }

  Future<Map<String, dynamic>> getExerciseInfo(String name) async {
    final response = await http.get(
      Uri.parse("$baseUrl/exercise-info/${Uri.encodeComponent(name)}"),
      headers: await _headers(),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw Exception(data["error"] ?? "Failed to load exercise info");
  }
}
