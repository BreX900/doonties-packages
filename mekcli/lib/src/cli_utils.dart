import 'package:logging/logging.dart';

const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
const bool kDebugMode = !kReleaseMode;
const String kBuildName = String.fromEnvironment('BUILD_NAME', defaultValue: '0.0.0');
const int kBuildNumber = int.fromEnvironment('BUILD_NUMBER', defaultValue: -1);

final lg = Logger.detached('app');
