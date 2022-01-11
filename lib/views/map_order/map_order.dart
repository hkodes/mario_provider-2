import 'dart:async';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mario_provider/imported/text_field.dart';
import 'package:mario_provider/repositories/order/order_repo.dart';
import 'package:mario_provider/common/base.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:mario_provider/repositories/trip/trip_repo.dart';
import 'package:mario_provider/utils/common_fun.dart';
import 'package:mario_provider/utils/snack_util.dart';
import 'package:mario_provider/views/dashboard/dashboard.dart';
import 'package:mario_provider/views/login_register/login_register.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:wakelock/wakelock.dart';

class MapOrder extends StatefulWidget {
  final Map<String, dynamic> tripInfo;
  final String sLocation;
  final Map<String, dynamic> stat;

  MapOrder(this.tripInfo, this.sLocation, this.stat);

  @override
  State<MapOrder> createState() => MapSampleState();
}

class MapSampleState extends State<MapOrder> {
  Map<String, dynamic> _tripInfo = {};
  String location = '';
  final TextEditingController _commentEditingController =
      TextEditingController(text: "");
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController googleMapController;
  //*List of Marker each representing a unique vendor
  Set<Marker> markers = {};
  //*Polilines for ios
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Map<String, dynamic> statusInfo = {};
  SharedReferences references = new SharedReferences();
//latlng
  String latitude, longitude;

  static final CameraPosition _kGoogleComplex = CameraPosition(
    target: LatLng(27.7272, 86.3250),
    zoom: 20,
  );
  bool isLoading = false;
  bool _isRating = false;
  bool isLoaded = false;
  bool countDown = true;
  double rating = 0.0;
  String _mapStyle;
  final StopWatchTimer _stopwatchTimer = new StopWatchTimer();
  BitmapDescriptor pinProviderIcon, pinUserIcon;
  StreamSubscription<Event> updates;
  bool _isHours = true;
  LatLng updatedValue;
  @override
  void initState() {
    location = widget.sLocation;
    _tripInfo = widget.tripInfo;
    statusInfo = widget.stat;
    print(_tripInfo);
    super.initState();
    Wakelock.enable();

    // mapBloc.listenToPushNotification();

    //*Load Custom Map Style theme
    rootBundle.loadString('assets/google_map_style.txt').then((string) {
      _mapStyle = string;
    });

    //*Load Custom pointer
    setCustomMapPin();
  }

