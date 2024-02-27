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
    this.readOnly = false,
    this.onTap,
    this.hintText,
    this.borderColor,
    this.fillColor,
    this.hintStyle,
    this.alignLabelWithHint,
    this.minLines,
    this.maxLines,
    this.cursorColor,
    this.style,
    this.radius,
    this.onFieldSubmit,
    this.textInputAction,
    this.contentPadding,
  }) : _textInputType = textInputType ?? TextInputType.text;

  const IsmLiveInputField.userName({
    super.key,
    required this.controller,
    this.onchange,
    this.obscureCharacter = '*',
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.hintText,
    this.borderColor,
    this.fillColor,
    this.hintStyle,
    this.alignLabelWithHint,
    this.minLines,
    this.maxLines,
    this.cursorColor,
    this.style,
    this.radius,
    this.onFieldSubmit,
    this.textInputAction,
    this.contentPadding,
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
    this.readOnly = false,
    this.onTap,
    this.hintText,
    this.borderColor,
    this.fillColor,
    this.hintStyle,
    this.alignLabelWithHint,
    this.minLines,
    this.maxLines,
    this.cursorColor,
    this.style,
    this.radius,
    this.onFieldSubmit,
    this.textInputAction,
    this.contentPadding,
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
    this.readOnly = false,
    this.onTap,
    this.hintText,
    this.borderColor,
    this.fillColor,
    this.hintStyle,
    this.alignLabelWithHint,
    this.minLines,
    this.maxLines,
    this.cursorColor,
    this.style,
    this.radius,
    this.onFieldSubmit,
    this.textInputAction,
    this.contentPadding,
  }) : _textInputType = TextInputType.visiblePassword;

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType _textInputType;
  final Function(String value)? onchange;
  final bool obscureText;
  final String obscureCharacter;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool readOnly;
  final void Function()? onTap;
  final void Function(String)? onFieldSubmit;
  final String? hintText;
  final Color? borderColor;
  final Color? fillColor;
  final Color? cursorColor;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final bool? alignLabelWithHint;
  final int? minLines;
  final int? maxLines;
  final double? radius;
  final TextInputAction? textInputAction;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) => Material(
        type: MaterialType.transparency,
        child: TextFormField(
          onFieldSubmitted: onFieldSubmit,
          maxLines: maxLines ?? 1,
          minLines: minLines ?? 1,
          style: style,
          onTap: onTap,
          cursorColor: cursorColor,
          readOnly: readOnly,
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            alignLabelWithHint: alignLabelWithHint,
            fillColor: fillColor ?? IsmLiveColors.white,
            hintText: hintText,
            hintStyle: hintStyle,
            isDense: true,
            contentPadding: contentPadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(IsmLiveDimens.twentyFive),
              borderSide: BorderSide(
                color: borderColor ?? IsmLiveColors.black,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(radius ?? IsmLiveDimens.twentyFive),
              borderSide: BorderSide(
                color: borderColor ?? IsmLiveColors.black,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(radius ?? IsmLiveDimens.twentyFive),
              borderSide: BorderSide(
                color: borderColor ?? IsmLiveColors.black,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(radius ?? IsmLiveDimens.twentyFive),
              borderSide: BorderSide(
                color: borderColor ?? IsmLiveColors.black,
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
          textInputAction: textInputAction,
          obscureText: obscureText,
          obscuringCharacter: obscureCharacter,
          onChanged: onchange,
        ),
      );
}
