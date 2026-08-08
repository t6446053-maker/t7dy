class QuestionModel {
  final String id;
  final String category;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final int points;

  final String ownerTeam;

  final String? imageQuery;

  bool isAnswered;

  QuestionModel({
    required this.id,
    required this.category,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.points,
    this.ownerTeam = 'A',
    this.imageQuery,
    this.isAnswered = false,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      questionText: map['questionText'] ?? map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: (map['correctOptionIndex'] as num?)?.toInt() ?? 0,
      points: (map['points'] as num?)?.toInt() ?? 100,
      ownerTeam: map['ownerTeam'] ?? 'A',
      imageQuery: map['imageQuery'] as String?,
      isAnswered: map['isAnswered'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'points': points,
      'ownerTeam': ownerTeam,
      'imageQuery': imageQuery,
      'isAnswered': isAnswered,
    };
  }
}
