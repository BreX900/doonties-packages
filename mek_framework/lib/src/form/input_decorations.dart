import 'package:flutter/material.dart';

abstract final class InputDecorations {
  static const InputDecoration borderless = InputDecoration(
    border: InputBorder.none,
    focusedBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    enabledBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
  );

  static const InputDecoration flat = InputDecoration(
    border: InputBorder.none,
    focusedBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    enabledBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    contentPadding: EdgeInsets.zero,
    isDense: true,
  );
}
