import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mek/src/shared/mek_utils.dart';
import 'package:mek/src/widgets/material/info_tile.dart';

Widget buildWithMaterial(BuildContext context, Widget child) {
  if (Material.maybeOf(context) == null) {
    return Material(
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: child,
      ),
    );
  }
  return child;
}

typedef LoadingDataBuilder = Widget Function(BuildContext context, LoadingData data);

class LoadingData {
  const LoadingData();
}

typedef ErrorDataBuilder = Widget Function(BuildContext context, ErrorData data);
typedef ErrorDataListener = void Function(BuildContext context, ErrorData data);

class ErrorData {
  final Object error;
  final VoidCallback? onTap;

  const ErrorData({
    required this.error,
    required this.onTap,
  });
}

typedef DataBuilders = DefaultWidgets;

/// Version 1.1.0
// extension BuildViewAsyncValue<T> on AsyncValue<T> {
// Widget buildView({
//   required void Function() onRefresh,
//   Widget Function()? loading,
//   required Widget Function(T data) data,
// }) {
//   return when(
//     skipLoadingOnRefresh: true,
//     skipLoadingOnReload: true,
//     skipError: false,
//     loading: loading ?? _buildLoadingView,
//     error: (error, _) {
//       if (isLoading) return _buildLoadingView();
//       return Builder(builder: (context) {
//         return DefaultWidgets.buildError(context, error, onTap: onRefresh);
//       });
//     },
//     data: data,
//   );
// }
//
// String buildString({required String Function(T data) data}) {
//   return when(
//     skipLoadingOnReload: true,
//     skipLoadingOnRefresh: true,
//     skipError: false,
//     loading: () => '...',
//     error: (_, __) => ' 🤕 ',
//     data: data,
//   );
// }
//
// static Widget _buildLoadingView() => const Builder(builder: DefaultWidgets.buildLoading);
// }

class DefaultWidgets extends ThemeExtension<DataBuilders> with EquatableMixin {
  static DefaultWidgets instance = const DefaultWidgets();

  final LoadingDataBuilder loadingBuilder;
  final ErrorDataBuilder errorBuilder;
  final ErrorDataListener errorListener;

  const DefaultWidgets({
    this.loadingBuilder = _buildLoading,
    this.errorBuilder = _buildError,
    this.errorListener = _showError,
  });

  static DefaultWidgets of(BuildContext context) =>
      Theme.of(context).extension<DefaultWidgets>() ?? const DefaultWidgets();

  static Widget buildLoading(BuildContext context) {
    return of(context).loadingBuilder(context, const LoadingData());
  }

  static Widget buildError(BuildContext context, Object error, {VoidCallback? onTap}) {
    return of(context).errorBuilder(context, ErrorData(error: error, onTap: onTap));
  }

  static void listenError(BuildContext context, Object error, {VoidCallback? onTap}) {
    return of(context).errorListener(context, ErrorData(error: error, onTap: onTap));
  }

  static Widget _buildLoading(BuildContext context, LoadingData data) {
    const child = LimitedBox(
      maxWidth: 256.0,
      maxHeight: 256.0,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
    return buildWithMaterial(context, child);
  }

  static Widget _buildError(BuildContext context, ErrorData data) {
    const child = InfoView(
      icon: Icon(Icons.error_outline),
      title: Text('🤖 My n_m_ _s r_b_t! 🤖'),
    );
    return buildWithMaterial(context, child);
  }

  static void _showError(BuildContext context, ErrorData data) {
    MekUtils.showSnackBarError(
      context: context,
      description: const Text('🤖 My n_m_ _s r_b_t! 🤖'),
    );
  }

  @override
  ThemeExtension<DataBuilders> copyWith() => this;

  @override
  ThemeExtension<DataBuilders> lerp(covariant ThemeExtension<DataBuilders>? other, double t) =>
      other ?? this;

  @override
  List<Object?> get props => [loadingBuilder, errorBuilder, errorListener];
}
