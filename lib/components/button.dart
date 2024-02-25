import 'package:flutter/material.dart';
import 'package:portu_go_driver/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? btnContentSize;
  final IconData? icon; // New parameter for icon

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.indigo7,
    this.textColor = AppColors.white,
    this.btnContentSize = AppFontSizes.ml,
    this.icon, // Initialize the new parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: AppSpaceValues.space4, vertical: AppSpaceValues.space2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpaceValues.space9),
          side: BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Ensures the Row only takes up necessary space
        children: [
          if(icon != null) Icon(icon, size: btnContentSize), // Conditional icon
          if(icon != null) const SizedBox(width: AppSpaceValues.space2), // Space between icon and text
          Text(
            text,
            style: TextStyle(
              fontSize: btnContentSize,
            ),
          ),
        ],
      ),
    );
  }
}