import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/particles_background.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../../data/api/questions_api.dart';
import '../../models/category_model.dart';
import '../../models/question_model.dart';
import '../../models/team_model.dart';
import '../widgets/question_view_dialog.dart';

class GameGridScreen extends StatefulWidget {
  final List<CategoryModel> selectedCategories;
  final String team1Name;
  final String team2Name;

  const GameGridScreen({
    super.key,
    required this.selectedCategories,
    required this.team1Name,
    required this.team2Name,
  });

  @override
  State<GameGridScreen> createState() => _GameGridScreenState();
}

class _GameGridScreenState extends State<GameGridScreen> with TickerProviderStateMixin {
  late TeamModel team1;
  late TeamModel team2;

  final GlobalKey<ConfettiOverlayState> _confettiKey = GlobalKey<ConfettiOverlayState>();

  late Map<String, List<QuestionModel>> categoryQuestions;

  late final AnimationController _entranceController;

  bool _gameEnded = false;

  @override
  void initState() {
    super.initState();
    team1 = TeamModel(id: 't1', name: widget.team1Name, score: 0);
    team2 = TeamModel(id: 't2', name: widget.team2Name, score: 0);

    categoryQuestions = {};
    for (var cat in widget.selectedCategories) {
      categoryQuestions[cat.title] = QuestionsApi.getQuestionsForCategory(cat.title);
    }

    _entranceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.selectedCategories.length * 100),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  List<QuestionModel> _teamQuestions(String categoryTitle, String team) {
    final all = categoryQuestions[categoryTitle] ?? [];
    final list = all.where((q) => q.ownerTeam == team).toList();
    list.sort((a, b) => a.points.compareTo(b.points));
    return list;
  }

  void _adjustScore(TeamModel team, int delta) {
    setState(() {
      team.score += delta;
      if (team.score < 0) team.score = 0;
    });
  }

  bool get _allQuestionsAnswered {
    for (final questions in categoryQuestions.values) {
      for (final q in questions) {
        if (!q.isAnswered) return false;
      }
    }
    return true;
  }

