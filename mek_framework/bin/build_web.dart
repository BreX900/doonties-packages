import 'dart:io';

import 'package:mekart/mekart_cli.dart';

void main() async {
  final pubspecFile = File('pubspec.yaml');
  final indexFile = File('web/index.html');

  final pubspecContent = pubspecFile.readAsStringSync();
  final buildNumber =
      RegExp(r'version: \d+\.\d+\.\d+\+(\d+)').firstMatch(pubspecContent)!.group(1)!;

  var indexContent = indexFile.readAsStringSync();
  final bootstrapUrlRegExp = RegExp(r'(?<=src=")flutter_bootstrap\.js[^"]*(?=")');
  indexContent = indexContent.replaceAllMapped(bootstrapUrlRegExp, (match) {
    final uri = Uri.parse(match.group(0)!);
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      'build-number': buildNumber,
    }).toString();
  });
  indexFile.writeAsStringSync(indexContent);

  await runProcess(onCommand: print, 'rm', ['-rf', 'build/web']);
  await runProcess(onCommand: print, 'flutter', ['build', 'web']);
}
