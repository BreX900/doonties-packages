import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

abstract class Document {
  final String id;

  const Document({required this.id});

  bool equals(Document other) => id == other.id;
}

extension type const Collection<T extends Document>._(IList<T> _self) implements Iterable<T> {
  const Collection.empty() : _self = const IList.empty();

  @redeclare
  Iterator<T> get iterator => _self.iterator;

  int get length => _self.length;

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
  factory Collection.fromJson(
    Map<String, Object?> json,
    T Function(Object?) fromJsonT,
  ) {
    return Collection._(json.mapTo((key, value) {
      return fromJsonT({'id': key, ...(value! as Map<String, dynamic>)});
    }).toIList());
  }

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) => Map.fromEntries(_self.map((document) {
        return MapEntry(document.id, (toJsonT(document)! as Map<String, dynamic>)..remove('id'));
      }));

  int _indexOf(T document) => _self.indexWhere(document.equals);
}

// extension type Piero(int value) {}
//
// void main() {
//   final piero = Collection.empty();
//
//   piero.map(toElement)
// }
