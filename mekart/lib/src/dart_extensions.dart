import 'dart:async';

abstract final class Comparators {
  static Comparator<T> by<T, K extends Comparable<Object>>(K Function(T element) keyOf) {
    return (a, b) => keyOf(a).compareTo(keyOf(b));
  }

  static Comparator<T> byBool<T>(bool Function(T element) keyOf) {
    return (a, b) {
      if (keyOf(a) && !keyOf(b)) return 1;
      if (!keyOf(a) && keyOf(b)) return -1;
      return 0;
    };
  }
}

DateTime parseDate(String source) {
  final segments = source.split('-');
  if (segments.length != 3) throw FormatException('Invalid date format', source);

  final year = int.tryParse(segments[0]);
  if (year == null) throw FormatException('Invalid date format', source, 0);
  final month = int.tryParse(segments[1]);
  if (month == null) throw FormatException('Invalid date format', source, 5);
  final day = int.tryParse(segments[2]);
  if (day == null) throw FormatException('Invalid date format', source, 8);

  return DateTime.utc(year, month, day);
}

extension StringExtensions on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}

extension DateTimeExtensions on DateTime {
  DateTime withoutTime() => copyDateWith();

  DateTime copyDateWith({
    int? year,
    int? month,
    int? day,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  }) =>
      (isUtc ? DateTime.utc : DateTime.new)(year ?? this.year, month ?? this.month, day ?? this.day,
          hour, minute, second, millisecond, microsecond);

  /// The day of the week [monday]..[sunday].
  ///
  /// In accordance with ISO 8601
  /// a week starts with Monday, which has the value 1.
  DateTime get initialWeekDay => withoutTime().applyWeekday(DateTime.monday);

  /// The day of the week [monday]..[sunday].
  ///
  /// In accordance with ISO 8601
  /// a week starts with Monday, which has the value 1.
  DateTime get lastWeekDay => withoutTime().applyWeekday(DateTime.sunday);

  DateTime get initialMonthDay => withoutTime().copyWith(day: 1);

  DateTime get lastMonthDay => withoutTime().copyWith(month: month + 1, day: 0);

  DateTime applyWeekday(int weekday) {
    assert(weekday >= 1 && weekday <= 7);
    return copyWith(day: day - (this.weekday - 1) + (weekday - 1));
  }

  DateTime copyAdding({int? years, int? months}) => copyWith(
        year: years != null ? year + years : null,
        month: months != null ? month + months : null,
      );

  DateTime copySubtracting({int? years, int? months}) => copyWith(
        year: years != null ? year - years : null,
        month: months != null ? month - months : null,
      );

  @Deprecated('In favour of inMonths')
  double differenceMonths(DateTime other) {
    final months = (year - other.year) * 12 + (month - other.month);

    final fixedOther = other.copyWith(year: year, month: month);
    final monthTime = fixedOther.difference(fixedOther.copyWith(month: fixedOther.month - 1));
    final consumedMonthTime = fixedOther.difference(this);

    return months - consumedMonthTime.inDays / monthTime.inDays;
  }

  double get inMonths {
    final firstMonthDate =
        copyWith(day: 1, hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    final lastMonthDate = copyWith(
        month: month + 1, day: 1, hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: -1);
    final distance = lastMonthDate.difference(firstMonthDate);
    final gap = difference(firstMonthDate);

    return year * 12 + (month - 1) + (gap.inMilliseconds / distance.inMilliseconds);
  }

  double get inYears => inMonths / 12;

  String toDateString() => '${_padNumber(year, 4)}-${_padNumber(month, 2)}-${_padNumber(day, 2)}';

  static String _padNumber(int value, int width) => value.toString().padLeft(width, '0');
}

extension DurationExtensions on Duration {
  int get days => inDays;
  int get hours => inHours % Duration.hoursPerDay;
  int get minutes => inMinutes % Duration.minutesPerHour;
  int get seconds => inSeconds % Duration.secondsPerMinute;
}

extension MapExtensions<K, V> on Map<K, V> {
  V require(K key, {V Function()? orElse}) {
    if (containsKey(key)) return this[key] as V;
    if (orElse != null) return orElse();
    throw StateError('Map<$K, $V> not contains "$key" key\n$this');
  }

