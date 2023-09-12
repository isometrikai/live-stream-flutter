import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveInputField extends StatelessWidget {
  const IsmLiveInputField({
    super.key,
    required this.controller,
    this.onchange,
    this.validator,
    this.obscureText = false,
    this.obscureCharacter = ' ',
    this.suffixIcon,
    this.prefixIcon,
    TextInputType? textInputType,
  }) : _textInputType = textInputType ?? TextInputType.text;

  const IsmLiveInputField.userName({
    super.key,
    required this.controller,
    this.onchange,
    this.obscureCharacter = '*',
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
  })  : _textInputType = TextInputType.name,
        obscureText = false;

  const IsmLiveInputField.email({
    super.key,
    required this.controller,
    this.onchange,
    this.obscureText = false,
    this.obscureCharacter = '*',
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
  }) : _textInputType = TextInputType.emailAddress;

  const IsmLiveInputField.password({
    super.key,
    required this.controller,
    this.onchange,
    this.obscureText = true,
    this.obscureCharacter = '*',
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
  }) : _textInputType = TextInputType.visiblePassword;

  final TextEditingController controller;
  final String? Function(String?)? validator;
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
              borderRadius: BorderRadius.circular(IsmLiveDimens.sixteen),
              borderSide: const BorderSide(
                color: IsmLiveColors.primary,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(IsmLiveDimens.sixteen),
              borderSide: const BorderSide(
                color: IsmLiveColors.primary,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(IsmLiveDimens.sixteen),
              borderSide: const BorderSide(
                color: IsmLiveColors.primary,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(IsmLiveDimens.sixteen),
              borderSide: const BorderSide(
                color: IsmLiveColors.primary,
                width: 1,
              ),
            ),
            counterText: '',
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: _textInputType,
          obscureText: obscureText,
          obscuringCharacter: obscureCharacter,
          onChanged: onchange,
        ),
      );
}
