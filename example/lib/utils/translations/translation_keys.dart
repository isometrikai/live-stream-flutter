import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:get/get.dart';

/// `TranslationKeys` is a singleton class that will contain all the translation keys
///
/// If need to add another key add it inside this class.
/// For simplicity keep the key (variable) name same as its value
///
/// For example
/// ```dart
/// static const String foo = 'foo';
/// ```
///
/// To add the translated strings check [TranslationsFile]
class TranslationKeys {
  const TranslationKeys._();

  static String passwordMustContain(String character) =>
      mustContain.trParams({'character': character});

  static const String appName = 'appName';

  static const String login = 'login';
  static const String signup = 'signup';

  static const String email = 'email';
  static const String password = 'password';
  static const String confirmPassword = 'confirmPassword';
  static const String userName = 'userName';

  static const String required = 'required';
  static const String invalid = 'invalid';

  static const String mustContain = 'mustContain';
  static const String number = 'number';
  static const String lowercase = 'lowercase';
  static const String uppercase = 'uppercase';
  static const String symbol = 'symbol';
  static const String lengthCharacters = 'lengthCharacters';
}
