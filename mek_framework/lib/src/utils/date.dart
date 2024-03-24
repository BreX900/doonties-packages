import 'package:intl/intl.dart';

class Date extends DateTime {
  static final DateFormat _format = DateFormat('yyyy-MM-dd');

  Date(super.year, [super.month, super.day]) : super.utc();

  factory Date.now() => Date.from(DateTime.now());

  factory Date.from(DateTime dateTime) {
    if (dateTime is Date) return dateTime;
    return Date(dateTime.year, dateTime.month, dateTime.day);
  }

  static Date parse(String source) => Date.from(_format.parseStrict(source, true));

  Date replace({int? year, int? month, int? day}) =>
      Date(year ?? this.year, month ?? this.month, day ?? this.day);

  @override
  String toString() => _format.format(this);
}

extension DateTimeToDate on DateTime {
  Date toDate() => Date.from(this);

  DateTime get date => DateTime.utc(year, month, day);
}
