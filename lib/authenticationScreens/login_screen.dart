import 'package:flutter/material.dart';
import 'package:portu_go_driver/authenticationScreens/signup_screen.dart';
import 'package:portu_go_driver/components/text_input.dart';
import 'package:portu_go_driver/constants.dart';

import '../components/button.dart';
import 'car_info_screen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('images/pexels-peter-fazekas-1386649.jpg'),
            Padding(
              padding: const EdgeInsets.all(AppSpaceValues.space3),
              child: Column(
                children: [
                  const Text(
                    AppStrings.welcomeBackMessage,
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
                    AppStrings.logInIntoYourAccount,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFontFamilies.primaryFont,
                      fontSize: AppFontSizes.ml,
                      fontWeight: AppFontWeights.regular,
                      color: AppColors.gray9,
                      height: AppLineHeights.ml,
                    ),
                  ),

                  // --> Driver's email:
                  CustomTextInput(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    labelText: AppStrings.emailTextField,
                    hintText: AppStrings.emailTextField,
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
                      text: AppStrings.enterAccountButton,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => const SignUpScreen()));
                      }
                  ),

                  const SizedBox(height: AppSpaceValues.space3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
