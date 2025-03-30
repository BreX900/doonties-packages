const None none = None._();

final class None {
  const None._();
}

@Deprecated('In favour of none')
const Nil nil = none;

@Deprecated('In favour of None')
typedef Nil = None;

final class Void {
  const Void();
}
