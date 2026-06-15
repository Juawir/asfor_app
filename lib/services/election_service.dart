import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/election.dart';
import 'api_config.dart';
class ElectionService {



  /// Get current election (active or latest completed)
  Future<Election?> getElection() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/elections/current'),
        headers: await ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data == null) return null;
        return Election.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting election: $e');
      return null;
    }
  }

  /// Create a new election (Super Admin only)
  Future<String?> createElection(String title, List<Candidate> candidates) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/elections'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode({
          'title': title,
          'candidates': candidates.map((c) => {
            'userId': c.userId,
          }).toList(),
        }),
      );
      debugPrint('CREATE ELECTION RESPONSE: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 201) return null;
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('CREATE ELECTION ERROR: $e');
      return 'Exception: $e';
    }
  }

  /// Cast a vote for a candidate
  Future<String?> castVote(String candidateId, String voterId) async {
    try {
      final election = await getElection();
      if (election == null) return 'Tidak ada pemilihan aktif';
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/elections/${election.id}/vote'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode({
          'candidateId': candidateId,
        }),
      );

      if (response.statusCode == 200) return null; // success

      final data = jsonDecode(response.body);
      return data['message'] ?? 'Gagal memberikan suara';
    } catch (e) {
      debugPrint('Error casting vote: $e');
      return 'Terjadi kesalahan koneksi';
    }
  }

  /// Check if user has voted
  Future<bool> hasVoted(String userId) async {
    final election = await getElection();
    if (election == null) return false;
    return election.hasVoted(userId);
  }

  /// End the election (Super Admin only)
  Future<bool> endElection(String electionId) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/elections/$electionId/end'),
        headers: await ApiConfig.getHeaders(),
      );
      debugPrint('END ELECTION: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error ending election: $e');
      return false;
    }
  }

  /// Delete the election (Super Admin only)
  Future<bool> deleteElection(String electionId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/elections/$electionId'),
        headers: await ApiConfig.getHeaders(),
      );
      debugPrint('DELETE ELECTION: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting election: $e');
      return false;
    }
  }
}
