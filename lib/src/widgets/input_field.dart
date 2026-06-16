import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.focusNode,
    this.inputFormatters,
    this.maxLength,
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
    this.focusNode,
    this.inputFormatters,
    this.maxLength,
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
    this.focusNode,
    this.inputFormatters,
    this.maxLength,
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
    this.focusNode,
    this.inputFormatters,
    this.maxLength,
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
  final int? maxLength;
  final double? radius;
  final TextInputAction? textInputAction;
  final EdgeInsets? contentPadding;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) => Material(
        type: MaterialType.transparency,
        child: TextFormField(
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmit,
          maxLines: maxLines ?? 1,
          minLines: minLines,
          style: style ??
              TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? context.liveTheme?.selectedTextColor ?? Colors.white
                    : Colors.black,
              ),
          onTap: onTap,
          cursorColor: cursorColor ??
              (Theme.of(context).brightness == Brightness.dark
                  ? context.liveTheme?.primaryColor ?? Colors.white
                  : IsmLiveColors.black),
          readOnly: readOnly,
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            alignLabelWithHint: alignLabelWithHint,
            fillColor: fillColor ??
                (Theme.of(context).brightness == Brightness.dark
                    ? context.liveTheme?.cardBackgroundColor ??
                        const Color(0xFF1E1E1E)
                    : IsmLiveColors.white),
            hintText: hintText,
            hintStyle: hintStyle ??
                TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? context.liveTheme?.unselectedTextColor ??
                          Colors.grey[400]
                      : Colors.grey[600],
                ),
            isDense: true,
            contentPadding: contentPadding,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(radius ?? IsmLiveDimens.twentyFive),
              borderSide: BorderSide(
                color: borderColor ??
                    (Theme.of(context).brightness == Brightness.dark
                        ? context.liveTheme?.borderColor ??
                            const Color(0xFF1E1E1E)
                        : IsmLiveColors.black),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(radius ?? IsmLiveDimens.twentyFive),
              borderSide: BorderSide(
                color: borderColor ??
                    (Theme.of(context).brightness == Brightness.dark
                        ? context.liveTheme?.borderColor ??
                            const Color(0xFF1E1E1E)
                        : IsmLiveColors.black),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(radius ?? IsmLiveDimens.twentyFive),
              borderSide: BorderSide(
                color: borderColor ??
                    context.liveTheme?.primaryColor ??
                    (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : IsmLiveColors.black),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(radius ?? IsmLiveDimens.twentyFive),
              borderSide: BorderSide(
                color: borderColor ?? IsmLiveColors.red,
                width: 1,
              ),
            ),
            counterText: '',
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 38,
              minHeight: 38,
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 38,
              minHeight: 38,
            ),
          ),
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: _textInputType,
          textInputAction: textInputAction ??
              ((maxLines ?? 1) == 1 && onFieldSubmit != null
                  ? TextInputAction.send
                  : null),
          obscureText: obscureText,
          obscuringCharacter: obscureCharacter,
          onChanged: onchange,
        ),
      );
}
