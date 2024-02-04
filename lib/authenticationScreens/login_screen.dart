import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:portu_go_driver/authenticationScreens/signup_screen.dart';
import 'package:portu_go_driver/components/text_input.dart';
import 'package:portu_go_driver/constants.dart';
import 'package:portu_go_driver/mainScreens/main_screen.dart';
import 'package:portu_go_driver/splashScreen/splash_screen.dart';

import '../components/button.dart';
import '../components/progress_dialog.dart';
import '../global/global.dart';
import 'car_info_screen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  // Firebase variables:
  late final User? firebaseUser;

  navigateToSplashScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => const SplashScreen()));
  }

  showToaster(String string) {
    Fluttertoast.showToast(msg: string);
  }

  setNavigatorPop() {
    Navigator.pop(context);
  }

  validateForm() {
    if(emailTextEditingController.text.isEmpty) {
      showToaster(AppStrings.mustEnterEmail);
    } else if(passwordTextEditingController.text.isEmpty) {
      showToaster(AppStrings.mustEnterPassword);
    } else if(passwordTextEditingController.text.isEmpty && emailTextEditingController.text.isEmpty) {
      showToaster(AppStrings.mustEnterEmailAndPassword);
    } else {
      checkCredentialsForLogIn();
    }
  }

  checkCredentialsForLogIn() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(message: AppStrings.loading);
        }
    );
    firebaseUser = (
      await fAuth.signInWithEmailAndPassword(
        // '.trim()' makes so that if the user inserts extra space at the end by accident, it won't count.
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim()
      ).catchError((msg) /* 'msg' will be the error message */ {
        setNavigatorPop();
        showToaster(AppStrings.logInError);
      })
    ).user;
    // If the user has been created successfully...
    if(firebaseUser != null) {
      // Going forward with the log in process:
      currentFirebaseUser = firebaseUser;
      showToaster(AppStrings.logInSuccessful);
      navigateToSplashScreen();
    } else {
      setNavigatorPop();
      showToaster(AppStrings.logInError);
    }
  }

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
                        validateForm();
                      }
                  ),

                  const SizedBox(height: AppSpaceValues.space3),

                  CustomButton(
                      text: AppStrings.dontHaveAccountButton,
                      backgroundColor: AppColors.gray2,
                      textColor: AppColors.gray9,
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
