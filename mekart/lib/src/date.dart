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
class Date implements Comparable<Date> {
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

  static Date fromJson(String source) => Date.parse(source);

  static Date parse(String source) {
    final segments = source.split('-');
    if (segments.length != 3) throw FormatException('Invalid date format', source);

    final year = int.tryParse(segments[0]);
    if (year == null) throw FormatException('Invalid date format', source, 0);
    final month = int.tryParse(segments[1]);
    if (month == null) throw FormatException('Invalid date format', source, 5);
    final day = int.tryParse(segments[2]);
    if (day == null) throw FormatException('Invalid date format', source, 8);

    return Date(year, month, day);
  }

  @Deprecated('In favour of copyWith')
  Date replace({int? year, int? month, int? day}) => copyWith(year: year, month: month, day: day);

  Date copyWith({int? year, int? month, int? day}) =>
      Date(year ?? _value.year, month ?? _value.month, day ?? _value.day);

  Date copyAdding({int years = 0, int months = 0, int days = 0}) =>
      Date(_value.year + years, _value.month + months, _value.day + days);

  Date copySubtracting({int years = 0, int months = 0, int days = 0}) =>
      Date(_value.year - years, _value.month - months, _value.day - days);

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

  DateTime asDateTime() => _value;

  DateTime toDateTime() => _value.toLocal();

  bool isBefore(Date other) => _value.isBefore(other._value);
  bool isAfter(Date other) => _value.isAfter(other._value);

  String toJson() => '${_padNumber(year, 4)}-${_padNumber(month, 2)}-${_padNumber(day, 2)}';

  @override
  int compareTo(Date other) => _value.compareTo(other._value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Date && runtimeType == other.runtimeType && _value == other._value;

  @override
  int get hashCode => Object.hash(runtimeType, _value);

  @override
  String toString() => toJson();

  static String _padNumber(int value, int width) => value.toString().padLeft(width, '0');
}

extension DateTimeAsDate on DateTime {
  Date asDate() => Date.from(this);
}
