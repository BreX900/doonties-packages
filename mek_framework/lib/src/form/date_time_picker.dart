import 'package:flutter/material.dart';

class DateTimePicker {
  final bool _shouldPickTime;

  const DateTimePicker() : _shouldPickTime = true;

  const DateTimePicker.date() : _shouldPickTime = false;

  Future<DateTime?> _pickDate(BuildContext context, DateTime value) async {
    return await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(1000),
      lastDate: DateTime(3000),
    );
  }

  Future<TimeOfDay?> _pickTime(BuildContext context, DateTime value) async {
    return await showTimePicker(
      context: context,
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
