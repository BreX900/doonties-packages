// import 'package:bloc/bloc.dart';
// import 'package:meta/meta.dart';
//
// extension StateStreamableSelectorExtension<T> on StateStreamable<T> {
//   StateStreamable<R> $select<R>(R Function(T value) selector) =>
//       _StateStreamableSelector<T, R>(this, selector);
// }
//
// @immutable
// class _StateStreamableSelector<T, R> implements StateStreamable<R> {
//   final StateStreamable<T> stateStreamable;
//   final R Function(T listenable) selector;
//
//   const _StateStreamableSelector(this.stateStreamable, this.selector);
//
//   @override
//   R get state => selector(stateStreamable.state);
//
//   @override
//   Stream<R> get stream => stateStreamable.stream.map(selector);
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is _StateStreamableSelector<T, R> &&
//           runtimeType == other.runtimeType &&
//           stateStreamable == other.stateStreamable &&
//           selector == other.selector;
//
//   @override
//   int get hashCode => Object.hash(runtimeType, stateStreamable, selector);
// }
