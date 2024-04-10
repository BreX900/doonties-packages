import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

@immutable
class DateRange {
  final Date start;
  final Date end;

  const DateRange({
    required this.start,
    required this.end,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(runtimeType, start, end);

  @override
  String toString() => '$start - $end';
}

@immutable
class Date {
  static final DateFormat _format = DateFormat('yyyy-MM-dd');

  final DateTime _value;

  int get year => _value.year;
  int get month => _value.month;
  int get day => _value.day;
  int get weekday => _value.weekday;

  Date(int year, [int month = 1, int day = 1]) : _value = DateTime.utc(year, month, day);

  @Deprecated('In favour of timestamp')
  factory Date.now() => Date.from(DateTime.now());

  factory Date.timestamp() => Date.from(DateTime.timestamp());

  factory Date.from(DateTime dateTime) => Date(dateTime.year, dateTime.month, dateTime.day);

  static Date parse(String source) => Date.from(_format.parseStrict(source, true));

  @Deprecated('In favour of copyWith')
  Date replace({int? year, int? month, int? day}) => copyWith(year: year, month: month, day: day);

  Date copyWith({int? year, int? month, int? day}) =>
      Date(year ?? _value.year, month ?? _value.month, day ?? _value.day);

  /// The day of the week [DateTime.monday]..[DateTime.sunday].
  ///
  /// In accordance with ISO 8601
  /// a week starts with Monday, which has the value 1.
  Date get initialWeekDay => applyWeekday(DateTime.monday);

  /// The day of the week [DateTime.monday]..[DateTime.sunday].
  ///
  /// In accordance with ISO 8601
  /// a week starts with Monday, which has the value 1.
  Date get lastWeekDay => applyWeekday(DateTime.sunday);

  Date get initialMonthDay => copyWith(day: 1);

  Date get lastMonthDay => copyWith(month: month + 1, day: 0);

  Date applyWeekday(int weekday) {
    assert(weekday >= 1 && weekday <= 7);
    return copyWith(day: day - (this.weekday - 1) + (weekday - 1));
  }

  DateTime get dateTime => _value;

  DateTime toDateTime() => _value.toLocal();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Date && runtimeType == other.runtimeType && _value == other._value;

  @override
  int get hashCode => Object.hash(runtimeType, _value);

  @override
  String toString() => _format.format(_value);
}

extension DateTimeToDate on DateTime {
  Date toDate() => Date.from(this);
}
