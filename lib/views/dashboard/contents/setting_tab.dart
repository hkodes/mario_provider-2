import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:mario_provider/utils/common_fun.dart';
import 'package:mario_provider/views/change_password/change_password.dart';
import 'package:mario_provider/views/documents/documents.dart';
import 'package:mario_provider/views/help/help.dart';
import 'package:mario_provider/views/login_register/login_register.dart';
import 'package:mario_provider/views/notifications/notifications.dart';
import 'package:mario_provider/views/policies/policies.dart';
import 'package:mario_provider/views/profile/profile.dart';
import 'package:mario_provider/views/services/services.dart';
import 'package:mario_provider/views/wallet/wallet.dart';
import 'package:mario_provider/common/base.dart';

class SettingTab extends StatelessWidget {
  final Map<String, dynamic> userModel;
  SettingTab(this.userModel);

  @override
  Widget build(BuildContext context) {
    return ProfilePage(this.userModel);
  }
}

class ProfilePage extends StatelessWidget {
  // final ProviderUserProfile providerUserProfile;

  // const ProfilePage({Key key, this.providerUserProfile}) : super(key: key);
  final Map<String, dynamic> userModel;
  ProfilePage(this.userModel);

  @override
  Widget build(BuildContext context) {
    print(this.userModel);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(150.0),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: this.userModel['picture'] ?? "",
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 75,
                          ),
                          width: 75,
                          height: 75,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        getFullName(this.userModel['first_name'],
                            this.userModel['last_name']),
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 16,
                          color: const Color(0xff2a2a2b),
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        this.userModel['email'],
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 11,
                          color: const Color(0xff7c7d7e),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        this.userModel['mobile'],
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 11,
                          color: const Color(0xff7c7d7e),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 6,
          ),
          SettingOptions(
            title: "Account Settings",
            listOfTiles: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Services())),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xff9059ff),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black87,
                                  blurRadius: 2.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(2.0,
                                      2.0), // shadow direction: bottom right
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.room_service,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Services",
                                  style: TextStyle(
                                    fontFamily: 'Metropolis',
                                    fontSize: 16,
                                    color: const Color(0xffffffff),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Profile(this.userModel))),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xff9059ff),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black87,
                                  blurRadius: 2.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(2.0,
                                      2.0), // shadow direction: bottom right
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Profile",
                                  style: TextStyle(
                                    fontFamily: 'Metropolis',
                                    fontSize: 16,
                                    color: const Color(0xffffffff),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Documents())),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xff9059ff),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black87,
                                  blurRadius: 2.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(2.0,
                                      2.0), // shadow direction: bottom right
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.document_scanner_outlined,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Documents",
                                  style: TextStyle(
                                    fontFamily: 'Metropolis',
                                    fontSize: 16,
                                    color: const Color(0xffffffff),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotificationPage())),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xff9059ff),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black87,
                                  blurRadius: 2.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(2.0,
                                      2.0), // shadow direction: bottom right
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Notifications",
                                  style: TextStyle(
                                    fontFamily: 'Metropolis',
                                    fontSize: 16,
                                    color: const Color(0xffffffff),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WalletPage())),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xff9059ff),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black87,
                                  blurRadius: 2.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(2.0,
                                      2.0), // shadow direction: bottom right
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Wallet",
                                  style: TextStyle(
                                    fontFamily: 'Metropolis',
                                    fontSize: 16,
                                    color: const Color(0xffffffff),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChangePasswordPage())),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xff9059ff),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black87,
                                  blurRadius: 2.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(2.0,
                                      2.0), // shadow direction: bottom right
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_clock,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Password",
                                  style: TextStyle(
                                    fontFamily: 'Metropolis',
                                    fontSize: 16,
                                    color: const Color(0xffffffff),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          SettingOptions(
            title: "HELP & LEGAL",
            listOfTiles: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HelpPage())),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                      width: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color(0xff9059ff),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black87,
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                            offset: Offset(
                                2.0, 2.0), // shadow direction: bottom right
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Help",
                            style: TextStyle(
                              fontFamily: 'Metropolis',
                              fontSize: 16,
                              color: const Color(0xffffffff),
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  InkWell(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Policies())),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                      width: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color(0xff9059ff),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black87,
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                            offset: Offset(
                                2.0, 2.0), // shadow direction: bottom right
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.policy_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Policies",
                            style: TextStyle(
                              fontFamily: 'Metropolis',
                              fontSize: 16,
                              color: const Color(0xffffffff),
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  InkWell(
                    onTap: () => logout(context),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                      width: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color(0xff9059ff),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black87,
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                            offset: Offset(
                                2.0, 2.0), // shadow direction: bottom right
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Logout",
                            style: TextStyle(
                              fontFamily: 'Metropolis',
                              fontSize: 16,
                              color: const Color(0xffffffff),
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }

  logout(BuildContext context) async {
    final SharedReferences _references = new SharedReferences();
    await _references.removeAccessToken();
    await _references.removeUserId();
    await _references.removeCurrency();
    await _references.removeStatus();

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginRegisterPage()),
        (route) => false);
  }
}

class SettingOptions extends StatelessWidget {
  final String title;
  final List<Widget> listOfTiles;

  const SettingOptions({Key key, this.title, this.listOfTiles})
      : assert(listOfTiles != null && listOfTiles.length != 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: StripContainer(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title == null
                  ? Container()
                  : Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 11,
                        color: const Color(0xff4a4b4d),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left,
                    ),
              title == null ? Container() : SizedBox(height: 8),
              Column(
                  children: listOfTiles.map((v) {
                return Column(
                  children: [
                    v,
                  ],
                );
              }).toList()),
            ],
          ),
        ),
      ),
    );
  }
}
