import 'package:flutter/material.dart';
import 'package:mek/src/shared/mek_utils.dart';
import 'package:mek/src/widgets/dispenser.dart';
import 'package:mek/src/widgets/info_tile.dart';

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

class DataBuilders extends DispensableEquatable<DataBuilders> {
  final LoadingDataBuilder loadingBuilder;
  final ErrorDataBuilder errorBuilder;
  final ErrorDataListener errorListener;

  const DataBuilders({
    this.loadingBuilder = _buildLoading,
    this.errorBuilder = _buildError,
    this.errorListener = MekUtils.showSnackBarDataError,
  });

  static DataBuilders of(BuildContext context) =>
      Dispense.maybeOf<DataBuilders>(context) ?? const DataBuilders();

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
    const child = Center(
      child: CircularProgressIndicator(),
    );
    return buildWithMaterial(context, child);
  }

  static Widget _buildError(BuildContext context, ErrorData data) {
    const child = InfoTile(
      icon: Icon(Icons.error_outline),
      title: Text('🤖 My n_m_ _s r_b_t! 🤖'),
    );
    return buildWithMaterial(context, child);
  }

  @override
  List<Object?> get props => [loadingBuilder, errorBuilder, errorListener];
}
