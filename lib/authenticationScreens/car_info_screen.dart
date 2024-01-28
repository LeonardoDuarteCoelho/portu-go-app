import 'package:flutter/material.dart';
import 'package:portu_go_driver/authenticationScreens/signup_screen.dart';
import 'package:portu_go_driver/components/text_input.dart';
import 'package:portu_go_driver/constants.dart';

import '../components/button.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key});

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  // 'TextEditingController' is basically what permits us to set text, via code, into text fields.
  TextEditingController carModelTextEditingController  = TextEditingController();
  TextEditingController carNumberTextEditingController = TextEditingController();
  TextEditingController carColorTextEditingController  = TextEditingController();

  // Car types for the driver to choose:
  List<String> carTypesList = [
    'Prime', // For SUVs or minivans; minimum of 6 seats and lots os space for baggage.
    'GO', // PortuGO's standard ride; 2 to 4 seats and may or may not have a trunk.
  ];
  String? selectedCarType;
  Map<String, String> carTypeExplanations = {
    'Prime': AppStrings.carPrimeExplanation,
    'GO': AppStrings.carGoExplanation,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      // For getting the driver's car info from the multiples text fields:
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('images/pexels-peter-fazekas-1386649.jpg'),
            Padding(
              padding: const EdgeInsets.all(AppSpaceValues.space3),
              child: Column(
                children: [
                  const SizedBox(height: AppSpaceValues.space1),

                  const Text(
                    AppStrings.greetingsUserMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFontFamilies.primaryFont,
                      fontSize: AppFontSizes.xl,
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.indigo7,
                      height: AppLineHeights.ml,
                    ),
                  ),

                  const SizedBox(height: AppSpaceValues.space3),

                  const Text(
                    AppStrings.insertCarInfoMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFontFamilies.primaryFont,
                      fontSize: AppFontSizes.ml,
                      fontWeight: AppFontWeights.regular,
                      color: AppColors.gray9,
                      height: AppLineHeights.m,
                    ),
                  ),

                  // --> Driver's car model:
                  CustomTextInput(
                    controller: carModelTextEditingController,
                    labelText: AppStrings.carModelTextField,
                    hintText: AppStrings.carModelTextField,
                  ),

                  // --> Driver's car model:
                  CustomTextInput(
                    controller: carNumberTextEditingController,
                    labelText: AppStrings.carNumberTextField,
                    hintText: AppStrings.carNumberTextField,
                  ),

                  // --> Driver's car model:
                  CustomTextInput(
                    controller: carColorTextEditingController,
                    labelText: AppStrings.carColorTextField,
                    hintText: AppStrings.carColorTextField,
                  ),

                  const SizedBox(height: AppSpaceValues.space3),

                  // --> Driver's car type (check string array 'carTypesList'):
                  DropdownButton(
                    iconDisabledColor: AppColors.gray3,
                    iconEnabledColor: AppColors.gray9,
                    iconSize: 30,
                    underline: Container(
                      height: 1,
                      color: AppColors.gray9,
                    ),
                    style: const TextStyle(
                      fontSize: AppFontSizes.m,
                      color: AppColors.gray9,
                    ),
                    hint: const Text(
                        AppStrings.carTypeDropdownHint,
                        style: TextStyle(
                          fontSize: AppFontSizes.m,
                          color: AppColors.gray9,
                        ),
                    ),
                    value: selectedCarType,
                    items: carTypesList.map((carType){
                      return DropdownMenuItem(
                        value: carType,
                        child: Text(
                          carType,
                          style: const TextStyle(
                              fontSize: AppFontSizes.ml,
                              color: AppColors.gray9
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCarType = newValue.toString();
                      });
                    }
                  ),

                  if (selectedCarType != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        carTypeExplanations[selectedCarType] ?? '', // Display the explanation
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: AppFontSizes.m,
                          height: AppLineHeights.m,
                          color: AppColors.gray9,
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSpaceValues.space3),

                  CustomButton(
                      text: AppStrings.createAccountButton,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => const SignUpScreen()));
                      }
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
