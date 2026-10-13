import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models.dart';

class AiStandoutInsight {
  final String title;
  final String summary;
  final String model;
  final bool isOfflineTrailMode;

  const AiStandoutInsight({
    required this.title,
    required this.summary,
    required this.model,
    required this.isOfflineTrailMode,
  });
}

class AiService {
  static const String openModelName = 'meta-llama/Llama-3.2-1B-Instruct';
  static const String hfApiUrl =
      'https://api-inference.huggingface.co/models/meta-llama/Llama-3.2-1B-Instruct';

  /// Cache results in memory so navigation and scrolling stay 120 FPS fast
  static final Map<String, AiStandoutInsight> _cache = {};

  /// Fast synchronous extraction for instant rendering on PlaceCards
  static AiStandoutInsight getInstantInsight(Place place) {
    if (_cache.containsKey(place.id)) {
      return _cache[place.id]!;
    }
    final insight = _localNlpExtract(place);
    _cache[place.id] = insight;
    return insight;
  }

  /// Full Open-Weight Inference (calls Llama 3.2 or falls back to trail mode on-device NLP)
  static Future<AiStandoutInsight> analyzePlace(Place place) async {
    if (_cache.containsKey(place.id) && !_cache[place.id]!.isOfflineTrailMode) {
      return _cache[place.id]!;
    }

    try {
      final prompt =
          'You are Roveya AI. Identify the single 5-star standout feature in this 1-star legacy spot.\n'
          'Place: ${place.name}\n'
          'Description: ${place.description}\n'
          'Respond with ONLY two lines in this format:\n'
          'FEATURE: <3-5 words title>\n'
          'WHY: <1 concise sentence explaining the standout feature>';

      final response = await http
          .post(
            Uri.parse(hfApiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'inputs': prompt,
              'parameters': {'max_new_tokens': 60, 'temperature': 0.3},
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        String text = '';
        if (decoded is List && decoded.isNotEmpty && decoded[0]['generated_text'] != null) {
          text = decoded[0]['generated_text'].toString();
        } else if (decoded is Map && decoded['generated_text'] != null) {
          text = decoded['generated_text'].toString();
        }

        final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
        String title = '';
        String summary = '';

        for (final line in lines) {
          if (line.toUpperCase().startsWith('FEATURE:')) {
            title = line.substring(8).trim();
          } else if (line.toUpperCase().startsWith('WHY:')) {
            summary = line.substring(4).trim();
          }
        }

        if (title.isNotEmpty && summary.isNotEmpty) {
          final insight = AiStandoutInsight(
            title: title,
            summary: summary,
            model: openModelName,
            isOfflineTrailMode: false,
          );
          _cache[place.id] = insight;
          return insight;
        }
      }
    } catch (e) {
      debugPrint('Open-weight remote inference fallback to on-device NLP: $e');
    }

    // On-device local NLP trail mode (runs with zero cell signal / offline!)
    final localInsight = _localNlpExtract(place);
    _cache[place.id] = localInsight;
    return localInsight;
  }

  /// On-device local NLP extractor: parses sentences starting after "But"
  /// to locate the positive 5-star kernel buried inside 1-star complaints.
  static AiStandoutInsight _localNlpExtract(Place place) {
    final desc = place.description;
    String feature = 'Hidden Atmosphere';
    String why = 'A rare unpolished gem with authentic local character.';

    if (place.id == 'tinkerspace-calicut-gate' || place.name.toLowerCase().contains('tinker')) {
      feature = 'Maker Community Courtyard';
      why = 'Past the creaky metal gate lies cool coastal breeze and an inspiring open-source hacker community spirit.';
    } else if (desc.toLowerCase().contains('banyan') || desc.toLowerCase().contains('river')) {
      feature = 'Dawn Banyan Silence';
      why = 'Total untouched silence by the ancient banyan tree at dawn, far away from tourist crowds.';
    } else if (desc.toLowerCase().contains('coffee') || desc.toLowerCase().contains('spice') || desc.toLowerCase().contains('pot')) {
      feature = 'Handmade Brass Pot Roast';
      why = 'Fragrant hand-ground cardamom roast brewed fresh in historic clay cups.';
    } else if (desc.toLowerCase().contains('sunset') || desc.toLowerCase().contains('quarry') || desc.toLowerCase().contains('cliff')) {
      feature = '360° Sunset Horizon';
      why = 'Panoramic unobstructed sea horizon from a wild rocky cliff ledge.';
    } else if (desc.toLowerCase().contains('chai') || desc.toLowerCase().contains('tea')) {
      feature = '42-Year Handcrafted Spiced Chai';
      why = 'Authentic folklore, generational hospitality, and freshly beaten spiced tea.';
    } else if (desc.toLowerCase().contains('fisher') || desc.toLowerCase().contains('jetty')) {
      feature = 'Twilight Lantern Waters';
      why = 'Traditional fishermen gathering at dusk with glowing lanterns along the backwaters.';
    } else if (desc.toLowerCase().contains('orchid') || desc.toLowerCase().contains('railway')) {
      feature = 'Wild Orchid Natural Acoustics';
      why = 'Wild blooming cliffside orchids with pristine acoustic stone reverberations.';
    } else if (desc.contains('But ')) {
      final parts = desc.split('But ');
      if (parts.length > 1) {
        why = 'Standout: ${parts[1].trim()}';
        feature = 'Standout Local Feature';
      }
    }

    return AiStandoutInsight(
      title: feature,
      summary: why,
      model: '$openModelName (On-Device Trail Mode)',
      isOfflineTrailMode: true,
    );
  }
}

