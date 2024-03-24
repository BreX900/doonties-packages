abstract class LogMessage {
  const LogMessage();

  const factory LogMessage.summary(String text) = _SummaryLogMessage;
  const factory LogMessage.description(String text) = _DescriptionLogMessage;
  const factory LogMessage.composite(List<LogMessage> children) = _CompositeLogMessage;

  @override
  String toString({bool short = false});
}

class _SummaryLogMessage extends LogMessage {
  final String text;

  const _SummaryLogMessage(this.text);

  @override
  String toString({bool short = false}) => text;
}

class _DescriptionLogMessage extends LogMessage {
  final String text;

  const _DescriptionLogMessage(this.text);

  @override
  String toString({bool short = false}) => text;
}

class _CompositeLogMessage extends LogMessage {
  final List<LogMessage> children;

  const _CompositeLogMessage(this.children);

  @override
  String toString({bool short = false}) {
    var children = this.children.expand(_flat);
    if (short) children = children.whereType<_DescriptionLogMessage>();
    return children.join('\n');
  }

  Iterable<LogMessage> _flat(LogMessage message) sync* {
    if (message is _CompositeLogMessage) {
      yield* message.children.expand(_flat);
    } else {
      yield message;
    }
  }
}
