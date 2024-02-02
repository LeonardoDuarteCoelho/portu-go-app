import 'package:flutter/material.dart';
import 'package:portu_go_driver/constants.dart';

class ProgressDialog extends StatelessWidget {
  String? message;
  ProgressDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpaceValues.space3)
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpaceValues.space3),
          child: Row(
            children: [
              const SizedBox(width: AppSpaceValues.space1),

              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.indigo7),
              ),

              const SizedBox(width: AppSpaceValues.space4),

              Text(
                message!,
                style: const TextStyle(
                  color: AppColors.gray7,
                  fontSize: AppFontSizes.m,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