  //* set custom pointer for service providerLocation
  setCustomMapPin() async {
    // pinProviderIcon =
    //     BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    pinUserIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    final Uint8List markerIcon2 = await getBytesFromAsset(
      'assets/icon/icon.png',
      100,
    );
    pinProviderIcon = BitmapDescriptor.fromBytes(markerIcon2);
    return;
  }

  @override
  void dispose() {
    super.dispose();
    // mapBloc.close();
    Wakelock.disable();
    // updates.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: _kGoogleComplex,
                    markers: markers,
                    polylines: Set<Polyline>.of(polylines.values),
                    onMapCreated: (GoogleMapController controller) {
                      googleMapController = controller;
                      _controller.complete(controller);
                      controller.setMapStyle(_mapStyle);
                      _addMarker(controller, _tripInfo);
                    },
                    onCameraIdle: () {
                      if (!isLoaded) {
                        if (statusInfo.length == 0) {
                          _modalBottomSheetMenu(
                            context,
                            _tripInfo['requests'][0]['request'],
                            _tripInfo['requests'][0]['request']['service_type'],
                            _tripInfo['requests'][0]['request']['user'],
                            location,
                          );
                        } else {
                          if (statusInfo['status'] == 'DROPPED') {
                            _confirmPay(context, statusInfo);
                          } else if (statusInfo['status'] == 'COMPLETED') {
                            showRatingModal(context, statusInfo);
                          } else {
                            _bottomSheetMenu(
                                context,
                                _tripInfo['requests'][0]['request']['user'],
                                _tripInfo['requests'][0]['request'],
                                statusInfo);
                          }
                        }

                        setState(() {
                          isLoaded = true;
                        });
                      }
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //onMapCreate Move Camera to fit two coordinate[self] and [provider]
  void _addMarker(
    GoogleMapController controller,
    Map<String, dynamic> serviceProviderModel,
  ) async {
    setState(() {
      // markers = {};
      // serviceProviderModel.forEach((element) {
      markers.add(Marker(
        markerId: MarkerId(
          'provider_id',
        ),
        position: LatLng(
            double.parse(
                serviceProviderModel['requests'][0]['request']['d_latitude']),
            double.parse(
                serviceProviderModel['requests'][0]['request']['d_longitude'])),
        icon: pinProviderIcon,
        draggable: false,
        onTap: () => null,
        infoWindow: new InfoWindow(title: "Provider"),
      ));

      markers.add(
        Marker(
            markerId: MarkerId(
              'service_id',
            ),
            position: LatLng(
                double.parse(serviceProviderModel['requests'][0]['request']
                    ['s_latitude']),
                double.parse(serviceProviderModel['requests'][0]['request']
                    ['s_longitude'])),
            icon: pinUserIcon,
            draggable: false,
            infoWindow: new InfoWindow(title: "Service"),
            onTap: () {}),
      );

      _getPolyline(serviceProviderModel['requests'][0]['request']);

      List<LatLng> latLngList = [];
      // serviceProviderModel.forEach((element) {
      latLngList.add(LatLng(
          double.parse(
              serviceProviderModel['requests'][0]['request']['d_latitude']),
          double.parse(
              serviceProviderModel['requests'][0]['request']['d_longitude'])));

      latLngList.add(LatLng(
          double.parse(
              serviceProviderModel['requests'][0]['request']['s_latitude']),
          double.parse(
              serviceProviderModel['requests'][0]['request']['s_longitude'])));
      // });

      controller.animateCamera(
        CameraUpdate.newLatLngBounds(boundsFromLatLngList(latLngList), 52),
      );
    });
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 10);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline(Map<String, dynamic> _result) {
    List<PointLatLng> result =
        polylinePoints.decodePolyline(_result['route_key']);
    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        print(point);
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  void _modalBottomSheetMenu(
      BuildContext context2,
      Map<String, dynamic> request,
      Map<String, dynamic> service,
      Map<String, dynamic> user,
      String location) async {
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        enableDrag: false,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        isScrollControlled: true,
        // set this to true
        builder: (context) {
          return DraggableScrollableSheet(
            expand: false,
            maxChildSize: .4,
            minChildSize: .2,
            initialChildSize: .3,
            builder: (_, controller) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Column(
                        children: [
                          StripContainer(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 12,
                                  ),
                                  SizedBox(
                                    height: 60,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            child: Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey.shade200,
                                              child: CachedNetworkImage(
                                                imageUrl: user['picture'],
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(
                                                  Icons.error,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                user['first_name'] +
                                                    ' ' +
                                                    user['last_name'],
                                                style: TextStyle(
                                                  fontFamily: 'Metropolis',
                                                  fontSize: 16,
                                                  color:
                                                      const Color(0xff4a4b4d),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              RatingBar.builder(
                                                itemSize: 10,
                                                initialRating: double.parse(
                                                    user['rating']),
                                                minRating: 1,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 4.0),
                                                itemBuilder: (context, _) =>
                                                    Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                onRatingUpdate: (rating) {
                                                  print(rating);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: StripContainer(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.local_shipping,
                                              size: 16,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              "Service Location",
                                              style: TextStyle(
                                                fontFamily: 'Metropolis',
                                                fontSize: 14,
                                                color: const Color(0xff4a4b4d),
                                                fontWeight: FontWeight.w700,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Text(
                                      location,
                                    ),
                                    // serviceCategoryModel['price']
                                    //   .toString()
                                    //   ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Service',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    service['name'],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      color: Colors.blue,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 40,
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Payment Mode',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    user['payment_mode'],
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  StripContainer(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                  onPressed: () =>
                                      cancelRequest(context2, request),
                                  child: Text("Cancel Request"),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.red[400]))),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    acceptRequest(context2, user, request),

                                // _orderNow(context2, state.data),
                                child: Text("Accept Request"),
                              ),
                            ),
                          ],
                        )
                        // },
                        // bloc: mapBloc,
                        ),
                  ),
                ],
              );
            },
          );
        }).then((value) {
      setState(() {
        isLoaded = false;
      });
    });
  }

  double lat, lng;

  cancelRequest(BuildContext context2, Map<String, dynamic> request) async {
    bool cancelling = false;
    final OrderRepo _order = new OrderRepo();

    Widget cancelButton = ElevatedButton(
      child: Text("NO"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("YES"),
      onPressed: () async {
        setState(() {
          cancelling = true;
        });
        Map<String, dynamic> _info =
            await _order.cancelRequest(request['id'].toString());

        if (_info['error'] != null) {
          showSnackError(context2, _info['error']);
        } else {
          showSnackSuccess(context2, 'Request Cancelled');
          Future.delayed(
              Duration(
                seconds: 3,
              ), () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => DashBoardPage('')),
                (route) => false);
          });
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Mario Provider"),
      content: Text("Are you sure to cancel the trip?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return cancelling ? Center(child: CircularProgressIndicator()) : alert;
      },
    );
  }

  acceptRequest(BuildContext context2, Map<String, dynamic> user,
      Map<String, dynamic> request) async {
    final OrderRepo _order = new OrderRepo();

    Map<String, dynamic> _info =
        await _order.acceptRequest(request['id'].toString());

    if (_info['error'] != null) {
      showSnackError(context2, _info['message']);
      if (_info['error'] == 'Token has expired') {
        await references.removeAccessToken();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginRegisterPage()),
            (route) => false);

        return;
      }
    } else {
      Navigator.pop(context2);
      print(_info);
      _bottomSheetMenu(context2, user, request, _info);

      setState(() {
        isLoaded = true;
        statusInfo = _info;
      });
    }
  }

  void _bottomSheetMenu(
      BuildContext context2,
      Map<String, dynamic> serviceCategoryModel,
      Map<String, dynamic> request,
      Map<String, dynamic> info) async {
    showModalBottomSheet(
        context: context2,
        isDismissible: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        enableDrag: false,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        isScrollControlled: true,
        // set this to true
        builder: (context) {
          return DraggableScrollableSheet(
            expand: false,
            maxChildSize: .38,
            minChildSize: .2,
            initialChildSize: .38,
            builder: (_, controller) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Column(
                        children: [
                          StripContainer(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 12,
                                  ),
                                  SizedBox(
                                    height: 60,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            child: Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey.shade200,
                                              child: CachedNetworkImage(
                                                imageUrl: serviceCategoryModel[
                                                    'avatar'],
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(
                                                  Icons.error,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                serviceCategoryModel[
                                                        'first_name'] +
                                                    ' ' +
                                                    serviceCategoryModel[
                                                        'last_name'],
                                                style: TextStyle(
                                                  fontFamily: 'Metropolis',
                                                  fontSize: 16,
                                                  color:
                                                      const Color(0xff4a4b4d),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              RatingBar.builder(
                                                itemSize: 10,
                                                initialRating: double.parse(
                                                    serviceCategoryModel[
                                                        'rating']),
                                                minRating: 1,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 4.0),
                                                itemBuilder: (context, _) =>
                                                    Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                onRatingUpdate: (rating) {
                                                  print(rating);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: StripContainer(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.local_shipping,
                                              size: 16,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              "Service Location",
                                              style: TextStyle(
                                                fontFamily: 'Metropolis',
                                                fontSize: 14,
                                                color: const Color(0xff4a4b4d),
                                                fontWeight: FontWeight.w700,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Text(
                                      location,
                                    ),
                                    // serviceCategoryModel['price']
                                    //   .toString()
                                    //   ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          StripContainer(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  "Due to peak hours the cost might vary depending on the providers.",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  StripContainer(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: info['status'] == 'PICKEDUP'
                            ? Row(children: [
                                Expanded(
                                  child: ElevatedButton(
                                      onPressed: () => updateStatus(
                                          context2,
                                          serviceCategoryModel,
                                          request,
                                          'DROPPED'),

                                      // _orderNow(context2, state.data),
                                      child: Text("Service Done")),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                    child: StreamBuilder<int>(
                                        stream: _stopwatchTimer.rawTime,
                                        initialData:
                                            _stopwatchTimer.rawTime.value,
                                        builder: (context, snapshot) {
                                          final value = snapshot.data;
                                          final displayTime =
                                              StopWatchTimer.getDisplayTime(
                                                  value,
                                                  hours: _isHours);

                                          return Text(
                                            displayTime,
                                            style: TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold),
                                          );
                                        })),
                              ])
                            : Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          cancelRequest(context2, request),
                                      child: Text("Cancel"),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.red[400])),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  if (info['status'] == 'ARRIVED')
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => updateStatus(
                                            context2,
                                            serviceCategoryModel,
                                            request,
                                            'PICKEDUP'),

                                        // _orderNow(context2, state.data),
                                        child: Text("Service Start"),
                                      ),
                                    ),
                                  if (info['status'] == 'STARTED')
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => updateStatus(
                                            context2,
                                            serviceCategoryModel,
                                            request,
                                            'ARRIVED'),

                                        // _orderNow(context2, state.data),
                                        child: Text("Arrived"),
                                      ),
                                    ),
                                ],
                              )
                        // },
                        // bloc: mapBloc,
                        ),
                  ),
                ],
              );
            },
          );
        }).then((value) {
      setState(() {
        isLoaded = false;
      });
    });
  }

  updateStatus(BuildContext context2, Map<String, dynamic> user,
      Map<String, dynamic> request, String status) async {
    final OrderRepo _order = new OrderRepo();

    Map<String, dynamic> _info =
        await _order.updateRequest(status, request['id'].toString());

    if (_info['error'] == 'Token has expired') {
      await references.removeAccessToken();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginRegisterPage()),
          (route) => false);

      return;
    }
    if (_info['errors'] != null) {
      showSnackError(context2, _info['message']);
    } else {
      // sNavigator.pop(context2);
      setState(() {
        // stopTimer();
        switch (_info['status']) {
          case 'PICKEDUP':
            _stopwatchTimer.onExecute.add(StopWatchExecute.start);
            // setState(() {
            // });
            break;
          case 'DROPPED':
            _stopwatchTimer.onExecute.add(StopWatchExecute.stop);
            break;
          default:
            break;
        }
      });
      if (_info['status'] == 'ARRIVED') {
        final marker = markers.first;
        Marker _marker = Marker(
          markerId: marker.markerId,
          onTap: () {
            print("tapped");
          },
          position: LatLng(double.parse(_info['s_latitude']),
              double.parse(_info['s_longitude'])),
          icon: marker.icon,
          infoWindow: InfoWindow(title: 'Provider'),
        );

        setState(() {
          isLoaded = true;

          //the marker is identified by the markerId and not with the index of the list
          markers.add(_marker);
          polylines = {};
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(double.parse(_info['s_latitude']),
                    double.parse(_info['s_longitude'])),
                zoom: 18,
              ),
            ),
          );
        });
      }

      setState(() {
        statusInfo = _info;
      });

      print(_info);

      if (_info['status'] != 'DROPPED') {
        Navigator.pop(context2);
        _bottomSheetMenu(context2, user, request, _info);
      } else {
        final TripRepo _trips = new TripRepo();
        Map<String, dynamic> _tripsList = await _trips.getTrips();
        if (_tripsList['requests'].length > 0) {
          Map<String, dynamic> _info =
              await _order.updateRequest('PAYMENT', request['id'].toString());
          if (_info['errors'] == null) {
            Navigator.pop(context2);
            _confirmPay(context2, _tripsList);
          }
        }
      }
    }
  }

  void _confirmPay(
    BuildContext context2,
    Map<String, dynamic> orderConfirmEntity,
  ) async {
    showModalBottomSheet(
        context: context2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        enableDrag: false,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        isScrollControlled: true,
        // set this to true
        builder: (context) {
          return DraggableScrollableSheet(
            expand: false,
            maxChildSize: .5,
            minChildSize: .2,
            initialChildSize: .5,
            builder: (_, controller) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: StripContainer(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      orderConfirmEntity['provider_details']
                                              ['first_name'] +
                                          ' ' +
                                          orderConfirmEntity['provider_details']
                                              ['last_name'],
                                      style: TextStyle(
                                        fontFamily: 'Metropolis',
                                        fontSize: 18,
                                        color: const Color(0xff4a4b4d),
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: StripContainer(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.directions_bike,
                                            size: 16,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            "Distance",
                                            style: TextStyle(
                                              fontFamily: 'Metropolis',
                                              fontSize: 14,
                                              color: const Color(0xff4a4b4d),
                                              fontWeight: FontWeight.w700,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      orderConfirmEntity['requests'][0]
                                                  ['request']['distance']
                                              .toString() +
                                          " KM",
                                      style: TextStyle(
                                        fontFamily: 'Metropolis',
                                        fontSize: 14,
                                        color: const Color(0xff4a4b4d),
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          StripContainer(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.lock_clock,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          "Time",
                                          style: TextStyle(
                                            fontFamily: 'Metropolis',
                                            fontSize: 14,
                                            color: const Color(0xff4a4b4d),
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "${orderConfirmEntity['requests'][0]['request']['travel_time'] ?? parseDisplayDate(DateTime.now())}",
                                    style: TextStyle(
                                      fontFamily: 'Metropolis',
                                      fontSize: 14,
                                      color: const Color(0xff4a4b4d),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: StripContainer(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.monetization_on,
                                            size: 16,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            "Fixed Price",
                                            style: TextStyle(
                                              fontFamily: 'Metropolis',
                                              fontSize: 14,
                                              color: const Color(0xff4a4b4d),
                                              fontWeight: FontWeight.w700,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Rs.' +
                                          orderConfirmEntity['requests'][0]
                                                      ['request']['payment']
                                                  ['fixed']
                                              .toString(),
                                      style: TextStyle(
                                        fontFamily: 'Metropolis',
                                        fontSize: 14,
                                        color: const Color(0xff4a4b4d),
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          StripContainer(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.monetization_on,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          "Tax Price",
                                          style: TextStyle(
                                            fontFamily: 'Metropolis',
                                            fontSize: 14,
                                            color: const Color(0xff4a4b4d),
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "Rs." +
                                        orderConfirmEntity['requests'][0]
                                                ['request']['payment']['tax']
                                            .toString(),
                                    style: TextStyle(
                                      fontFamily: 'Metropolis',
                                      fontSize: 14,
                                      color: const Color(0xff4a4b4d),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          StripContainer(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.monetization_on,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          "Tips",
                                          style: TextStyle(
                                            fontFamily: 'Metropolis',
                                            fontSize: 14,
                                            color: const Color(0xff4a4b4d),
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "Rs." +
                                        orderConfirmEntity['requests'][0]
                                                ['request']['payment']['tips']
                                            .toString(),
                                    style: TextStyle(
                                      fontFamily: 'Metropolis',
                                      fontSize: 14,
                                      color: const Color(0xff4a4b4d),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          StripContainer(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.monetization_on,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          "Total",
                                          style: TextStyle(
                                            fontFamily: 'Metropolis',
                                            fontSize: 14,
                                            color: const Color(0xff4a4b4d),
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "Rs." +
                                        orderConfirmEntity['requests'][0]
                                                    ['request']['payment']
                                                ['provider_pay']
                                            .toString(),
                                    style: TextStyle(
                                      fontFamily: 'Metropolis',
                                      fontSize: 18,
                                      color: const Color(0xff000000),
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
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: StripContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () => completeOrder(
                              context2,
                              orderConfirmEntity['requests'][0]['request']
                                  ['id']),
                          child: Text("Accepted Payment"),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }).then((value) {
      setState(() {
        isLoaded = false;
      });
    });
  }

  completeOrder(BuildContext context2, int id) async {
    final OrderRepo _order = new OrderRepo();

    Map<String, dynamic> _info =
        await _order.updateRequest('COMPLETED', id.toString());

    print(_info);

    if (_info['error'] == 'Token has expired') {
      await references.removeAccessToken();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginRegisterPage()),
          (route) => false);
    }
    if (_info['errors'] != null) {
      showSnackError(context2, _info['message']);
    } else if (_info['error'] != null) {
      showSnackError(context2, _info['error']);
    } else {
      setState(() {
        statusInfo = _info;
      });
      Navigator.pop(context2);

      showRatingModal(context2, _info);
    }
  }

  void showRatingModal(
      BuildContext context2, Map<String, dynamic> _info) async {
    showModalBottomSheet(
        context: context2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        enableDrag: false,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        isScrollControlled: true,
        // set this to true
        builder: (context) {
          return DraggableScrollableSheet(
            expand: false,
            maxChildSize: .3,
            minChildSize: .3,
            initialChildSize: .3,
            builder: (_, controller) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Please Rate the trip",
                      style: TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 19,
                        color: const Color(0xff4a4b4d),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Center(
                              child: RatingBar.builder(
                                initialRating: 0.0,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding:
                                    EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rate) {
                                  setState(() {
                                    rating = rate;
                                  });
                                },
                              ),
                            ),
                          ),
                          CustomTextField(
                              hint: "Comment",
                              textEditingController: _commentEditingController,
                              validator: (String text) {
                                if (text.length == 0) {
                                  return 'Please enter the text';
                                }
                                return null;
                              }),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: _isRating
                                ? Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: () =>
                                        _rateTrip(context2, rating, _info),
                                    child: Text("Submit"),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }).then((value) {
      setState(() {
        isLoaded = false;
      });
    });
  }

  _rateTrip(
      BuildContext context, double rating, Map<String, dynamic> info) async {
    setState(() {
      _isRating = true;
    });
    final OrderRepo _order = new OrderRepo();
    if (_commentEditingController.text.isEmpty) {
      showSnackError(context, 'Please Provide valid comment');
      setState(() {
        _isRating = false;
      });

      return false;
    }
    Map<String, dynamic> _info = await _order.rateTrip(
        info['id'].toString(), rating.round(), _commentEditingController.text);

    setState(() {
      _isRating = false;
    });
    if (_info['error'] != null) {
      showSnackError(context, _info['error']);
      if (_info['error'] == 'Token has expired') {
        await references.removeAccessToken();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginRegisterPage()),
            (route) => false);

        return;
      }
    } else if (_info['errors'] != null) {
      showSnackError(context, _info['message']);
    } else {
      Navigator.pop(context);
      showSnackSuccess(context, _info['message']);
      Future.delayed(
          Duration(
            seconds: 3,
          ), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DashBoardPage('')),
            (route) => false);
      });
    }
  }

  _onWillPop(BuildContext context) {
    Widget cancelButton = ElevatedButton(
      child: Text("NO"),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.red[400])),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("YES"),
      onPressed: () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DashBoardPage('')));
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Mario Provider"),
      content: Text("Are you sure to exit?"),
      actions: [
        cancelButton,
        continueButton,
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
}
