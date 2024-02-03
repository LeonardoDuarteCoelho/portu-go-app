import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:portu_go_driver/authenticationScreens/car_info_screen.dart';
import 'package:portu_go_driver/authenticationScreens/login_screen.dart';
import 'package:portu_go_driver/components/button.dart';
import 'package:portu_go_driver/components/progress_dialog.dart';
import 'package:portu_go_driver/constants.dart';
import 'package:portu_go_driver/components/text_input.dart';
import 'package:portu_go_driver/global/global.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 'TextEditingController' is basically what permits us to set text into text fields and get text from them.
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  // Firebase variables:
  late final User? firebaseUser;
  late Map driverMap;
  late DatabaseReference driversRef;

  @override
  void initState() {
    super.initState();
    // Initialize with the country code if not already present:
    phoneTextEditingController.text = AppStrings.ptCountryCode;

    phoneTextEditingController.addListener(() {
      // Setting local variable to store country code:
      const countryCode = AppStrings.ptCountryCode;
      String currentText = phoneTextEditingController.text;

      // If the current text doesn't start with the country code, fix it
      if (!currentText.startsWith(countryCode)) {
        // Prevent the listener from triggering infinite loop
        phoneTextEditingController.removeListener(() {});

        // If user attempts to edit within the country code, reset the cursor and text
        if (currentText.length < countryCode.length) {
          currentText = countryCode;
          phoneTextEditingController.text = currentText;
          phoneTextEditingController.selection = TextSelection.fromPosition(
            TextPosition(offset: currentText.length),
          );
        } else {
          // Correct the text by ensuring the country code is at the start
          final newText = countryCode + currentText.substring(currentText.length - (currentText.length - countryCode.length)).trim();
          phoneTextEditingController.text = newText;
          // Position the cursor correctly
          phoneTextEditingController.selection = TextSelection.fromPosition(
            TextPosition(offset: newText.length),
          );
        }

        // Re-add the listener after corrections
        phoneTextEditingController.addListener(() {});
      }
    });
  }

  showToaster(String string) {
    Fluttertoast.showToast(msg: string);
  }

  setNavigatorPop() {
    Navigator.pop(context);
  }

  navigateToCarInfoScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => const CarInfoScreen()));
  }

  navigateToLogInScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => const LogInScreen()));
  }

  validateForm() {
    if(nameTextEditingController.text.length < 5) {
      showToaster(AppStrings.nameValidationToast);
    } else if(!emailTextEditingController.text.contains('@')) {
      showToaster(AppStrings.emailValidationToast);
    } else if(phoneTextEditingController.text.isEmpty) {
      showToaster(AppStrings.phoneValidationToast);
    } else if(passwordTextEditingController.text.length <= 5) {
      showToaster(AppStrings.passwordValidationToast);
    } else {
      saveDriverInfo();
    }
  }

  saveDriverInfo() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(message: AppStrings.loading);
        }
    );
    firebaseUser = (
        await fAuth.createUserWithEmailAndPassword(
          // '.trim()' makes so that if the user inserts extra space at the end by accident, it won't count.
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim()
        ).catchError((msg) /* 'msg' will be the error message */ {
          setNavigatorPop();
          showToaster('Error: $msg');
        })
    ).user;
    // If the user has been created successfully...
    if(firebaseUser != null) {
      driverMap = {
        'id': firebaseUser?.uid, // '.uid' sets the unique user ID for the driver.
        'name': nameTextEditingController.text.trim(),
        'email': emailTextEditingController.text.trim(),
        'phone': phoneTextEditingController.text.trim(),
      };
      // Saving the driver information to the database:
      driversRef = FirebaseDatabase.instance.ref().child('drivers');
      driversRef.child(firebaseUser!.uid).set(driverMap);
      // Going forward with the creating account process:
      currentFirebaseUser = firebaseUser;
      showToaster(AppStrings.accountCreated);
      navigateToCarInfoScreen();
    } else {
      setNavigatorPop();
      showToaster(AppStrings.errorAccountNotCreated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      // For getting the driver's data from the multiples text fields:
      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('images/pexels-tobi-620332.jpg'),
              Padding(
                  padding: const EdgeInsets.all(AppSpaceValues.space3),
                  child: Column(
                    children: [
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
                          height: AppLineHeights.ml,
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

                      // Sign up button:
                      CustomButton(
                          text: AppStrings.createAccountButton,
                          onPressed: () {
                            validateForm();
                          }
                      ),

                      const SizedBox(height: AppSpaceValues.space3),

                      // Log in button:
                      CustomButton(
                          text: AppStrings.alreadyCreatedAccountButton,
                          backgroundColor: AppColors.gray2,
                          textColor: AppColors.gray9,
                          onPressed: () {
                            validateForm();
                            navigateToLogInScreen();
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
