import 'package:logging/logging.dart';

const bool kReleaseMode = bool.fromEnvironment('RELEASE_MODE');
const bool kDebugMode = !kReleaseMode;

final lg = Logger.detached('app');
