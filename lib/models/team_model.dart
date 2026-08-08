class TeamModel {
  final String id;
  final String name;
  int score;

  TeamModel({
    required this.id,
    required this.name,
    this.score = 0,
  });
}
