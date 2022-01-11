import 'package:flutter/material.dart';
import 'package:mario_provider/repositories/check_api/check_api.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:mario_provider/utils/snack_util.dart';
import 'package:mario_provider/views/carousel/carousel.dart';
import 'package:mario_provider/views/dashboard/dashboard.dart';
import 'package:mario_provider/views/login_register/login_register.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  SharedReferences shared = new SharedReferences();
  CheckApi check = new CheckApi();
  Map<String, dynamic> response = {};
  @override
  void initState() {
    super.initState();

    changeRoute(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: Image.asset('assets/icon/icon.png'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Service',
                  style: TextStyle(
                    fontFamily: 'Cabin',
                    fontSize: 34,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 1.15,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                  textHeightBehavior:
                      TextHeightBehavior(applyHeightToFirstAscent: false),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  'Mario',
                  style: TextStyle(
                    fontFamily: 'Cabin',
                    fontSize: 34,
                    color: const Color(0xff4a4b4d),
                    letterSpacing: 1.1560000000000001,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                  textHeightBehavior:
                      TextHeightBehavior(applyHeightToFirstAscent: false),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Text(
              'Service Provider',
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 10,
                color: const Color(0xff4a4b4d),
                letterSpacing: 2.36,
                height: 3.4,
              ),
              textHeightBehavior:
                  TextHeightBehavior(applyHeightToFirstAscent: false),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void changeRoute(BuildContext context) async {
    // setState(() {
    response = await check.check();
    var isFirst = false;
    if (await shared.getPrefernce() == null) {
      isFirst = true;
    }
    String tokn = await shared.getAccessToken();
    if (response['sucess']) {
      Future.delayed(
          Duration(
            seconds: 1,
          ), () {
        if (isFirst) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => CarouselPage()));
        } else {
          if (tokn == null) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LoginRegisterPage()));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DashBoardPage('')));
          }
        }
      });
    } else {
      showSnackError(context, "Server is not responding");
    }
  }
}
