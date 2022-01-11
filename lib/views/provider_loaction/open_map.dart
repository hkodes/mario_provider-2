import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mario_provider/common/base.dart';
import 'package:mario_provider/utils/snack_util.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:mario_provider/repositories/location/provider_location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:mario_provider/views/dashboard/dashboard.dart';
import 'package:mario_provider/views/login_register/login_register.dart';

class OpenMapPage extends StatefulWidget {
  // final void Function(Addre)ssStringEntity addressStringEntity) onResult;

  final addressName;

  OpenMapPage(this.addressName);

  // const OpenMapPage() : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OpenMapPageState();
  }
}

class OpenMapPageState extends State<OpenMapPage> {
  final SharedReferences _sharedReferences = new SharedReferences();
  final ProviderLocationRepo _userlocation = new ProviderLocationRepo();
  Completer<GoogleMapController> googleMapController = Completer();

  GoogleMapController mapController;
  CameraPosition _kBaseKtm = CameraPosition(
    target: LatLng(27.682738, 85.297993),
    zoom: 14.4746,
  );

  String _mapStyle;
  bool disableLocationCall = true;
  String text;

  @override
  void initState() {
    ///loadMapStyle
    rootBundle.loadString('assets/google_map_style.txt').then((string) {
      _mapStyle = string;
    });
    //  GetMyLocationEvent();
    super.initState();
  }

  @override
  void dispose() {
    // mapBloc.close();
    super.dispose();
  }

  ///last known camera moved
  CameraPosition cameraPosition;

  void _loadLocation() async {
    if (cameraPosition != null) {
      disableLocationCall = false;
      text = widget.addressName;
      final coordinates = new Coordinates(
          cameraPosition.target.latitude, cameraPosition.target.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;

      setState(() {
        text = first.addressLine;
      });
    }

    // mapBloc.add(RetrieveAddressEvent(latLng: cameraPosition.target));
  }

  void _loadingLocation() {
    setState(() {
      disableLocationCall = true;
      text = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _kBaseKtm,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  googleMapController.complete(controller);
                  controller.setMapStyle(_mapStyle);
                  updateCameraPosition(controller);
                },
                onCameraMove: (CameraPosition cameraPosition) {
                  this.cameraPosition = cameraPosition;
                  if (!disableLocationCall) {
                    _loadingLocation();
                  }
                },
                onCameraMoveStarted: () {},
                onCameraIdle: () {
                  _loadLocation();
                },
                zoomControlsEnabled: true,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
              ),
              Center(
                child: Icon(
                  Icons.location_searching_sharp,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
        StripContainer(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(text ?? "Searching..."),
              ),
              text == null
                  ? BottomButton(
                      onTap: () {},
                      title: "Set Address",
                      enabled: false,
                      isPositive: true,
                    )
                  : BottomButton(
                      onTap: () => _popWithValue(context),
                      title: "Set Address",
                      enabled: true,
                      isPositive: true,
                    )
            ],
          ),
        ),
      ],
    ));
  }

  updateCameraPosition(GoogleMapController _controller) async {
    LatLng target = await _sharedReferences.getLatLng();
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: 18,
        ),
      ),
    );

    setState(() {
      text = widget.addressName;
      disableLocationCall = false;
    });
  }

  void _popWithValue(BuildContext context) async {
    showSnackLoading(context, "Updating...");
    Map<String, dynamic> setLocation =
        await _userlocation.updateProviderLocation(
            cameraPosition.target.latitude, cameraPosition.target.longitude);
    if (setLocation['error'] != null) {
      showSnackError(context, setLocation['error']);
      if (setLocation['error'] == 'Token has expired') {
        await _sharedReferences.removeAccessToken();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginRegisterPage()),
            (route) => false);

        return;
      }
    } else {
      await _sharedReferences.setLatLng(
          cameraPosition.target.latitude, cameraPosition.target.longitude);
      showSnackSuccess(context, "Updated");
    }

    Future.delayed(
        Duration(
          seconds: 3,
        ), () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DashBoardPage(text)),
          (route) => false);
    });
  }
}
