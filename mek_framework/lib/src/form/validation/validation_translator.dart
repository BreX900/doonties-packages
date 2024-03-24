import 'package:mek/src/form/validation/translate.dart';
import 'package:mek/src/form/validation/validation_errors.dart';
import 'package:mek/src/form/validation/validation_translations.dart';

class ValidationTranslator {
  final ValidationTranslations fallbackTranslations;
  final List<ValidationTranslations> translations;

  const ValidationTranslator({
    this.fallbackTranslations = const ValidationEnTranslations(),
    this.translations = ValidationTranslations.values,
  });

  bool isSupported(String languageCode) {
    return translations.any((translations) {
      return translations.languageCodes.contains(languageCode);
    });
  }

  ValidationTranslations resolve(String languageCode) {
    return translations.lastWhere(
      (translations) => translations.languageCodes.contains(languageCode),
      orElse: () => fallbackTranslations,
    );
  }

  String translate(ValidationError e, String languageCode) {
    return translateValidationError(e, resolve(languageCode));
  }
}
