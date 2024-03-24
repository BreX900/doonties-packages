import 'dart:io';

import 'package:path/path.dart' as path_;
import 'package:yaml/yaml.dart';

class Project {
  final Directory directory;
  final String name;
  final Map<String, String> scripts;
  final Map<String, dynamic> dependencies;

  const Project({
    required this.directory,
    required this.name,
    required this.scripts,
    required this.dependencies,
  });

  factory Project.fromMap(Directory directory, Map<dynamic, dynamic> map) {
    return Project(
      directory: directory,
      name: map['name'],
      scripts: (map['scripts'] as Map?)?.cast() ?? const <String, String>{},
      dependencies: (map['dependencies'] as Map?)?.cast() ?? const <String, dynamic>{},
    );
  }

  String get path => directory.path;

  String get rootPath => path_.relative(directory.path);

  Iterable<String> get dependentRootPaths sync* {
    yield rootPath;

    for (final dependency in dependencies.values) {
      if (dependency is! Map<dynamic, dynamic>) continue;

      final path = dependency['path'] as String?;
      if (path == null) continue;

      yield path_.relative(path_.normalize(path_.join(directory.path, path)));
    }
  }

  String get modulePath => '${directory.path}/$name.iml';

  bool get hasFlutterDependency => dependencies.containsKey('flutter');

  static Future<Project> read(Directory directory) async {
    final pubspecContent = await File('${directory.path}/pubspec.yaml').readAsString();
    final data = loadYaml(pubspecContent);
    return Project.fromMap(directory, data);
  }

  static Stream<Project> find(Directory directory) {
    return directory.list().asyncExpand((file) async* {
      if (path_.basename(file.path).startsWith('.')) {
        return;
      } else if (file.path.endsWith('/pubspec.yaml')) {
        yield await Project.read(directory);
      } else if (file.statSync().type == FileSystemEntityType.directory) {
        yield* find(Directory(file.path));
      }
    });
  }
}
