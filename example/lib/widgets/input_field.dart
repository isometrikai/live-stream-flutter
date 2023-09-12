import 'package:appscrip_live_stream_component_example/res/res.dart';
import 'package:appscrip_live_stream_component_example/utils/validator.dart';
import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.controller,
    this.onchange,
    String? Function(String?)? validator,
    this.obscureText = false,
    this.obscureCharacter = ' ',
    this.suffixIcon,
    this.prefixIcon,
    TextInputType? textInputType,
  })  : _validator = validator,
        _textInputType = textInputType ?? TextInputType.text;

  const InputField.userName({
    super.key,
    required this.controller,
    this.onchange,
    this.obscureCharacter = '*',
    this.suffixIcon,
    this.prefixIcon,
    String? Function(String?)? validator,
  })  : _textInputType = TextInputType.name,
        obscureText = false,
        _validator = validator ?? AppValidator.userName;

  const InputField.email({
    super.key,
    required this.controller,
    this.onchange,
    this.obscureText = false,
    this.obscureCharacter = '*',
    this.suffixIcon,
    this.prefixIcon,
    String? Function(String?)? validator,
  })  : _textInputType = TextInputType.emailAddress,
        _validator = validator ?? AppValidator.emailValidator;

  const InputField.password({
    super.key,
    required this.controller,
    this.onchange,
    this.obscureText = true,
    this.obscureCharacter = '*',
    this.suffixIcon,
    this.prefixIcon,
    String? Function(String?)? validator,
  })  : _textInputType = TextInputType.visiblePassword,
        _validator = validator ?? AppValidator.passwordValidator;

  final TextEditingController controller;
  final String? Function(String?)? _validator;
  final TextInputType _textInputType;
  final Function(String value)? onchange;
  final bool obscureText;
  final String obscureCharacter;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) => Material(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimens.sixteen),
              borderSide: const BorderSide(
                color: ColorsValue.primary,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimens.sixteen),
              borderSide: const BorderSide(
                color: ColorsValue.primary,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimens.sixteen),
              borderSide: const BorderSide(
                color: ColorsValue.primary,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimens.sixteen),
              borderSide: const BorderSide(
                color: ColorsValue.primary,
                width: 1,
              ),
            ),
            counterText: '',
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
          validator: _validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: _textInputType,
          obscureText: obscureText,
          obscuringCharacter: obscureCharacter,
          onChanged: onchange,
        ),
      );
}
