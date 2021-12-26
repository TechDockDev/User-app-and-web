import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/web_menu_bar.dart';
import 'package:efood_multivendor/view/screens/auth/widget/guest_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  SignInScreen({@required this.exitFromApp});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _canExit = GetPlatform.isWeb ? true : false;
  String phoneNo;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  AuthController authController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _contactEditingController = TextEditingController();
  final _OTPEditingController = TextEditingController();
  String phoneNoWithoutCode;
  bool showLoading = false;
  MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;
  double screenHeight;
  double screenWidth;

  int start = 30;
  bool wait = false;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        if (widget.exitFromApp) {
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
              content: Text('back_press_again_to_exit'.tr,
                  style: TextStyle(color: Colors.white)),
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
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? WebMenuBar()
            : !widget.exitFromApp
                ? AppBar(
                    leading: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.arrow_back_ios_rounded,
                          color: Theme.of(context).textTheme.bodyText1.color),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent)
                : null,
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 8,
                  ),
                  Image.asset(
                    'assets/image/otp.png',
                    //height: screenHeight * 0.3,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  showLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : currentState ==
                              MobileVerificationState.SHOW_MOBILE_FORM_STATE
                          ? getMobileFormWidget(context)
                          : getOtpFormWidget(context),
                  GuestButton()
                ]),
          ),
        ),
      ),
    );
  }

  getMobileFormWidget(context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: Colors.white,
          // ignore: prefer_const_literals_to_create_immutables
          boxShadow: [
            const BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
          borderRadius: BorderRadius.circular(16.0)),
      child: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.02,
          ),
          const Text(
            'Enter your mobile number',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 253, 188, 51),
              ),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Row(
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                const Text('+91'),
                SizedBox(
                  width: screenWidth * 0.01,
                ),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Contact Number',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 13.5),
                    ),
                    controller: _contactEditingController,
                    keyboardType: TextInputType.number,
                    // inputFormatters: [LengthLimitingTextInputFormatter(10)],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              clickOnLogin(context);
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 253, 188, 51),
                borderRadius: BorderRadius.circular(36),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Send OTP',
                style: TextStyle(color: Colors.black, fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getOtpFormWidget(context) {
    // setState(() {
    //   wait=false;
    //   start = 30;
    // });
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: Colors.white,
          // ignore: prefer_const_literals_to_create_immutables
          boxShadow: [
            const BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
          borderRadius: BorderRadius.circular(16.0)),
      child: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.02,
          ),
          const Text(
            'Enter OTP',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          PinCodeTextField(
            length: 6,
            obscureText: false,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(5),
              fieldHeight: 50,
              fieldWidth: 40,
              activeFillColor: Colors.white,
              inactiveFillColor: Colors.white,
              selectedFillColor: Colors.white,
              activeColor: Theme.of(context).primaryColor,
              selectedColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(context).disabledColor,
            ),
            enableActiveFill: true,
            keyboardType: TextInputType.number,
            onCompleted: (v) {
              print("Completed");
            },
            onChanged: (value) {
              print(value);
              setState(() {
                smsOTP = value;
              });
            },
            beforeTextPaste: (text) {
              print("Allowing to paste $text");
              //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
              //but you can show anything you want here, like your pop up saying wrong paste format or etc
              return true;
            },
            appContext: context,
          ),
          wait ? resendButtonText(context) : resendTimerText(),
          const SizedBox(
            height: 20,
          ),
          GetBuilder<AuthController>(builder: (_authController) {
            return GestureDetector(
              onTap: () {
                verifyOtp(_authController);
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 253, 188, 51),
                  borderRadius: BorderRadius.circular(36),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Verify OTP',
                  style: TextStyle(color: Colors.black, fontSize: 16.0),
                ),
              ),
            );
          })
        ],
      ),
    );
  }

  //Login click with contact number validation
  Future<void> clickOnLogin(BuildContext context) async {
    print('click login');
    setState(() {
      showLoading = true;
    });

    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      setState(() {
        showLoading = false;
        currentState = MobileVerificationState.SHOW_OTP_FORM_STATE;
        this.verificationId = verificationId;
      });
      startTimer();
      verificationId = verId;
      print('code sent');
    };
    if (_contactEditingController.text.isEmpty) {
      setState(() {
        showLoading = false;
        currentState = MobileVerificationState.SHOW_MOBILE_FORM_STATE;
      });
      showErrorDialog(context, 'Contact number can\'t be empty.');
    } else {
      phoneNo = '+91${_contactEditingController.text}';
      print('phone $phoneNo');
      try {
        var res = await _auth.verifyPhoneNumber(
            phoneNumber: phoneNo,
            codeAutoRetrievalTimeout: (String verId) {
              verificationId = verId;
            },
            codeSent: smsOTPSent,
            timeout: const Duration(seconds: 30),
            verificationCompleted: (AuthCredential phoneAuthCredential) {
              setState(() {
                showLoading = false;
              });
            },
            verificationFailed: (FirebaseAuthException exception) {
              setState(() {
                showLoading = false;
              });
              print('ex : ${exception.message}');
              Navigator.pop(context, exception.message);
            });
      } on PlatformException catch (e) {
        print('ex1');
        debugPrint(e.toString());
      } on FirebaseAuthException catch (e) {
        print('ex2');
        debugPrint(e.toString());
      }
    }
    print('uji1R');
  }

  //Alert dialogue to show error and response
  void showErrorDialog(BuildContext context, String message) {
    // set up the AlertDialog
    final CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: const Text('Error'),
      content: Text('\n$message'),
      actions: <Widget>[
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //Method for verify otp entered by user
  Future<void> verifyOtp(AuthController authController) async {
    if (smsOTP == null || smsOTP == '') {
      showAlertDialog(context, 'please enter 6 digit otp');
      return;
    }
    setState(() {
      showLoading = true;
    });
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      final UserCredential user = await _auth.signInWithCredential(credential);
      final User currentUser = _auth.currentUser;
      assert(user.user.uid == currentUser.uid);

      authController
          .login(phoneNo, AppConstants.TOKEN_KEY)
          .then((status) async {
        if (status.isSuccess) {
          setState(() {
            showLoading = false;
          });
          if (authController.isActiveRememberMe) {
            authController.saveUserNumberAndPassword(phoneNo,
                AppConstants.TOKEN_KEY, AppConstants.COUNTRY_CODE_INDIA);
          } else {
            authController.clearUserNumberAndPassword();
          }
          String _token = status.message.substring(1, status.message.length);
          if (Get.find<SplashController>().configModel.customerVerification &&
              int.parse(status.message[0]) == 0) {
            List<int> _encoded = utf8.encode(AppConstants.TOKEN_KEY);
            String _data = base64Encode(_encoded);
            Get.toNamed(RouteHelper.getVerificationRoute(
                phoneNo, _token, RouteHelper.signUp, _data));
          } else {
            Get.toNamed(RouteHelper.getAccessLocationRoute('sign-in'));
          }
        } else {
          setState(() {
            showLoading = false;
          });
          if (status.message == 'Unauthorized.')
            Get.toNamed(
                RouteHelper.getSignUpRoute(_contactEditingController.text));
          //showCustomSnackBar(status.message);
        }
      });
    } catch (e) {
      setState(() {
        showLoading = false;
        currentState = MobileVerificationState.SHOW_MOBILE_FORM_STATE;
      });
      handleError(e as FirebaseException);
    }
  }

  //Method for handle the errors
  void handleError(FirebaseException error) {
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        showAlertDialog(context, 'Invalid Code');
        break;
      default:
        showAlertDialog(context, error.message);
        break;
    }
  }

  //Basic alert dialogue for alert errors and confirmations
  void showAlertDialog(BuildContext context, String message) {
    // set up the AlertDialog
    final CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: const Text('Error'),
      content: Text('\n$message'),
      actions: <Widget>[
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void startTimer() {
    const onsec = Duration(seconds: 1);
    Timer _timer = Timer.periodic(onsec, (timer) {
      if (start == 0) {
        setState(() {
          timer.cancel();
          wait = true;
        });
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  Widget resendTimerText() {
    return RichText(
        text: TextSpan(
      children: [
        TextSpan(
          text: "Send OTP again in ",
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        TextSpan(
          text: "00:$start",
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
        TextSpan(
          text: " sec ",
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    ));
  }

  Widget resendButtonText(BuildContext context) {
    return Container(
      width: context.width,
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
            onTap: () {
              clickOnLogin(context);
              showAlertDialog(context, "OTP Sent");
              setState(() {
                currentState = MobileVerificationState.SHOW_OTP_FORM_STATE;
                wait = false;
                start = 59;
              });
            },
            child: Text('Resend OTP')),
      ),
    );
  }
}

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}
