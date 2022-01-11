import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mario_provider/repositories/firebase_response/firebase_response.dart';
import 'package:mario_provider/repositories/trip/trip_repo.dart';
import 'package:mario_provider/utils/common_fun.dart';
import 'package:mario_provider/imported/package/navigation_bar/curved_navigation_bar.dart';
import 'package:mario_provider/utils/snack_util.dart';
import 'package:mario_provider/views/dashboard/contents/history_tab.dart';
import 'package:mario_provider/views/dashboard/contents/home_tab.dart';
import 'package:mario_provider/repositories/users/user_repo.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:mario_provider/views/dashboard/contents/setting_tab.dart';
import 'package:mario_provider/views/login_register/login_register.dart';
import 'package:mario_provider/views/map_order/map_order.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class DashBoardPage extends StatefulWidget {
  final address;
  DashBoardPage(this.address);
  @override
  State<StatefulWidget> createState() {
    return DashBoardPageState();
  }
}

class DashBoardPageState extends State<DashBoardPage> {
  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();
  final UserRepo userRepo = new UserRepo();

  final SharedReferences references = new SharedReferences();
  final TripRepo _providerRepo = new TripRepo();
  bool _isLoading = true;
  Map<String, dynamic> _userDetails = {};

  @override
  void initState() {
    getUserDetails();
    super.initState();
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      print("2Value  from notification ");
      if (value != null) {
        print("2Value  from notification $value");
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;

      FirebaseResponse firebaseResponse;
      try {
        firebaseResponse = FirebaseResponse.fromJson(message.data);
      } catch (e) {
        print(e);
        firebaseResponse = FirebaseResponse(message: "New Request");
      }

      if (firebaseResponse.message == "New Request") {
        goToMap(context);
      } else {
        if (firebaseResponse.message.contains('You received') ||
            firebaseResponse.message
                .contains('Your documents have been verified')) {
          showSnackSuccess(context, firebaseResponse.message);
        } else {
          showSnackError(context, firebaseResponse.message);
        }
      }
      // AndroidNotification android = message.notification.android;
      print("FirebaseMessaging.onMessage.listen");
      print("$notification");
      // print("$android");
      print("$message");
      print("FirebaseMessaging.onMessage.listen");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("irebaseMessaging.onMessageOpenedApp.listen");
      print('A new onMessageOpenedApp event was published! $message');
      print("irebaseMessaging.onMessageOpenedApp.listen");
    });
  }

  goToMap(BuildContext context) async {
    Map<String, dynamic> _trips = await _providerRepo.getTrips();

    if (_trips['error'] == 'Token has expired') {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginRegisterPage()),
          (route) => false);
      return;
    }
    String loc = '';
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // debugPrint('location: ${position.latitude}');
    final coordinates = new Coordinates(
        double.parse(_trips['requests'][0]['request']['s_latitude']),
        double.parse(_trips['requests'][0]['request']['s_longitude']));
    // await _sharedReferences.setLatLng(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    loc = first.addressLine;

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => MapOrder(_trips, loc, {})));
  }

  getUserDetails() async {
    _userDetails = await userRepo.getUserDetail();
    if (_userDetails['error'] == 'Token has expired') {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginRegisterPage()),
          (route) => false);

      return;
    }
    if (_userDetails['sucess'] == null) {
      await references.setUserId((_userDetails['id']));
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // homePageContentBloc.close();
    super.dispose();
  }

  // _refreshStatistics(BuildContext context){
  //   // BlocProvider.of<DashBoard
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          getTitle(_page),
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 20,
            color: const Color(0xff4a4b4d),
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.left,
        ),
        actions: [
          // InkWell(
          //   onTap: () => _loadNotification(context),
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Row(
          //       children: [
          //         Icon(
          //           Icons.notifications,
          //           color: Theme.of(context).primaryColor,
          //           size: 24,
          //         ),
          //         Text(
          //           "Fake a  request",
          //           style: TextStyle(
          //             color: Theme.of(context).primaryColor,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
        backgroundColor: Colors.white,
      ),

      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _page,
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: const Color(0xff9059ff),
          ),

          /// Likes
          SalomonBottomBarItem(
            icon: Icon(Icons.reorder),
            title: Text("Order History"),
            selectedColor: const Color(0xff9059ff),
          ),

          /// Search
          SalomonBottomBarItem(
            icon: Icon(Icons.settings),
            title: Text("Settings"),
            selectedColor: const Color(0xff9059ff),
          ),

          /// Profile
        ],
      ),
      body: SafeArea(
        child: _getTab(_page, context),
      ),
    );
  }

  _getTab(int page, BuildContext context) {
    if (page == 1) {
      return HistoryTab();
    } else if (page == 2) {
      return SettingTab(_userDetails);
    } else if (page == 0) {
      return HomePage(widget.address);
    }
  }

  String getTitle(int page) {
    if (page == 1) {
      return 'Orders';
    } else if (page == 2) {
      return 'Settings';
    } else if (page == 0) {
      return "Good ${greeting()}!";
    }
    return "Hello";
  }
}

showSnack(BuildContext context, String text) {
  final snackBar = SnackBar(content: Text(text));

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
