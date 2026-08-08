import 'dart:convert';
import 'package:http/http.dart' as http;


class ImageService {
  ImageService._();
  static final ImageService instance = ImageService._();

  final Map<String, String?> _cache = {};

  static const _arSummaryBase =
      'https://ar.wikipedia.org/api/rest_v1/page/summary/';
  static const _enSummaryBase =
      'https://en.wikipedia.org/api/rest_v1/page/summary/';

  Future<String?> fetchImageUrl(String query) async {
    final key = query.trim().toLowerCase();
    if (key.isEmpty) return null;
    if (_cache.containsKey(key)) return _cache[key];

    final ar = await _fetchFrom(_arSummaryBase, query);
    if (ar != null) {
      _cache[key] = ar;
      return ar;
    }

    final en = await _fetchFrom(_enSummaryBase, query);
    _cache[key] = en;
    return en;
  }

  Future<String?> _fetchFrom(String base, String query) async {
    try {
      final uri = Uri.parse('$base${Uri.encodeComponent(query)}');
      final response = await http
          .get(uri, headers: {'accept': 'application/json'})
          .timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final thumbnail = data['thumbnail'];
      final original = data['originalimage'];

      if (original != null && original['source'] != null) {
        return original['source'] as String;
      }
      if (thumbnail != null && thumbnail['source'] != null) {
        return thumbnail['source'] as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
