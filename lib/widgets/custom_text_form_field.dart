import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {Key? key,
      required this.hintInfo,
      required this.labelInfo,
      this.textController,
      this.inputType,
      required this.obscure})
      : super(key: key);
  final String hintInfo;
  final String labelInfo;
  final TextEditingController? textController;
  final TextInputType? inputType;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20,
      ),
      child: TextFormField(
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
      ),
    );
  }
}
