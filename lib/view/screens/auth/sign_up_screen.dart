import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:country_code_picker/country_code.dart';
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/body/signup_body.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/view/base/web_menu_bar.dart';
import 'package:efood_multivendor/view/screens/auth/widget/condition_check_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phone_number/phone_number.dart';

class SignUpScreen extends StatefulWidget {
  final String phone;
  SignUpScreen({@required this.phone});
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _countryDialCode;
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();

    _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel.country).dialCode;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? WebMenuBar() : null,
      body: SafeArea(child: Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          physics: BouncingScrollPhysics(),
          child: Center(
            child: Container(
              width: context.width > 700 ? 700 : context.width,
              padding: context.width > 700 ? EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT) : null,
              decoration: context.width > 700 ? BoxDecoration(
                color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300], blurRadius: 5, spreadRadius: 1)],
              ) : null,
              child: GetBuilder<AuthController>(builder: (authController) {

                return Column(children: [

                  Image.asset(Images.sign_up, width: context.width*0.5,),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),

                  Text('sign_up'.tr.toUpperCase(), style: robotoBlack.copyWith(fontSize: 30)),
                  SizedBox(height: 50),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 1, blurRadius: 5)],
                    ),
                    child: Column(children: [

                      CustomTextField(
                        hintText: 'first_name'.tr,
                        controller: _firstNameController,
                        focusNode: _firstNameFocus,
                        nextFocus: _lastNameFocus,
                        inputType: TextInputType.name,
                        capitalization: TextCapitalization.words,
                        prefixIcon: Images.user,
                        divider: true,
                      ),

                      CustomTextField(
                        hintText: 'last_name'.tr,
                        controller: _lastNameController,
                        focusNode: _lastNameFocus,
                        nextFocus: _emailFocus,
                        inputType: TextInputType.name,
                        capitalization: TextCapitalization.words,
                        prefixIcon: Images.user,
                        divider: true,
                      ),

                      CustomTextField(
                        hintText: 'Email (Optional)',
                        controller: _emailController,
                        focusNode: _emailFocus,
                        inputType: TextInputType.emailAddress,
                        prefixIcon: Images.mail,
                        divider: true,
                      ),

                      // Row(children: [
                      //   CodePickerWidget(
                      //     onChanged: (CountryCode countryCode) {
                      //       _countryDialCode = countryCode.dialCode;
                      //     },
                      //     initialSelection: _countryDialCode,
                      //     favorite: [_countryDialCode],
                      //     showDropDownButton: true,
                      //     padding: EdgeInsets.zero,
                      //     showFlagMain: true,
                      //     textStyle: robotoRegular.copyWith(
                      //       fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyText1.color,
                      //     ),
                      //   ),
                      //   Expanded(child: CustomTextField(
                      //     hintText: 'phone'.tr,
                      //     controller: _phoneController,
                      //     focusNode: _phoneFocus,
                      //     nextFocus: _passwordFocus,
                      //     inputType: TextInputType.phone,
                      //     divider: false,
                      //   )),
                      // ]),
                      Padding(padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE), child: Divider(height: 1)),

                      // CustomTextField(
                      //   hintText: 'password'.tr,
                      //   controller: _passwordController,
                      //   focusNode: _passwordFocus,
                      //   nextFocus: _confirmPasswordFocus,
                      //   inputType: TextInputType.visiblePassword,
                      //   prefixIcon: Images.lock,
                      //   isPassword: true,
                      //   divider: true,
                      // ),
                      //
                      // CustomTextField(
                      //   hintText: 'confirm_password'.tr,
                      //   controller: _confirmPasswordController,
                      //   focusNode: _confirmPasswordFocus,
                      //   inputAction: TextInputAction.done,
                      //   inputType: TextInputType.visiblePassword,
                      //   prefixIcon: Images.lock,
                      //   isPassword: true,
                      //   onSubmit: (text) => (GetPlatform.isWeb && authController.acceptTerms) ? _register(authController, _countryDialCode) : null,
                      // ),

                    ]),
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                  ConditionCheckBox(authController: authController),
                  SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                  !authController.isLoading ? CustomButton(
                    buttonText: 'sign_up'.tr,
                    onPressed:(){
                      if(authController.acceptTerms) {
                        print('true');
                        _register(authController, _countryDialCode);
                      }
                      else
                        print('false');
                    }
                  ): Center(child: CircularProgressIndicator()),
                  SizedBox(height: 30),

                ]);
              }),
            ),
          ),
        ),
      )),
    ),
        onWillPop: () async {
          if(true) {
            if (_canExit) {
              if (GetPlatform.isAndroid) {
                SystemNavigator.pop();
              } else if (GetPlatform.isIOS) {
                exit(0);
              } else {
                // Navigator.pushNamed(context, RouteHelper.getInitialRoute());
              }
              return Future.value(false);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('back_press_again_to_exit'.tr, style: TextStyle(color: Colors.white)),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
                margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              ));
              _canExit = true;
              Timer(Duration(seconds: 2), () {
                _canExit = false;
              });
              return Future.value(false);
            }
          }else {
            return true;
          }
        });
  }

  void _register(AuthController authController, String countryCode) async {
    String _firstName = _firstNameController.text.trim();
    String _lastName = _lastNameController.text.trim();
    String _email = _emailController.text.trim();
    String _number = widget.phone;

    String _numberWithCountryCode = '+91'+_number;
    bool _isValid = GetPlatform.isWeb ? true : false;
     if(!GetPlatform.isWeb) {
       try {
         PhoneNumber phoneNumber = await PhoneNumberUtil().parse(_numberWithCountryCode);
         _numberWithCountryCode = '+' + phoneNumber.countryCode + phoneNumber.nationalNumber;
         _isValid = true;
       } catch (e) {}
     }

    if (_firstName.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr);
    }else if (_lastName.isEmpty) {
      showCustomSnackBar('enter_your_last_name'.tr);
    }else if(_email.isNotEmpty){
      if (!GetUtils.isEmail(_email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    }}else if (_number.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (!_isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    }else if (_email.isEmpty) {
    _email = '$_number@noMail.com';
    }
      SignUpBody signUpBody = SignUpBody(fName: _firstName, lName: _lastName, email: _email,phone: _numberWithCountryCode , tokenKey : AppConstants.TOKEN_KEY);
      authController.registration(signUpBody).then((status) async {
        if (status.isSuccess) {
          if(!Get.find<SplashController>().configModel.customerVerification ) {
            List<int> _encoded = utf8.encode(AppConstants.TOKEN_KEY);
            String _data = base64Encode(_encoded);
            Get.toNamed(RouteHelper.getVerificationRoute(_numberWithCountryCode, status.message, RouteHelper.signUp, _data));
          }else {
            Get.toNamed(RouteHelper.getAccessLocationRoute(RouteHelper.signUp));
          }
        }else {
          print("invalid  : ");
          showCustomSnackBar(status.message);
        }
      });

  }
}
