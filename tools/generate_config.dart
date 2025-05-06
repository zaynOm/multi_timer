// tool/generate_config.dart
import 'dart:io';

void main() {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('pubspec.yaml not found');
    exit(1);
  }

  final content = pubspec.readAsStringSync();
  final version = content.split('version: ')[1].split('+')[0].trim();

  final outFile = File('lib/config.dart');
  outFile.writeAsStringSync('''
// GENERATED FILE - DO NOT MODIFY
const String appVersion = '$version';
''');

  print('✅ Generated lib/config.dart');
}
