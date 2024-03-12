import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portu_go_driver/components/button.dart';
import 'package:portu_go_driver/constants.dart';

class FareAmountCollectionDialog extends StatefulWidget {
  double? tripPrice;
  FareAmountCollectionDialog({super.key, this.tripPrice});

  @override
  State<FareAmountCollectionDialog> createState() => _FareAmountCollectionDialogState();
}

class _FareAmountCollectionDialogState extends State<FareAmountCollectionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpaceValues.space5),
      ),
      backgroundColor: AppColors.transparent,
      child: Container(
        margin: const EdgeInsets.all(AppSpaceValues.space1),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter, // Gradient begins at the top
            end: Alignment.bottomCenter, // And ends at the bottom
            colors: [
              AppColors.indigo7,
              AppColors.indigo5,
              AppColors.indigo7
            ],
          ),
          // color: AppColors.indigo7,
          borderRadius: BorderRadius.circular(AppSpaceValues.space5),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: AppSpaceValues.space3,
            right: AppSpaceValues.space1,
            bottom: AppSpaceValues.space3,
            left: AppSpaceValues.space1,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                AppStrings.niceEarningText,
                style: TextStyle(
                  fontWeight: AppFontWeights.semiBold,
                  color: AppColors.white,
                  fontSize: AppFontSizes.l,
                ),
              ),

              const SizedBox(height: AppSpaceValues.space3),

              Text(
                '${widget.tripPrice!} ${AppStrings.euroSymbol}',
                style: const TextStyle(
                  fontWeight: AppFontWeights.bold,
                  color: AppColors.white,
                  fontSize: AppFontSizes.xxxxl,
                ),
              ),

              const SizedBox(height: AppSpaceValues.space3),

              CustomButton(
                text: AppStrings.collectMoney,
                icon: Icons.credit_card,
                backgroundColor: AppColors.success3,
                textColor: AppColors.black,
                onPressed: () {
                  Future.delayed(const Duration(seconds: 2), () {
                    SystemNavigator.pop();
                  });
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
