import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/election.dart';

class ElectionService {
  static const _electionKey = 'asfor_election';

  /// Get current election (active or latest completed)
  Future<Election?> getElection() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_electionKey);
    if (data == null) return null;
    try {
      return Election.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  /// Save election to local storage
  Future<void> _saveElection(Election election) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_electionKey, jsonEncode(election.toJson()));
  }

  /// Create a new election (Super Admin only)
  Future<bool> createElection(String title, List<Candidate> candidates) async {
    final election = Election(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      candidates: candidates,
      voterIds: [],
      status: ElectionStatus.active,
    );
    await _saveElection(election);
    return true;
  }

  /// Cast a vote for a candidate
  Future<String?> castVote(String candidateId, String voterId) async {
    final election = await getElection();
    if (election == null) return 'Tidak ada pemilihan aktif';
    if (!election.isActive) return 'Pemilihan sudah berakhir';
    if (election.hasVoted(voterId)) return 'Anda sudah memberikan suara';

    final candidateIndex = election.candidates.indexWhere((c) => c.userId == candidateId);
    if (candidateIndex == -1) return 'Kandidat tidak ditemukan';

    election.candidates[candidateIndex].votes++;
    election.voterIds.add(voterId);

    await _saveElection(election);
    return null; // success
  }

  /// Check if user has voted
  Future<bool> hasVoted(String userId) async {
    final election = await getElection();
    if (election == null) return false;
    return election.hasVoted(userId);
  }

  /// End the election (Super Admin only)
  Future<bool> endElection() async {
    final election = await getElection();
    if (election == null) return false;
    election.status = ElectionStatus.completed;
    await _saveElection(election);
    return true;
  }

  /// Delete the election (Super Admin only, for creating new one)
  Future<bool> deleteElection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_electionKey);
    return true;
  }
}
