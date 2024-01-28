import 'package:flutter/material.dart';
import 'package:portu_go_driver/authenticationScreens/car_info_screen.dart';
import 'package:portu_go_driver/components/button.dart';
import 'package:portu_go_driver/constants.dart';
import 'package:portu_go_driver/components/text_input.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 'TextEditingController' is basically what permits us to set text, via code, into text fields.
  TextEditingController nameTextEditingController     = TextEditingController();
  TextEditingController emailTextEditingController    = TextEditingController();
  TextEditingController phoneTextEditingController    = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      // For getting the driver's data from the multiples text fields:
      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('images/pexels-hassan-ouajbir-804128.jpg'),
              Padding(
                  padding: const EdgeInsets.all(AppSpaceValues.space3),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpaceValues.space1),

                      const Text(
                        AppStrings.welcomeMessage,
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
                        AppStrings.signingUpAsDriverMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppFontFamilies.primaryFont,
                          fontSize: AppFontSizes.ml,
                          fontWeight: AppFontWeights.regular,
                          color: AppColors.gray9,
                          height: AppLineHeights.m,
                        ),
                      ),

                      // --> Driver's name:
                      CustomTextInput(
                        controller: nameTextEditingController,
                        labelText: AppStrings.nameTextField,
                        hintText: AppStrings.nameTextField,
                      ),

                      // --> Driver's email:
                      CustomTextInput(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        labelText: AppStrings.emailTextField,
                        hintText: AppStrings.emailTextField,
                      ),

                      // --> Driver's phone number:
                      CustomTextInput(
                        controller: phoneTextEditingController,
                        keyboardType: TextInputType.phone,
                        labelText: AppStrings.phoneTextField,
                        hintText: AppStrings.phoneTextField,
                      ),

                      // --> Driver's password:
                      CustomTextInput(
                        controller: passwordTextEditingController,
                        labelText: AppStrings.passwordTextField,
                        hintText: AppStrings.passwordTextField,
                        obscureText: true,
                      ),

                      const SizedBox(height: AppSpaceValues.space5),

                      CustomButton(
                          text: AppStrings.submitDataButton,
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (c) => const CarInfoScreen()));
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
