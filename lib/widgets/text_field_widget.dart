import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
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
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      controller: widget.controller,
      obscureText:
          widget.obscureText != true ? widget.obscureText : _obscureText,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      autocorrect: widget.autoCorrect,
      decoration: InputDecoration(
        prefixIconColor: Color(0xFFE38B29),
        contentPadding: EdgeInsets.all(10),
        hintText: widget.hintText,
        prefixIcon: Icon(
          widget.prefixIconData,
          size: 35,
        ),
        suffixIcon: widget.useSuffixIcon == true
            ? GestureDetector(
                onTap: () {
                  print("basıldı");
                  setState(() {
                    print(_obscureText);
                    _obscureText = !_obscureText;
                    print(_obscureText);
                  });
                },
                child: Icon(
                    _obscureText == true
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 35),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
      ),
    );
  }
}
