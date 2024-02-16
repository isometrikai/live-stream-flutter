import 'package:appscrip_live_stream_component_example/utils/translations/translation_keys.dart';
import 'package:get/get.dart';

class AppValidator {
  const AppValidator._();

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return TranslationKeys.required.tr;
    }
    if (!GetUtils.isEmail(value)) {
      return '${TranslationKeys.invalid.tr} ${TranslationKeys.email.tr}';
    }
    return null;
  }

  static String? userName(String? value) {
    if (value == null || value.isEmpty) {
      return TranslationKeys.required.tr;
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return TranslationKeys.required.tr;
    }
    if (value.length < 8) {
      return TranslationKeys.passwordMustContain(TranslationKeys.lengthCharacters.tr);
    }
    if (!value.contains(RegExp('[a-z]'))) {
      return TranslationKeys.passwordMustContain(TranslationKeys.lowercase.tr);
    }
    if (!value.contains(RegExp('[A-Z]'))) {
      return TranslationKeys.passwordMustContain(TranslationKeys.uppercase.tr);
    }
    if (!value.contains(RegExp('[0-9]'))) {
      return TranslationKeys.passwordMustContain(TranslationKeys.number.tr);
    }
    // This Regex is to match special symbols
    if (!value.contains(RegExp('[^((0-9)|(a-z)|(A-Z)|)]'))) {
      return TranslationKeys.passwordMustContain(TranslationKeys.symbol.tr);
    }
    return null;
  }
}
