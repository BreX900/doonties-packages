import 'dart:async';

typedef _AE = AsyncError;

extension ParallelWaitErrorExtensions on ParallelWaitError<dynamic, dynamic> {
  List<AsyncError?> errorsToList() {
    final e = this;
    return switch (e) {
      ParallelWaitError<dynamic, List<_AE?>>() => e.errors,
      ParallelWaitError<dynamic, (_AE?, _AE)>() => e.errors.toList(),
      ParallelWaitError<dynamic, (_AE?, _AE?, _AE?)>() => e.errors.toList(),
      ParallelWaitError<dynamic, (_AE?, _AE?, _AE?, _AE?)>() => e.errors.toList(),
      ParallelWaitError<dynamic, (_AE?, _AE?, _AE?, _AE?, _AE?)>() => e.errors.toList(),
      ParallelWaitError<dynamic, (_AE?, _AE?, _AE?, _AE?, _AE?, _AE?)>() => e.errors.toList(),
      ParallelWaitError<dynamic, (_AE?, _AE?, _AE?, _AE?, _AE?, _AE?, _AE?)>() => e.errors.toList(),
      ParallelWaitError<dynamic, (_AE?, _AE?, _AE?, _AE?, _AE?, _AE?, _AE?, _AE?)>() =>
        e.errors.toList(),
      ParallelWaitError<dynamic, (_AE?, _AE?, _AE?, _AE?, _AE?, _AE?, _AE?, _AE?, _AE?)>() =>
        e.errors.toList(),
      _ => throw StateError('Unsupported ${e.runtimeType}.'),
    };
  }

  AsyncError get defaultError => errorsToList().firstWhere((e) => e != null)!;
}

extension Record2<T> on (T, T) {
  List<T> toList() => [$1, $2];
}

extension Record3<T> on (T, T, T) {
  List<T> toList() => [$1, $2, $3];
}

extension Record4<T> on (T, T, T, T) {
  List<T> toList() => [$1, $2, $3, $4];
}

extension Record5<T> on (T, T, T, T, T) {
  List<T> toList() => [$1, $2, $3, $4, $5];
}

extension Record6<T> on (T, T, T, T, T, T) {
  List<T> toList() => [$1, $2, $3, $4, $5, $6];
}

extension Record7<T> on (T, T, T, T, T, T, T) {
  List<T> toList() => [$1, $2, $3, $4, $5, $6, $7];
}

extension Record8<T> on (T, T, T, T, T, T, T, T) {
  List<T> toList() => [$1, $2, $3, $4, $5, $6, $7, $8];
}

extension Record9<T> on (T, T, T, T, T, T, T, T, T) {
  List<T> toList() => [$1, $2, $3, $4, $5, $6, $7, $8, $9];
}
