import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mario_provider/common/base.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:geocoder/geocoder.dart';
import 'package:mario_provider/repositories/trip/trip_repo.dart';
import 'package:mario_provider/repositories/users/user_repo.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:mario_provider/utils/snack_util.dart';
import 'package:mario_provider/views/login_register/login_register.dart';
import 'package:mario_provider/views/provider_loaction/reterive_location.dart';

class HomePage extends StatelessWidget {
  final String location;

  HomePage(this.location);
  @override
  Widget build(BuildContext context) {
    return HomePageContentView(this.location);
  }
}

class HomePageContentView extends StatefulWidget {
  final String location;
  HomePageContentView(this.location);

  @override
  State<StatefulWidget> createState() {
    return HomePageContentViewState();
  }
}

class HomePageContentViewState extends State<HomePageContentView> {
  final SharedReferences _sharedReferences = new SharedReferences();
  final TripRepo _tripRepo = new TripRepo();
  Map<String, dynamic> _summary = {};
  bool _isLoading = true;
  bool _isAvailabel = true;
  String currentLocation = '';
  String currency = '';
  @override
  void initState() {
    getAllData();
    super.initState();
  }

  getAllData() async {
    LatLng latlong = await _sharedReferences.getLatLng();
    bool available = await _sharedReferences.getStatus();
    currency = await _sharedReferences.getCurrency();
    _summary = await _tripRepo.getsummary();

    if (_summary['error'] == 'Token has expired') {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginRegisterPage()),
          (route) => false);