  void _checkGameOver() {
    if (_gameEnded || !_allQuestionsAnswered) return;
    _gameEnded = true;
    _confettiKey.currentState?.burst();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _showWinnerDialog();
    });
  }

  void _showWinnerDialog() {
    String winnerText;
    Color winnerColor;

    if (team1.score > team2.score) {
      winnerText = 'الْفَائِزُ: ${team1.name} 🏆';
      winnerColor = AppColors.teamRed;
    } else if (team2.score > team1.score) {
      winnerText = 'الْفَائِزُ: ${team2.name} 🏆';
      winnerColor = AppColors.teamBlue;
    } else {
      winnerText = 'تَعَادُلٌ حَاسِمٌ بَيْنَ الْفَرِيقَيْنِ! 🤝';
      winnerColor = AppColors.accentGold;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.7, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.goldPrimary, width: 2),
              boxShadow: [
                BoxShadow(color: AppColors.goldPrimary.withOpacity(0.3), blurRadius: 30, spreadRadius: 4),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_rounded, size: 80, color: AppColors.accentGold),
                const SizedBox(height: 16),
                const Text(
                  'انْتَهَتِ الْمُبَارَاةُ!',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  winnerText,
                  style: TextStyle(color: winnerColor, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildScoreRow(team1.name, team1.score, AppColors.teamRed),
                      const Divider(color: AppColors.border, height: 20),
                      _buildScoreRow(team2.name, team2.score, AppColors.teamBlue),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text(
                      'الْعَوْدَةُ لِلرَّئِيسِيَّةِ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(String name, int score, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        Text('$score نُقْطَة', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _openQuestion(QuestionModel question, CategoryModel category, TeamModel team, Color teamColor) {
    if (question.isAnswered) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuestionViewDialog(
        question: question,
        answeringTeam: team,
        teamColor: teamColor,
        categoryIcon: category.icon,
        categoryColor: category.color,
        onCorrectAnswer: () => _confettiKey.currentState?.burst(),
        onScoreUpdated: () {
          setState(() {}); 
          _checkGameOver();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiOverlay(
      key: _confettiKey,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'شَاشَةُ التَّحَدِّي الْكُبْرَى',
            style: TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: ParticlesBackground(particleCount: 20)),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(child: _buildTeamCard(team1, AppColors.teamRed)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTeamCard(team2, AppColors.teamBlue)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 12),
                  const Text(
                    'كُلُّ فَرِيقٍ يَخْتَارُ سُؤَالًا مِنْ أَسْئِلَتِهِ الثَّلَاثَةِ فِي كُلِّ مَوْضُوعٍ',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: widget.selectedCategories.length,
                      itemBuilder: (context, index) {
                        final cat = widget.selectedCategories[index];
                        final teamAQuestions = _teamQuestions(cat.title, 'A');
                        final teamBQuestions = _teamQuestions(cat.title, 'B');

                        final start = (index / widget.selectedCategories.length).clamp(0.0, 1.0);
                        final end = ((index + 1) / widget.selectedCategories.length).clamp(0.0, 1.0);
                        final itemAnim = CurvedAnimation(
                          parent: _entranceController,
                          curve: Interval(start, end, curve: Curves.easeOutCubic),
                        );

                        return AnimatedBuilder(
                          animation: itemAnim,
                          builder: (context, child) {
                            return Opacity(
                              opacity: itemAnim.value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, 24 * (1 - itemAnim.value.clamp(0.0, 1.0))),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: cat.color.withOpacity(0.4), width: 1.2),
                              boxShadow: [
                                BoxShadow(color: cat.color.withOpacity(0.12), blurRadius: 16),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [cat.color, cat.color.withOpacity(0.6)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: cat.color.withOpacity(0.4), blurRadius: 10),
                                        ],
                                      ),
                                      child: Icon(cat.icon, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        cat.title,
                                        style: TextStyle(
                                          color: cat.color,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                _buildTeamQuestionsRow(
                                  teamLabel: team1.name,
                                  teamColor: AppColors.teamRed,
                                  questions: teamAQuestions,
                                  onTap: (q) => _openQuestion(q, cat, team1, AppColors.teamRed),
                                ),
                                const SizedBox(height: 10),

                                _buildTeamQuestionsRow(
                                  teamLabel: team2.name,
                                  teamColor: AppColors.teamBlue,
                                  questions: teamBQuestions,
                                  onTap: (q) => _openQuestion(q, cat, team2, AppColors.teamBlue),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamQuestionsRow({
    required String teamLabel,
    required Color teamColor,
    required List<QuestionModel> questions,
    required void Function(QuestionModel) onTap,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: teamColor),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  teamLabel,
                  style: TextStyle(color: teamColor, fontSize: 11, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Row(
            children: questions.map((q) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: q.isAnswered ? AppColors.cardBg : teamColor.withOpacity(0.15),
                      disabledBackgroundColor: AppColors.cardBg,
                      foregroundColor: teamColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: q.isAnswered ? AppColors.border : teamColor,
                          width: q.isAnswered ? 1 : 1.5,
                        ),
                      ),
                    ),
                    onPressed: q.isAnswered ? null : () => onTap(q),
                    child: Text(
                      q.isAnswered ? 'تمت' : '${q.points}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: q.isAnswered ? AppColors.textSecondary : teamColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard(TeamModel team, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor, width: 2),
        boxShadow: [
          BoxShadow(color: accentColor.withOpacity(0.2), blurRadius: 12),
        ],
      ),
      child: Column(
        children: [
          Text(
            team.name,
            style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: team.score),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) => Text(
              '$value',
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => _adjustScore(team, -100),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.remove, size: 18, color: AppColors.error),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => _adjustScore(team, 100),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.add, size: 18, color: AppColors.success),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
