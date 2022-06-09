import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    Key? key,
    required this.hintInfo,
    required this.labelInfo,
    this.textController,
    this.inputType,
    this.noPadding = false,
    required this.obscure,
    this.submitCallback,
    this.autocorrect = true,
    this.minLines,
    this.maxLines,
  }) : super(key: key);
  final String hintInfo;
  final String labelInfo;
  final bool obscure;
  final bool noPadding;
  final int? minLines;
  final int? maxLines;
  final TextEditingController? textController;
  final TextInputType? inputType;
  final void Function(String)? submitCallback;
  final bool autocorrect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: noPadding ? 0 : 20,
      ),
      child: TextFormField(
        minLines: obscure ? 1 : minLines,
        maxLines: obscure ? 1 : maxLines,
        onFieldSubmitted: submitCallback,
        controller: textController,
        decoration: InputDecoration(
          hintText: hintInfo,
          labelText: labelInfo,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value != null && value.isEmpty) {
            return "Please fill in $labelInfo";
          } else {
            return null;
          }
        },
        keyboardType: inputType,
        obscureText: obscure,
        autocorrect: autocorrect,
      ),
    );
  }
}
