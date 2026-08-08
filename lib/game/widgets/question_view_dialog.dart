import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/topic_image.dart';
import '../../models/question_model.dart';
import '../../models/team_model.dart';

class QuestionViewDialog extends StatefulWidget {
  final QuestionModel question;

  final TeamModel answeringTeam;
  final Color teamColor;
  final IconData categoryIcon;
  final Color categoryColor;

  final VoidCallback onScoreUpdated;
  final VoidCallback? onCorrectAnswer;

  const QuestionViewDialog({
    super.key,
    required this.question,
    required this.answeringTeam,
    required this.teamColor,
    required this.categoryIcon,
    required this.categoryColor,
    required this.onScoreUpdated,
    this.onCorrectAnswer,
  });

  @override
  State<QuestionViewDialog> createState() => _QuestionViewDialogState();
}

class _QuestionViewDialogState extends State<QuestionViewDialog> with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _startSeconds = 60;
  bool _showAnswer = false;
  int? _selectedOptionIndex;

  late final AnimationController _entranceController;
  late final Animation<double> _entranceScale;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _entranceScale = CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startSeconds > 0) {
        setState(() => _startSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resetTimer() {
    setState(() => _startSeconds = 60);
    _startTimer();
  }

  void _markAnswered({required bool correct}) {
    widget.question.isAnswered = true;
    if (correct) {
      widget.answeringTeam.score += widget.question.points;
      widget.onCorrectAnswer?.call();
    }
    widget.onScoreUpdated();
    Navigator.pop(context);
  }

  void _skipQuestion() {
    widget.question.isAnswered = true;
    widget.onScoreUpdated();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _entranceScale,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: widget.teamColor, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 30, spreadRadius: 5),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.categoryColor.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(widget.categoryIcon, color: widget.categoryColor, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.question.category,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.goldPrimary),
                      ),
                      child: Text(
                        '${widget.question.points} نُقْطَةٍ',
                        style: const TextStyle(
                          color: AppColors.goldPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Answering team badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.teamColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: widget.teamColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_rounded, color: widget.teamColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'سُؤَالُ فَرِيقِ: ${widget.answeringTeam.name}',
                        style: TextStyle(color: widget.teamColor, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Timer Section
                Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: _startSeconds / 60),
                      duration: const Duration(milliseconds: 400),
                      builder: (context, value, _) => SizedBox(
                        width: 76,
                        height: 76,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 6,
                          color: _startSeconds > 15 ? AppColors.goldPrimary : AppColors.error,
                          backgroundColor: AppColors.cardBg,
                        ),
                      ),
                    ),
                    Text(
                      '$_startSeconds',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _startSeconds > 15 ? AppColors.textPrimary : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh, color: AppColors.goldPrimary),
                  tooltip: 'إعادة العداد 60 ثانية',
                ),
                const SizedBox(height: 12),

                if (widget.question.imageQuery != null) ...[
                  TopicImage(
                    query: widget.question.imageQuery,
                    fallbackIcon: widget.categoryIcon,
                    color: widget.categoryColor,
                    height: 150,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  const SizedBox(height: 16),
                ],

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    widget.question.questionText,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                ...List.generate(widget.question.options.length, (index) {
                  final isCorrect = index == widget.question.correctOptionIndex;
                  final isSelected = index == _selectedOptionIndex;

                  Color optionBorder = AppColors.border;
                  Color optionBg = AppColors.cardBg;

                  if (_showAnswer) {
                    if (isCorrect) {
                      optionBorder = AppColors.success;
                      optionBg = AppColors.success.withOpacity(0.2);
                    } else if (isSelected) {
                      optionBorder = AppColors.error;
                      optionBg = AppColors.error.withOpacity(0.2);
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: InkWell(
                      onTap: () => setState(() {
                        _selectedOptionIndex = index;
                        _showAnswer = true;
                      }),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: optionBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: optionBorder, width: _showAnswer && isCorrect ? 2 : 1),
                        ),
                        child: Text(
                          widget.question.options[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _showAnswer && isCorrect ? AppColors.success : AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 12),

                Text(
                  'هَلْ أَجَابَ فَرِيقُ ${widget.answeringTeam.name} إِجَابَةً صَحِيحَةً؟',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _markAnswered(correct: true),
                        icon: const Icon(Icons.check_rounded, color: Colors.white),
                        label: const Text(
                          'إِجَابَةٌ صَحِيحَةٌ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _markAnswered(correct: false),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        label: const Text(
                          'إِجَابَةٌ خَاطِئَةٌ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                TextButton(
                  onPressed: _skipQuestion,
                  child: const Text(
                    'تَجَاوُزُ السُّؤَالِ دُونَ نِقَاطٍ',
                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
