import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget(
      {Key? key,
      this.keyboardType = TextInputType.none,
      this.textCapitalization = TextCapitalization.none,
      this.autoCorrect = false,
      required this.hintText,
      this.obscureText = false,
      this.prefixIconData,
      this.suffixIconData = Icons.abc,
      this.useSuffixIcon = false,
      required this.controller,
      this.validator})
      : super(key: key);

  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final bool autoCorrect;
  final String hintText;
  final bool obscureText;
  final IconData? prefixIconData;
  final IconData? suffixIconData;
  final bool useSuffixIcon;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autocorrect: autoCorrect,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(2),
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(), borderRadius: BorderRadius.circular(50)),
        prefixIcon: Icon(
          prefixIconData,
          size: 35,
        ),
        suffixIcon:
            useSuffixIcon == true ? Icon(suffixIconData, size: 35) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
      ),
    );
  }
}
