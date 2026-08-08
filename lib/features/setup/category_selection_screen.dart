import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/particles_background.dart';
import '../../data/api/questions_api.dart';
import '../../models/category_model.dart';
import '../../core/widgets/topic_image.dart';
import '../../game/screens/game_grid_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen>
    with SingleTickerProviderStateMixin {
  final List<CategoryModel> _categories = QuestionsApi.categories;
  final TextEditingController _team1Controller = TextEditingController(text: 'الفريق الأول');
  final TextEditingController _team2Controller = TextEditingController(text: 'الفريق الثاني');

  late final AnimationController _entranceController;

  int get selectedCount => _categories.where((c) => c.isSelected).length;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + _categories.length * 80),
    )..forward();
  }

  @override
  void dispose() {
    _team1Controller.dispose();
    _team2Controller.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _toggleCategory(CategoryModel category) {
    setState(() {
      if (!category.isSelected && selectedCount >= 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يمكنك اختيار 6 مواضيع فقط للمسابقة'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      category.isSelected = !category.isSelected;
    });
  }

  void _startGame() {
    if (selectedCount != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى اختيار 6 مواضيع للبدء (المحدد حالياً: $selectedCount)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final selectedCategories = _categories.where((c) => c.isSelected).toList();

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => GameGridScreen(
          selectedCategories: selectedCategories,
          team1Name: _team1Controller.text.trim().isEmpty ? 'الفريق الأول' : _team1Controller.text.trim(),
          team2Name: _team2Controller.text.trim().isEmpty ? 'الفريق الثاني' : _team2Controller.text.trim(),
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'إِعْدَادُ الْمُسَابَقَةِ',
          style: TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: ParticlesBackground(particleCount: 18)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Teams Setup Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'أَسْمَاءُ الْفَرِيقَيْنِ',
                          style: TextStyle(color: AppColors.goldPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _team1Controller,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  labelText: 'الفريق 1',
                                  labelStyle: const TextStyle(color: AppColors.teamRed),
                                  filled: true,
                                  fillColor: AppColors.cardBg,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppColors.teamRed),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppColors.teamRed, width: 2),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _team2Controller,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  labelText: 'الفريق 2',
                                  labelStyle: const TextStyle(color: AppColors.teamBlue),
                                  filled: true,
                                  fillColor: AppColors.cardBg,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppColors.teamBlue),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppColors.teamBlue, width: 2),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Categories Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'اخْتَر 6 مَوَاضِيعَ لِلْمُسَابَقَةِ:',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedCount == 6 ? AppColors.success.withOpacity(0.2) : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selectedCount == 6 ? AppColors.success : AppColors.goldPrimary,
                          ),
                        ),
                        child: Text(
                          '$selectedCount / 6',
                          style: TextStyle(
                            color: selectedCount == 6 ? AppColors.success : AppColors.goldPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'كُلُّ مَوْضُوعٍ فِيهِ 6 أَسْئِلَةٍ: 3 لِكُلِّ فَرِيقٍ يَخْتَارُ مِنْهَا',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Categories Grid with staggered entrance animation + themed color badges
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.9,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];

                      final start = (index / _categories.length).clamp(0.0, 1.0);
                      final end = ((index + 1) / _categories.length).clamp(0.0, 1.0);
                      final itemAnim = CurvedAnimation(
                        parent: _entranceController,
                        curve: Interval(start, end, curve: Curves.easeOutBack),
                      );

                      return AnimatedBuilder(
                        animation: itemAnim,
                        builder: (context, child) {
                          return Opacity(
                            opacity: itemAnim.value.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: 0.8 + 0.2 * itemAnim.value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: InkWell(
                          onTap: () => _toggleCategory(cat),
                          borderRadius: BorderRadius.circular(18),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: cat.isSelected ? cat.color.withOpacity(0.15) : AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: cat.isSelected ? cat.color : AppColors.border,
                                width: cat.isSelected ? 2 : 1,
                              ),
                              boxShadow: cat.isSelected
                                  ? [BoxShadow(color: cat.color.withOpacity(0.3), blurRadius: 14)]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 46,
                                  height: 46,
                                  child: Stack(
                                    children: [
                                      TopicImage(
                                        query: cat.imageQuery,
                                        fallbackIcon: cat.icon,
                                        color: cat.color,
                                        height: 46,
                                        borderRadius: BorderRadius.circular(23),
                                      ),
                                      if (cat.isSelected)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.black.withOpacity(0.35),
                                            ),
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.check_circle_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    cat.title,
                                    style: TextStyle(
                                      color: cat.isSelected ? cat.color : AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  // Confirm Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: selectedCount == 6 ? AppColors.goldGradient : null,
                      color: selectedCount == 6 ? null : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: selectedCount == 6
                          ? [
                              BoxShadow(
                                color: AppColors.goldPrimary.withOpacity(0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: selectedCount == 6 ? _startGame : null,
                      child: Text(
                        'انْطِلاَقُ اللَّعْبَةِ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: selectedCount == 6 ? Colors.black : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
