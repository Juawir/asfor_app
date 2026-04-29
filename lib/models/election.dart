class Candidate {
  final String userId;
  final String name;
  final String division;
  final String visiMisi;
  int votes;

  Candidate({
    required this.userId,
    required this.name,
    required this.division,
    this.visiMisi = '',
    this.votes = 0,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'division': division,
    'visiMisi': visiMisi,
    'votes': votes,
  };

  factory Candidate.fromJson(Map<String, dynamic> json) => Candidate(
    userId: json['userId'] ?? '',
    name: json['name'] ?? '',
    division: json['division'] ?? '',
    visiMisi: json['visiMisi'] ?? '',
    votes: json['votes'] ?? 0,
  );
}

enum ElectionStatus { active, completed }

class Election {
  final String id;
  final String title;
  final List<Candidate> candidates;
  final List<String> voterIds; // user IDs who already voted
  ElectionStatus status;
  final DateTime createdAt;

  Election({
    required this.id,
    required this.title,
    required this.candidates,
    this.voterIds = const [],
    this.status = ElectionStatus.active,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isActive => status == ElectionStatus.active;
  bool get isCompleted => status == ElectionStatus.completed;
  int get totalVotes => candidates.fold(0, (s, c) => s + c.votes);

  bool hasVoted(String userId) => voterIds.contains(userId);

  Candidate? get winner {
    if (candidates.isEmpty) return null;
    final sorted = List<Candidate>.from(candidates)..sort((a, b) => b.votes.compareTo(a.votes));
    return sorted.first;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'candidates': candidates.map((c) => c.toJson()).toList(),
    'voterIds': voterIds,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Election.fromJson(Map<String, dynamic> json) => Election(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    candidates: (json['candidates'] as List?)?.map((c) => Candidate.fromJson(c)).toList() ?? [],
    voterIds: List<String>.from(json['voterIds'] ?? []),
    status: json['status'] == 'completed' ? ElectionStatus.completed : ElectionStatus.active,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
  );
}
