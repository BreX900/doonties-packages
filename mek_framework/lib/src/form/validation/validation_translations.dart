import 'package:mek/src/form/validation/translate.dart';
import 'package:mek/src/form/validation/validation_errors.dart';

typedef Formatter<T> = String Function(T value);

class ValidationFormats {
  final ValidationFormats? _formats;
  final Formatter<DateTime>? _dateTimeFormatter;

  const ValidationFormats({ValidationFormats? formats, Formatter<DateTime>? dateTimeFormatter})
    : _formats = formats,
      _dateTimeFormatter = dateTimeFormatter;

  String format(Object value) {
    if (value is DateTime) {
      return formatDateTime(value);
    }
    return '$value';
  }

  String formatDateTime(DateTime value) =>
      _dateTimeFormatter?.call(value) ?? _formats?.formatDateTime(value) ?? '$value';

  ValidationFormats copyWith({Formatter<DateTime>? dateTimeFormatter}) {
    return ValidationFormats(formats: this, dateTimeFormatter: dateTimeFormatter);
  }
}

abstract class ValidationTranslations {
  static const List<ValidationTranslations> values = [
    ValidationEnTranslations(),
    ValidationItTranslations(),
  ];

  final ValidationFormats formats;

  Set<String> get languageCodes;

  const ValidationTranslations({this.formats = const ValidationFormats()});

  String invalid();

  String greaterThanComparable(Object value);

  String lessThanComparable(Object value);

  String greaterOrEqualThanComparable(Object value);

  String lessOrEqualThanComparable(Object value);

  String minLength(int value);

  String maxLength(int value);

  String match(String value);

  String notMatch(String value);

  String beforeDateTime(DateTime value);

  String afterDateTime(DateTime value);

  ValidationTranslations copyWith({ValidationFormats? formats});

  String translate(ValidationError error) {
    return translateValidationError(error, this);
  }
}

class ValidationEnTranslations extends ValidationTranslations {
  @override
  Set<String> get languageCodes => const {'en'};

  const ValidationEnTranslations({super.formats});

  @override
  String invalid() => 'It not valid.';

  @override
  String greaterThanComparable(Object value) => 'It must be greater than ${formats.format(value)}.';

  @override
  String lessThanComparable(Object value) => 'It must be less than ${formats.format(value)}.';

  @override
  String greaterOrEqualThanComparable(Object value) =>
      'It must be greater or equal than ${formats.format(value)}.';

  @override
  String lessOrEqualThanComparable(Object value) =>
      'It must be less or equal than ${formats.format(value)}.';

  @override
  String minLength(int value) => 'It must be at least $value characters.';

  @override
  String maxLength(int value) => 'It must be at most $value characters.';

  @override
  String match(String value) => 'Invalid format.';

  @override
  String notMatch(String value) => 'Invalid format.';

  @override
  String beforeDateTime(DateTime value) => 'It must be before ${formats.format(value)}.';

  @override
  String afterDateTime(DateTime value) => 'It must be after ${formats.format(value)}.';

  @override
  ValidationTranslations copyWith({ValidationFormats? formats}) {
    return ValidationEnTranslations(formats: formats ?? this.formats);
  }
}

class ValidationItTranslations extends ValidationEnTranslations {
  @override
  Set<String> get languageCodes => const {'it'};

  const ValidationItTranslations({super.formats});

  @override
  String invalid() => 'Non è valido.';

  @override
  String greaterThanComparable(Object value) => 'Maggiore di ${formats.format(value)}.';

  @override
  String lessThanComparable(Object value) => 'Minore di ${formats.format(value)}.';

  @override
  String greaterOrEqualThanComparable(Object value) =>
      'Maggiore o uguale di ${formats.format(value)}.';

  @override
  String lessOrEqualThanComparable(Object value) => 'Minore o uguale di ${formats.format(value)}.';

  @override
  String minLength(int value) => 'Almeno $value caratteri.';

  @override
  String maxLength(int value) => 'Massimo $value caratteri.';

  @override
  String match(String value) => 'Formato non valido.';

  @override
  String notMatch(String value) => 'Formato non valido.';

  @override
  String beforeDateTime(DateTime value) => 'Prima di ${formats.format(value)}.';

  @override
  String afterDateTime(DateTime value) => 'Dopo di ${formats.format(value)}.';

  @override
  ValidationTranslations copyWith({ValidationFormats? formats}) {
    return ValidationItTranslations(formats: formats ?? this.formats);
  }
}
