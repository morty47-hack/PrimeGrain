import 'dart:convert';

import 'package:flutter/services.dart';

class AssetsService {
  const AssetsService._();

  static const String _imagesPrefix = 'assets/images/';

  static Future<List<String>> listProductImages() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = json.decode(manifestJson);

    final images = manifest.keys
        .where((key) => key.startsWith(_imagesPrefix))
        .where((key) {
          final lower = key.toLowerCase();
          return lower.endsWith('.jpg') ||
              lower.endsWith('.jpeg') ||
              lower.endsWith('.png') ||
              lower.endsWith('.webp');
        })
        .toList()
      ..sort();

    return images;
  }
}

