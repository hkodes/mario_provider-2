import 'package:flutter/material.dart';
import 'package:mario_provider/repositories/authentication/login_repo.dart';
import 'package:mario_provider/utils/form_util.dart';
import 'package:mario_provider/utils/snack_util.dart';
import 'package:mario_provider/common/base.dart';
import 'package:mario_provider/views/login/login.dart';

class ResetPassword extends StatefulWidget {
  final int id;

  const ResetPassword({Key key, this.id})
      : assert(id != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ResetPasswordState();
  }
}

class ResetPasswordState extends State<ResetPassword> {
  final LoginRepo _loginRepo = new LoginRepo();
  bool btnEnable = true;
  final _formKeyResetPassword = GlobalKey<FormState>();
  TextEditingController _passwordEditingController = TextEditingController();
  TextEditingController _passwordConfirmEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKeyResetPassword,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 75,
              ),
              Text(
                'Update Password',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 30,
                  color: const Color(0xff4a4b4d),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                'The account was verified,\n you can update the password from here',
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 14,
                  color: const Color(0xff7c7d7e),
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                textHeightBehavior:
                    TextHeightBehavior(applyHeightToFirstAscent: false),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 75,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                child: CustomTextField(
                  hint: "Password",
                  obscure: true,
                  minLine: 1,
                  validator: (String text) =>
                      FormUtils.validatePassword(text, context),
                  textEditingController: _passwordEditingController,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                child: CustomTextField(
                  hint: "Confirm Password",
                  obscure: true,
                  minLine: 1,
                  validator: (String text) =>
                      FormUtils.validateConfirmationPassword(
                          text, context, _passwordEditingController.text),
                  textEditingController: _passwordConfirmEditingController,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              PositiveButton(
                onTap: btnEnable
                    ? () {
                        if (_formKeyResetPassword.currentState.validate()) {
                          return _validate(
                            widget.id,
                            _passwordEditingController.text,
                            _passwordConfirmEditingController.text,
                          );
                        }
                        return null;
                      }
                    : null,
                text: "Update",
              ),
              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _validate(int id, String text, String text2) async {
    setState(() {
      btnEnable = false;
    });

    Map<String, dynamic> _message =
        await _loginRepo.resetPassword(id.toString(), text, text2);

    setState(() {
      btnEnable = true;
    });
    if (_message['errors'] != null) {
      showSnackError(context, _message['message']);
    } else {
      showSnackSuccess(context, _message['message']);

      Future.delayed(
          Duration(
            seconds: 3,
          ), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false);
      });
    }
  }
}

class CustomTextField extends StatelessWidget {
  final textEditingController;
  final String hint;
  final bool obscure;
  final FormFieldValidator<String> validator;
  final int minLine;

  const CustomTextField({
    Key key,
    this.textEditingController,
    this.hint,
    this.validator,
    this.obscure = false,
    this.minLine = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      obscureText: obscure,
      validator: validator,
      minLines: minLine,
      keyboardType: TextInputType.multiline,
      controller: textEditingController,
      style: TextStyle(
        fontFamily: 'Metropolis',
        fontSize: 14,
        color: const Color(0xff636565),
      ),
      decoration: new InputDecoration(
        focusColor: Colors.green,
        enabledBorder: new OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
            width: 2,
          ),
          borderRadius: const BorderRadius.all(
            const Radius.circular(50.0),
          ),
        ),
        focusedBorder: new OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
            width: 2,
          ),
          borderRadius: const BorderRadius.all(
            const Radius.circular(50.0),
          ),
        ),
        errorBorder: new OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 2,
          ),
          borderRadius: const BorderRadius.all(
            const Radius.circular(50.0),
          ),
        ),
        border: new OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
            width: 2,
          ),
          borderRadius: const BorderRadius.all(
            const Radius.circular(50.0),
          ),
        ),
        filled: true,
        hintStyle: TextStyle(
          fontFamily: 'Metropolis',
          fontSize: 14,
          color: const Color(0xffb6b7b7),
        ),
        hintText: hint,
        fillColor: const Color(0xfff2f2f2),
      ),
    );
  }
}
