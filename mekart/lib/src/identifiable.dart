abstract class Identifiable<T extends Object> {
  T get id;
}

extension IdentifiableIterableExtensions<T extends Identifiable<K>, K extends Object>
    on Iterable<T> {
  T getById(K id) {
    for (final element in this) {
      if (element.id == id) return element;
    }
    throw StateError('Not found "$T" with id "$id" ');
  }

  T? getByNullId(K? id) => id != null ? getById(id) : null;

  T? getOrNullBy(K? id) {
    if (id == null) return null;
    for (final element in this) {
      if (element.id == id) return element;
    }
    return null;
  }

  bool containsById(K? id) {
    if (id == null) return false;
    for (final element in this) {
      if (element.id == id) return true;
    }
    return false;
  }
}
