import 'package:flutter/material.dart';
import 'package:mek/src/widgets/common/shared_app_value.dart';

class DateTimePicker {
  static final _dateEntryPickerMode = SharedAppValue(() => DatePickerEntryMode.calendar);
  static final _timeEntryPickerMode = SharedAppValue(() => TimePickerEntryMode.dial);

  final bool _shouldPickTime;

  const DateTimePicker() : _shouldPickTime = true;

  const DateTimePicker.date() : _shouldPickTime = false;

  // Is broken
  // // _isDesktop(context) ? TimePickerEntryMode.input : TimePickerEntryMode.dial
  // static bool _isDesktop(BuildContext context) {
  //   return switch (Theme.of(context).platform) {
  //     TargetPlatform.android || TargetPlatform.iOS => false,
  //     TargetPlatform.fuchsia || TargetPlatform.linux => true,
  //     TargetPlatform.macOS || TargetPlatform.windows => true,
  //   };
  // }

  Future<DateTime?> _pickDate(BuildContext context, DateTime value) async {
    return await showDatePicker(
      context: context,
      initialEntryMode: _dateEntryPickerMode.get(context),
      onDatePickerModeChange: (mode) => _dateEntryPickerMode.set(context, mode),
      initialDate: value,
      firstDate: DateTime(1000),
      lastDate: DateTime(3000),
    );
  }

  Future<TimeOfDay?> _pickTime(BuildContext context, DateTime value) async {
    return await showTimePicker(
      context: context,
      initialEntryMode: _timeEntryPickerMode.get(context),
      onEntryModeChanged: (mode) => _timeEntryPickerMode.set(context, mode),
      initialTime: TimeOfDay.fromDateTime(value),
    );
  }

  Future<DateTime?> call(BuildContext context, DateTime prevValue) async {
    var currValue = prevValue;

    final date = await _pickDate(context, prevValue);
    if (!context.mounted || date == null) return null;

    currValue = date;

    if (_shouldPickTime) {
      final time = await _pickTime(context, prevValue);
      if (!context.mounted || time == null) return null;

      currValue = currValue.copyWith(hour: time.hour, minute: time.minute);
    }

    return currValue;
  }
}
