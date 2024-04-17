import 'dart:async';

import 'package:collection/collection.dart';
import 'package:pure_extensions/pure_extensions.dart';
import 'package:rxdart/rxdart.dart';

extension DateTimeExtensions on DateTime {
  DateTime get date => (isUtc ? DateTime.utc : DateTime.new)(year, month, day);

  /// The day of the week [monday]..[sunday].
  ///
  /// In accordance with ISO 8601
  /// a week starts with Monday, which has the value 1.
  DateTime get initialWeekDay => date.applyWeekday(DateTime.monday);

  /// The day of the week [monday]..[sunday].
  ///
  /// In accordance with ISO 8601
  /// a week starts with Monday, which has the value 1.
  DateTime get lastWeekDay => date.applyWeekday(DateTime.sunday);

  DateTime get initialMonthDay => date.copyWith(day: 1);

  DateTime get lastMonthDay => date.copyWith(month: month + 1, day: 0);

  DateTime applyWeekday(int weekday) {
    assert(weekday >= 1 && weekday <= 7);
    return copyWith(day: day - (this.weekday - 1) + (weekday - 1));
  }

  DateTime copyAdding({int? years, int? months}) => copyWith(
        year: years != null ? year + years : null,
        month: months != null ? month + months : null,
      );
}

extension MapExtensions<K, V> on Map<K, V> {
  bool equals(Map<K, V> other) => const MapEquality<Object?, Object?>().equals(this, other);

  Iterable<R> mapEntries<R>(R Function(K key, V value) mapper) => entries.mapTo(mapper);

  Map<KR, VR> mapWhereNotNull<KR, VR>(MapEntry<KR, VR>? Function(K key, V value) mapper) =>
      entries.map((e) => mapper(e.key, e.value)).nonNulls.toMap();
}

extension SetExtensions<T> on Set<T> {
  bool equals(Set<T> other) => const SetEquality<Object?>().equals(this, other);
}

extension IterableExtension<T> on Iterable<T> {
  bool equals(Iterable<T> other) => const IterableEquality<Object?>().equals(this, other);

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
      if (!predicate(entry.key, entry.value)) yield entry;
    }
  }
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

extension AsyncSwitchMapStream<T> on Stream<T> {
  Stream<R> asyncSwitchMap<R>(Future<R> Function(T event) mapper) {
    return switchMap<R>((event) async* {
      yield await mapper(event);
    });
  }
}
