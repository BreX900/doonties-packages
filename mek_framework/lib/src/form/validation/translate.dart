import 'package:mek/src/form/validation/validation_errors.dart';
import 'package:mek/src/form/validation/validation_translations.dart';

String translateValidationError(ValidationError e, ValidationTranslations t) {
  if (e is InvalidValidationError) {
    switch (e.code) {
      case InvalidValidationError.intCode:
        return 'Invalid integer value.';
      case InvalidValidationError.doubleCode:
      case InvalidValidationError.rationalCode:
        return 'Invalid decimal value.';
    }
    return t.invalid();
  } else if (e is EqualityValidationError) {
    return 'The field must be equal to ${e.equals ?? e.identical}.';
  } else if (e is RequiredValidationError) {
    return 'This field is required.';
  } else if (e is TextValidationError) {
    switch (e.code) {
      case TextValidationError.urlCode:
        return 'Invalid url.';
      case TextValidationError.emailCode:
        return 'Invalid email.';
    }
    if (e.minLength != null) {
      return t.minLength(e.minLength!);
    } else if (e.maxLength != null) {
      return t.maxLength(e.maxLength!);
    } else if (e.match != null) {
      return t.match(e.match!);
    } else if (e.notMatch != null) {
      return t.notMatch(e.notMatch!);
    }
  } else if (e is NumberValidationError) {
    if (e.greaterThan != null) {
      return t.greaterThanComparable(e.greaterThan!);
    } else if (e.lessThan != null) {
      return t.lessThanComparable(e.lessThan!);
    } else if (e.greaterOrEqualThan != null) {
      return t.greaterOrEqualThanComparable(e.greaterOrEqualThan!);
    } else if (e.lessOrEqualThan != null) {
      return t.lessOrEqualThanComparable(e.lessOrEqualThan!);
    }
  } else if (e is OptionsValidationError) {
    if (e.lengths != null) {
      return 'Select (${e.lengths!.join(', ')}) options.';
    } else if (e.minLength != null) {
      return 'Select at least ${e.minLength} options.';
    } else if (e.maxLength != null) {
      return 'Select up to ${e.maxLength} options.';
    } else if (e.whereIn != null) {
      return 'Selection must contain these options (${e.whereIn!.join(', ')}).';
    } else if (e.whereNotIn != null) {
      return 'Selection must not contains these options (${e.whereNotIn!.join(', ')}).';
    }
  } else if (e is FileValidationError) {
    if (e.whereExtensionIn != null) {
      return 'Allowed file extensions are as follows: (${e.whereExtensionIn!.join(', ')}).';
    } else if (e.whereExtensionNotIn != null) {
      return 'The file extensions not allowed are as follows: (${e.whereExtensionNotIn!.join(', ')}).';
    }
  } else if (e is DateTimeValidationError) {
    if (e.after != null) {
      return 'It must be greater than ${t.formats.format(e.after!)}.';
    } else if (e.before != null) {
      return 'It must be less than ${t.formats.format(e.before!)}.';
    }
  }

  assert(false, 'Unknown ValidationError $e');

  return e.code?.replaceFirst(ValidationError.codePrefix, '') ?? 'Error type: $e';
}
