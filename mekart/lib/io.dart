import 'dart:io';

extension DirectoryExtension on Directory {
  File file(String path) => File('${this.path}${Platform.pathSeparator}$path');

  Directory directory(String path) => Directory('${this.path}${Platform.pathSeparator}$path');

  void createIfNotExistSync({bool recursive = false}) {
    if (existsSync()) return;
    createSync(recursive: recursive);
  }
}
