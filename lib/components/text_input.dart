import 'package:flutter/material.dart';
import 'package:portu_go_driver/constants.dart';

class CustomTextInput extends StatelessWidget  {
  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextInputAction textInputAction;
  final Function(String)? onSubmitted;

  const CustomTextInput({
    Key? key,
    required this.hintText,
    required this.labelText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        color: AppColors.gray9,
        fontSize: AppFontSizes.ml,
        fontWeight: AppFontWeights.regular,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: AppColors.gray9,
          fontSize: AppFontSizes.m,
          fontWeight: AppFontWeights.regular,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.gray5,
          fontSize: AppFontSizes.ml,
          fontWeight: AppFontWeights.regular,
        ),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.gray9)
        ),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.gray9)
        ),
      ),
    );
  }
}
