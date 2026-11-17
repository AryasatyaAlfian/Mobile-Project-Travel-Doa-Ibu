import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Memasang font lokal untuk widget test tanpa jaringan.
///
/// Kenapa tidak langsung menunjuk satu path SDK: artefak
/// `material_fonts/roboto-regular.ttf` tidak selalu ada (di runner CI Flutter
/// hanya mengunduh artefak yang diminta, dan namanya bisa berbeda antar versi).
/// Kalau file tidak ditemukan, test tetap dijalankan dengan font default
/// (Ahem) — cukup untuk menguji layout, teks, dan finder.
Future<bool> installTestFonts() async {
  GoogleFonts.config.allowRuntimeFetching = false;

  final fontFile = _resolveFontFile();
  if (fontFile == null) return false;

  final font = ByteData.sublistView(await fontFile.readAsBytes());
  const codec = StandardMessageCodec();
  final manifest = <String, Object>{
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold'])
      'test-font/Poppins-$weight.ttf': [
        <String, Object>{'asset': 'test-font/Poppins-$weight.ttf'},
      ],
  };

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
        final name = utf8.decode(
          message!.buffer.asUint8List(
            message.offsetInBytes,
            message.lengthInBytes,
          ),
        );
        if (name == 'AssetManifest.bin') return codec.encodeMessage(manifest);
        if (name.startsWith('test-font/')) return font;
        final asset = File(name);
        if (await asset.exists()) {
          return ByteData.sublistView(await asset.readAsBytes());
        }
        return null;
      });
  return true;
}

void uninstallTestFonts() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', null);
  GoogleFonts.config.allowRuntimeFetching = true;
}

File? _resolveFontFile() {
  final env = Platform.environment;

  final explicit = env['TEST_FONT_PATH'];
  if (explicit != null && explicit.isNotEmpty) {
    final file = File(explicit);
    if (file.existsSync()) return file;
  }

  final root = env['FLUTTER_ROOT'];
  if (root == null || root.isEmpty) return null;

  final preferred = File(
    '$root/bin/cache/artifacts/material_fonts/roboto-regular.ttf',
  );
  if (preferred.existsSync()) return preferred;

  final dir = Directory('$root/bin/cache/artifacts/material_fonts');
  if (!dir.existsSync()) return null;
  final ttf = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.ttf'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return ttf.isEmpty ? null : ttf.first;
}
