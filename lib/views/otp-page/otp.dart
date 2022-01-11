import 'package:flutter/material.dart';
import 'package:mario_provider/utils/snack_util.dart';
import 'package:mario_provider/common/base.dart';
import 'package:mario_provider/imported/package/OTP_field/otp_field.dart';
import 'package:mario_provider/imported/package/OTP_field/style.dart';
import 'package:mario_provider/repositories/authentication/login_repo.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:mario_provider/views/dashboard/dashboard.dart';

class OtpPage extends StatefulWidget {
  final String mobile;
  final int userId;

  const OtpPage(this.mobile, this.userId);

  @override
  State<StatefulWidget> createState() {
    return OtpPageState();
  }
}

class OtpPageState extends State<OtpPage> {
  final LoginRepo _loginRepo = new LoginRepo();
  final SharedReferences references = new SharedReferences();
  String phoneNumber;

  String otpText;

  bool enabled = false;
  List<TextEditingController> listOfTextEditingController =
      List<TextEditingController>.filled(6, null, growable: false);

  @override
  void initState() {
    this.phoneNumber = widget.mobile;
    super.initState();
  }

  @override
  void dispose() {
    listOfTextEditingController.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),
              Text(
                'We have sent an OTP to\nyour Email',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 25,
                  color: const Color(0xff4a4b4d),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 50,
              ),
              Text(
                'Please check your mobile number $phoneNumber \ncontinue to reset your password',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 14,
                  color: const Color(0xff7c7d7e),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                textHeightBehavior:
                    TextHeightBehavior(applyHeightToFirstAscent: false),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 50,
              ),
              OTPTextField(
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: MediaQuery.of(context).size.width / 6,
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  textFieldAlignment: MainAxisAlignment.spaceEvenly,
                  fieldStyle: FieldStyle.box,
                  onCompleted: (pin) {
                    print('this is otp: $pin');
                    enabled = true;
                    otpText = pin;
                  },
                  onChanged: (pin) {
                    print('this is otp: $pin');
                    if (pin.length == 6) {
                      setState(() {
                        enabled = true;
                      });
                    } else {
                      setState(() {
                        enabled = false;
                      });
                    }
                  },
                  listOfTextEditingController: listOfTextEditingController),
              const SizedBox(
                height: 50,
              ),
              PositiveButton(
                onTap: enabled
                    ? () => _validate(context, otpText, phoneNumber)
                    : null,
                text: "Next",
              ),
              const SizedBox(
                height: 50,
              ),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 14,
                    color: const Color(0xff7c7d7e),
                  ),
                  children: [
                    TextSpan(
                      text: 'Didn\'t Receive? ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: 'Click Here',
                      style: TextStyle(
                        // color: const Color(0xfffc6011),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                textHeightBehavior:
                    TextHeightBehavior(applyHeightToFirstAscent: false),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }

  _validate(
    BuildContext context,
    String otpText,
    String phoneNumber,
  ) async {
    Map<String, dynamic> _verifyotp =
        await _loginRepo.validateOtp(phoneNumber, otpText);
    print(_verifyotp);
    if (_verifyotp['errors'] != null) {
      showSnackError(context, _verifyotp['message']);
    } else {
      if (_verifyotp['message'] == 'Invalid OTP') {
        showSnackError(context, _verifyotp['message']);
      } else {
        _update(context);
      }
    }
  }

  void _update(BuildContext context) {
    if (widget.userId == null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DashBoardPage('')),
          (route) => false);
    } else {
      //navigate to resetPassword
      // context.router.push(
      //   ResetPassword(
      //     id: widget.userId,
      //   ),
      // );
    }
  }
}
