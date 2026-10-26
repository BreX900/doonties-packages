import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

abstract class Document<T> {
  final T id;

  const Document({required this.id});

  bool equals(Document<T> other) => id == other.id;
}

extension type const Collection<T extends Document<String>>._(IList<T> _self)
    implements Iterable<T> {
  const Collection.empty() : _self = const IList.empty();

  // ignore: experimental_member_use
  @redeclare
  Iterator<T> get iterator => _self.iterator;

  T operator [](int index) => _self[index];

  bool has(String id) => _self.any((e) => e.id == id);

  T get(String id, {T Function()? orElse}) => _self.firstWhere((e) => e.id == id, orElse: orElse);

  T? getOrNull(String? id) {
    if (id == null) return null;
    return _self.firstWhereOrNull((e) => e.id == id);
  }

  Collection<T> set(T document) {
    final index = _indexOf(document);
    return Collection._(index != -1 ? _self.put(index, document) : _self.add(document));
  }

  Collection<T> update(T document) {
    final index = _indexOf(document);
    if (index == -1) throw StateError('Not exists document ${document.id}');
    return Collection._(_self.put(index, document));
  }

  Collection<T> remove(String id) => Collection._(_self.removeWhere((e) => e.id == id));

  /// Converts from JSon. Json serialization support for json_serializable with @JsonSerializable.
  factory Collection.fromJson(Map<String, Object?> json, T Function(Object?) fromJsonT) {
    return Collection._(
      json.mapTo((key, value) {
        return fromJsonT({'id': key, ...(value! as Map<String, dynamic>)});
      }).toIList(),
    );
  }

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) => Map.fromEntries(
    _self.map((document) {
      return MapEntry(document.id, (toJsonT(document)! as Map<String, dynamic>)..remove('id'));
    }),
  );

  int _indexOf(T document) => _self.indexWhere(document.equals);
}

extension type const Bundle<K, T extends Document<K>>._(IList<T> _self) implements Iterable<T> {
  const Bundle.empty() : _self = const IList.empty();

  // ignore: experimental_member_use
  @redeclare
  Iterator<T> get iterator => _self.iterator;

  T operator [](int index) => _self[index];

  bool has(K id) => _self.any((e) => e.id == id);

  T get(K id, {T Function()? orElse}) => _self.firstWhere((e) => e.id == id, orElse: orElse);

  T? getOrNull(K? id) {
    if (id == null) return null;
    return _self.firstWhereOrNull((e) => e.id == id);
  }

  Bundle<K, T> set(T document) {
    final index = _indexOf(document);
    return Bundle._(index != -1 ? _self.put(index, document) : _self.add(document));
  }

  Bundle<K, T> update(T document) {
    final index = _indexOf(document);
    if (index == -1) throw StateError('Not exists document ${document.id}');
    return Bundle._(_self.put(index, document));
  }

  Bundle<K, T> remove(K id) => Bundle._(_self.removeWhere((e) => e.id == id));

  /// Converts from JSon. Json serialization support for json_serializable with @JsonSerializable.
  factory Bundle.fromJson(Iterable<Object?> json, T Function(Object?) fromJsonT) =>
      Bundle._(json.map(fromJsonT).toIList());

  List<Object?> toJson(Object? Function(T) toJsonT) => _self.map(toJsonT).toList();

  int _indexOf(T document) => _self.indexWhere(document.equals);
}
