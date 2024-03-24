import 'dart:io';

import 'package:yaml/yaml.dart';

class Rds {
  final Directory directory;
  final List<Workspace> workspaces;
  final Map<String, String> scripts;

  const Rds._({
    required this.directory,
    required this.workspaces,
    required this.scripts,
  });

  static Future<Rds?> read(Directory directory) async {
    final pubspecFile = File('${directory.path}/rds.yaml');
    if (!pubspecFile.existsSync()) return null;

    final map = loadYaml(await pubspecFile.readAsString()) as Map;
    return Rds._(
      directory: directory,
      workspaces: (map['workspaces'] as List? ?? const [])
          .map((value) => Workspace.fromMap(value as Map))
          .toList(),
      scripts: (map['scripts'] as Map?)?.cast() ?? const <String, String>{},
    );
  }

  static Future<Rds> find(Directory directory) async {
    if (directory.path == directory.parent.path) {
      return throw StateError('File rds.yaml not exist!');
    }

    final rds = await read(directory);
    if (rds != null) return rds;

    return await find(directory.parent);
  }
}

class Workspace {
  final String name;
  final Directory directory;
  final List<String> modules;

  const Workspace({
    required this.name,
    required this.directory,
    required this.modules,
  });

  String get path => directory.path;

  factory Workspace.fromMap(Map<dynamic, dynamic> map) {
    return Workspace(
      name: map['name'] as String,
      directory: Directory(map['path'] as String),
      modules: (map['modules'] as List).cast(),
    );
  }
}