      return;
    }
    var loc;
    if (widget.location != '') {
      loc = widget.location;
    } else {
      final coordinates = new Coordinates(latlong.latitude, latlong.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;

      loc = first.addressLine;
    }

    if (mounted) {
      setState(() {
        currentLocation = loc;
        _isLoading = false;
        _isAvailabel = available;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.09,
                width: MediaQuery.of(context).size.width * 0.97,
                padding: EdgeInsets.only(left: 5, top: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xff9059ff),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UserLocationUpdatePage(currentLocation)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Currently at',
                          style: TextStyle(
                            fontFamily: 'Metropolis',
                            fontSize: 11,
                            color: Colors.white,
                            height: 1.8,
                          ),
                          textHeightBehavior: TextHeightBehavior(
                              applyHeightToFirstAscent: false),
                          textAlign: TextAlign.left,
                        ),
                        Row(
                          children: [
                            Text(
                              'Current Provider Location',
                              style: TextStyle(
                                fontFamily: 'Metropolis',
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              // color: Color(0xFFFC6011),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          '$currentLocation',
                          style: TextStyle(
                            fontFamily: 'Metropolis',
                            fontSize: 11,
                            color: Colors.white,
                            height: 1.8,
                          ),
                          textHeightBehavior: TextHeightBehavior(
                              applyHeightToFirstAscent: false),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              StripContainer(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 7,
                      ),
                      child: TitleCard(
                        onTap: () => {},
                        title: "Statistics",
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: const Color(0xff9059ff),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Monthly revenue',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xffffffff),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "${currency}",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: const Color(0xffffffff),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Spacer(flex: 1),
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.19,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xff9059ff),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Rides',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${_summary['rides']}",
                                      // homePageContents.summaryModel.rides.toString(),
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: const Color(0xffffffff),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Spacer(flex: 1),
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xff9059ff),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xffffffff),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${_summary['completed_rides']}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: const Color(0xffffffff),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Spacer(flex: 1),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Spacer(flex: 1),
                        Expanded(
                          flex: 4,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xff9059ff),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Cancelled',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xffffffff),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${_summary['cancel_rides']}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: const Color(0xffffffff),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Spacer(flex: 1),
                        Expanded(
                          flex: 4,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xff9059ff),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Profit',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xffffffff),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      // homePageContents.userDetailModel.currency +
                                      '${_summary['montly_gains']}',
                                      // (homePageContents.summaryModel.montlyGains)
                                      // .toString(),
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: const Color(0xffffffff),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Spacer(flex: 1),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.59,
                    padding: EdgeInsets.only(left: 5, top: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(55),
                      color: _isAvailabel ? Colors.green : Colors.red,
                    ),
                    child: GestureDetector(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 12,
                                      color: _isAvailabel
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Text(
                                      _isAvailabel ? 'Online' : "Offline",
                                      style: TextStyle(
                                        fontFamily: 'Metropolis',
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                                Transform.scale(
                                    scale: 0.5,
                                    child: LiteRollingSwitch(
                                      //initial value
                                      value: _isAvailabel,
                                      textOn: 'ON',
                                      textOff: 'OFF',
                                      colorOn: Colors.greenAccent[700],
                                      colorOff: Colors.redAccent[700],
                                      iconOn: Icons.done,
                                      iconOff: Icons.remove_circle_outline,
                                      textSize: 16.0,
                                      onChanged: (bool state) {
                                        //Use it to manage the different states
                                        updateAvaliablity(context, state);
                                        //       print(value);
                                        // print('Current State of SWITCH IS: $state');
                                      },
                                    )

                                    // CupertinoSwitch(
                                    //     value: _isAvailabel,
                                    //     onChanged: (bool value) {
                                    //
                                    //     }),
                                    )
                              ],
                            ),
                            SizedBox(
                              height: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
            ],
          );
  }

  updateAvaliablity(BuildContext context, bool value) async {
    final UserRepo _userRepo = new UserRepo();
    final SharedReferences _refs = new SharedReferences();
    bool status = await _refs.getStatus();
    Map<String, dynamic> _result = await _userRepo.setStatus(value);

    if (_result['error'] == 'Token has expired') {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginRegisterPage()),
          (route) => false);

      return;
    }

    if (_result['sucess'] != null) {
      showSnackError(context, 'Status unchanged');
      setState(() {
        _isAvailabel = status;
      });
    } else {
      await _refs.setStatus(value);
      setState(() {
        _isAvailabel = value;
      });
    }
  }
}

class TitleCard extends StatelessWidget {
  final String title;
  final Function() onTap;

  const TitleCard({Key key, this.title, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title',
            style: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 20,
              color: const Color(0xff4a4b4d),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.left,
          ),
          // GestureDetector(
          //   onTap: onTap,
          //   child: Text(
          //     "View all",
          //     style: TextStyle(
          //       fontFamily: 'Metropolis',
          //       fontSize: 13,
          //       color: const Color(0xfffc6011),
          //       fontWeight: FontWeight.w500,
          //     ),
          //     textAlign: TextAlign.right,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class Rating extends StatelessWidget {
  final String rating;

  Rating(this.rating);

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating: double.parse(rating),
      itemBuilder: (context, index) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      itemCount: 5,
      itemSize: 12.0,
      direction: Axis.horizontal,
    );
  }
}

class LocationSelection extends StatelessWidget {
  final bool isActive;
  final String address;
  final IconData iconData;
  final String type;

  LocationSelection(this.isActive, this.address, this.iconData, this.type);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            '$type',
            style: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 14,
              color: const Color(0xff4a4b4d),
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(
            width: 16,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color:
                        isActive ? Colors.primaries[0] : Colors.grey.shade300,
                    width: 1,
                  ),
                  right: BorderSide(
                    color:
                        isActive ? Colors.primaries[0] : Colors.grey.shade300,
                    width: 1,
                  ),
                  left: BorderSide(
                    color:
                        isActive ? Colors.primaries[0] : Colors.grey.shade300,
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color:
                        isActive ? Colors.primaries[0] : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99.0),
                      child: Container(
                        width: 35,
                        height: 35,
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            iconData,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '$address',
                      style: TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 12,
                        color: const Color(0xff4a4b4d),
                        fontWeight: FontWeight.w100,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
