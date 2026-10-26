import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/shared/mek_utils.dart';
import 'package:mek/src/widgets/material/info_tile.dart';

extension BuildViewAsyncValue<T> on AsyncValue<T> {
  R buildWhen<R>({
    required R Function() loading,
    required R Function(Object error, StackTrace stackTrace) error,
    required R Function(T data) data,
  }) {
    if (hasValue) return data(requireValue);
    if (isLoading) return loading();
    return error(this.error!, stackTrace!);
  }

  R? handleCallback<R>(R Function(T data) callback) {
    if (isLoading || hasError || !hasValue) return null;
    return callback(requireValue);
  }

  R maybeBuild<R>({
    R Function()? loading,
    R Function(Object error, StackTrace stackTrace)? error,
    R Function(T data)? data,
    required R Function() orElse,
  }) {
    return buildWhen(
      loading: loading ?? orElse,
      error: error ?? (_, _) => orElse(),
      data: data ?? (_) => orElse(),
    );
  }

  R? buildOrNull<R>({
    R Function()? loading,
    R Function(Object error, StackTrace stackTrace)? error,
    R Function(T data)? data,
  }) {
    return buildWhen(
      loading: loading ?? () => null,
      error: error ?? (_, _) => null,
      data: data ?? (_) => null,
    );
  }
}

base class AsyncHandler {
  const AsyncHandler();

  Widget buildLoadingView() {
    return const LimitedBox(
      maxWidth: 256.0,
      maxHeight: 256.0,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget buildErrorView(Object error, VoidCallback onRefresh) {
    return InfoView(
      onTap: onRefresh,
      icon: const Icon(Icons.error_outline),
      title: error is TextualError ? Text(error.message) : const Text('🤖 My n_m_ _s r_b_t! 🤖'),
    );
  }

  void showError(BuildContext context, Object error) {
    MekUtils.showErrorSnackBar(
      context: context,
      description: error is TextualError
          ? Text(error.message)
          : const Text('🤖 My n_m_ _s r_b_t! 🤖'),
    );
  }
}

class TextualError extends Error {
  final String message;

  TextualError(this.message);

  @override
  String toString() => 'TextualError: $message';
}