  Iterable<R> mapEntries<R>(R Function(K key, V value) mapper) => entries.mapTo(mapper);

  Map<KR, VR> mapWhereNotNull<KR, VR>(MapEntry<KR, VR>? Function(K key, V value) mapper) =>
      Map.fromEntries(entries.map((e) => mapper(e.key, e.value)).nonNulls);
}

extension IterableExtension<T> on Iterable<T> {
  T firstSortedBy(Comparator<T> comparator) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) throw StateError('No element');
    var element = iterator.current;
    while (iterator.moveNext()) {
      final score = comparator(element, iterator.current);
      if (score <= 0) continue;
      element = iterator.current;
    }
    return element;
  }

  T lastSortedBy(Comparator<T> comparator) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) throw StateError('No element');
    var element = iterator.current;
    while (iterator.moveNext()) {
      final score = comparator(element, iterator.current);
      if (score >= 0) continue;
      element = iterator.current;
    }
    return element;
  }

  R? firstType<R extends Object>() {
    for (final element in this) {
      if (element is R) return element;
    }
    return null;
  }

  T? get oneOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    final result = iterator.current;
    if (!iterator.moveNext()) throw StateError('Too many elements');
    return result;
  }

  Iterable<R> whereTypeExtend<R extends T>() => whereType<R>();

  Iterable<R> mapNonNulls<R>(R? Function(T e) toElement) sync* {
    for (final element in this) {
      final result = toElement(element);
      if (result != null) yield result;
    }
  }

  Map<K, V> groupFolding<K, V>(
    V initialValue,
    K Function(T element) keyOf,
    V Function(V previousValue, T element) combine,
  ) {
    final result = <K, V>{};
    for (final element in this) {
      final key = keyOf(element);
      final value = result.putIfAbsent(key, () => initialValue);
      result[key] = combine(value, element);
    }
    return result;
  }

  // Iterable<T> intersect(T element) sync* {
  //   final iterator = this.iterator;
  //   if (!iterator.moveNext()) return;
  //
  //   yield iterator.current;
  //
  //   while (iterator.moveNext()) {
  //     yield element;
  //     yield iterator.current;
  //   }
  // }
  //
  // Iterable<R> intersectExpanded<R>(R element, R Function(T element) mapper) sync* {
  //   final iterator = this.iterator;
  //   if (!iterator.moveNext()) return;
  //
  //   yield iterator.current;
  //
  //   while (iterator.moveNext()) {
  //     yield element;
  //     yield iterator.current;
  //   }
  // }
}

extension ListExtensions<T> on List<T> {
  Iterable<T> skipLast(int count) => take(length - count);

  Iterable<T> takeLast(int count) => skip(length - count);
}

extension ListEntryExtensions<K, V> on Iterable<MapEntry<K, V>> {
  @Deprecated('In favour of mapTo')
  Iterable<R> mapEntries<R>(R Function(K key, V value) mapper) sync* {
    for (final entry in this) {
      yield mapper(entry.key, entry.value);
    }
  }

  Iterable<R> mapTo<R>(R Function(K key, V value) mapper) sync* {
    for (final entry in this) {
      yield mapper(entry.key, entry.value);
    }
  }

  Iterable<MapEntry<K, V>> whereEntry(bool Function(K key, V value) predicate) sync* {
    for (final entry in this) {
      if (predicate(entry.key, entry.value)) yield entry;
    }
  }

  Iterable<K> get keys => map((e) => e.key);
  Iterable<V> get values => map((e) => e.value);
  Map<K, V> toMap() => Map.fromEntries(this);
}

FutureOr<List<T>> waitAll<T>(Iterable<FutureOr<T>> entries) {
  final values = <T?>[];

  Completer<List<T>>? completer;

  var index = 0;
  var remaining = 0;
  for (final futureOrValue in entries) {
    if (futureOrValue is T) {
      values.add(futureOrValue);
    } else {
      final xCompleter = completer ??= Completer();
      values.add(null);
      final pos = index;
      remaining++;
      futureOrValue.then((value) {
        values[pos] = value;
        remaining--;
        if (remaining == 0) xCompleter.complete(List<T>.from(values));
      }, onError: xCompleter.completeError);
    }
    index++;
  }

  if (completer == null) return List<T>.from(values);
  return completer.future;
}
