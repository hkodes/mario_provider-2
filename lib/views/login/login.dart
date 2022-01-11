import 'package:flutter/material.dart';
import 'package:mario_provider/utils/form_util.dart';
import 'package:mario_provider/utils/snack_util.dart';
import 'package:mario_provider/common/base.dart';
import 'package:mario_provider/imported/text_field.dart';
import 'package:mario_provider/repositories/authentication/login_repo.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:mario_provider/views/dashboard/dashboard.dart';
import 'package:mario_provider/views/register/register.dart';
import 'package:mario_provider/views/reset_password/forget_password.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final LoginRepo _loginRepo = new LoginRepo();
  final SharedReferences references = new SharedReferences();
  final TextEditingController _emailEditingController =
      TextEditingController(text: "");
  final TextEditingController _passwordEditingController =
      TextEditingController(text: "");
  final GlobalKey<FormState> _globalKeyLoginForm = GlobalKey();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 75,
                  ),
                  Text(
                    'Login',
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    'Add your details to login',
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textHeightBehavior:
                        TextHeightBehavior(applyHeightToFirstAscent: false),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                ],
              ),
              Form(
                key: _globalKeyLoginForm,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextField(
                      hint: "Phone",
                      isPhone: true,
                      textEditingController: _emailEditingController,
                      validator: (String text) =>
                          FormUtils.validatePhone(text, context),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    CustomTextField(
                      hint: "Password",
                      obscure: true,
                      textEditingController: _passwordEditingController,
                      validator: (String text) =>
                          FormUtils.validatePassword(text, context),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : PositiveButton(
                            onTap: () => _login(context),
                            text: "Login",
                          ),
                    const SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () => _navigateToForgotPage(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Forgot your password?',
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 14,
                          color: const Color(0xff7c7d7e),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  GestureDetector(
                    onTap: () => _navigateToSignUp(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontFamily: 'Metropolis',
                            fontSize: 14,
                            color: const Color(0xff7c7d7e),
                          ),
                          children: [
                            TextSpan(
                              text: 'Don\'t have an Account? ',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        textHeightBehavior:
                            TextHeightBehavior(applyHeightToFirstAscent: false),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _login(BuildContext context) async {
    if (_globalKeyLoginForm.currentState.validate()) {
      _globalKeyLoginForm.currentState.save();
      setState(() {
        isLoading = true;
      });

      final Map<String, dynamic> successInformation = await _loginRepo.login(
          _emailEditingController.text, _passwordEditingController.text);

      print(successInformation);
      setState(() {
        isLoading = false;
      });

      if (successInformation['error'] != null) {
        showSnackError(context, successInformation['error']);
      }

      if (successInformation['errors'] != null) {
        showSnackError(context, successInformation['message']);
      }

      if (successInformation['access_token'] != null) {
        var lat = (successInformation['latitude']);
        var long = (successInformation['longitude']);
        print('this is lat: $lat');
        await references.setAccessToken(successInformation['access_token']);
        await references.setCurrency(successInformation['currency']);
        await references.setUserId(successInformation['id']);
        await references.setLatLng(lat, long);
        if (successInformation['service'].length > 0) {
          bool active;
          for (int i = 0; i < successInformation['service'].length; i++) {
            print(successInformation['service'][i]);
            if (successInformation['service'][i]['status'] == 'active') {
              active = true;
            } else {
              active = false;
            }
          }

          references.setStatus(active);
        }
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DashBoardPage('')),
            (route) => false);
      }
    }
  }

  _navigateToForgotPage(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ForgetPassword()));
  }

  _navigateToSignUp(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => RegisterPage()));
  }
}
