import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    Key? key,
    required this.hintInfo,
    required this.labelInfo,
  }) : super(key: key);
  final String hintInfo;
  final String labelInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20,
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hintInfo,
          labelText: labelInfo,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value != null && value.isEmpty) {
            return "Please enter some textahh";
          }
          return null;
        },
      ),
    );
  }
}
