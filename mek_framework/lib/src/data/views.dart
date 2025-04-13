import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/shared/mek_utils.dart';
import 'package:mek/src/widgets/material/info_tile.dart';

extension AsyncValueExtensions on AsyncValue {
  bool get isUpdating => isLoading && hasValue;
}

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
}

base class AsyncHandler {
  const AsyncHandler();

  Widget buildLoadingView() {
    return const LimitedBox(
      maxWidth: 256.0,
      maxHeight: 256.0,
      child: Center(
        child: CircularProgressIndicator(),
      ),
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
      description:
          error is TextualError ? Text(error.message) : const Text('🤖 My n_m_ _s r_b_t! 🤖'),
    );
  }
}

class TextualError extends Error {
  final String message;

  TextualError(this.message);

  @override
  String toString() => 'TextualError: $message';
}
