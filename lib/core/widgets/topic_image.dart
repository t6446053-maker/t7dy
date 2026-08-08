import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/services/image_service.dart';
import '../theme/app_colors.dart';

class TopicImage extends StatelessWidget {
  final String? query;
  final IconData fallbackIcon;
  final Color color;
  final double height;
  final BorderRadius borderRadius;

  const TopicImage({
    super.key,
    required this.query,
    required this.fallbackIcon,
    required this.color,
    this.height = 140,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    final q = query?.trim() ?? '';

    if (q.isEmpty) {
      return _fallback();
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: FutureBuilder<String?>(
        future: ImageService.instance.fetchImageUrl(q),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _loading();
          }
          final url = snapshot.data;
          if (url == null || url.isEmpty) {
            return _fallback();
          }
          return CachedNetworkImage(
            imageUrl: url,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 300),
            placeholder: (context, _) => _loading(),
            errorWidget: (context, _, __) => _fallback(),
          );
        },
      ),
    );
  }

  Widget _loading() {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.cardBg,
      alignment: Alignment.center,
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      ),
    );
  }

  Widget _fallback() {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.35), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(fallbackIcon, color: color, size: 42),
      ),
    );
  }
}
