import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mario_provider/common/base.dart';
import 'package:mario_provider/views/dashboard/dashboard.dart';
import 'package:mario_provider/views/provider_loaction/address_search.dart';
import 'package:mario_provider/views/provider_loaction/open_map.dart';
import 'package:mario_provider/views/provider_loaction/places_search.dart';
import 'package:uuid/uuid.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';

class UserLocationUpdatePage extends StatefulWidget {
  final String addressName;
  // final Function(UserAddressEntity userAddressEntity) param2;
  UserLocationUpdatePage(this.addressName);
  @override
  State<StatefulWidget> createState() {
    return UserLocationUpdatePageState();
  }
}

class UserLocationUpdatePageState extends State<UserLocationUpdatePage> {
  final _controller = TextEditingController();
  // String _addressStringEntity = '';
  // //saved result;
  // AddressStringEntity _addressStringEntity;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // userLocationBloc.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Set your Address"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 8,
            ),
            StripContainer(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      readOnly: true,
                      onTap: () async {
                        // generate a new token here
                        final sessionToken = Uuid().v4();
                        final Suggestion result = await showSearch(
                            context: context,
                            delegate: AddressSearch(sessionToken));
                        // This will change the text displayed in the TextField
                        if (result != null) {
                          final placeDetails =
                              await PlaceApiProvider(sessionToken)
                                  .getPlaceDetailFromId(result.placeId);
                          // setState(() {
                          //   _controller.text = result.description;

                          //   print(placeDetails.streetNumber);
                          //   print(placeDetails.street);
                          //   print(placeDetails.city);
                          //   print(placeDetails.zipCode);
                          // });
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) {
                            _popWithValue(
                                context,
                                result.description,
                                placeDetails.estimatedLatLng.latitude,
                                placeDetails.estimatedLatLng.longitude);
                            // }
                            // _popWithValue(
                            //     context,
                            //     UserAddressEntity(
                            //         addressName: result.description,
                            //         latLng: placeDetails.estimatedLatLng));
                          });
                        }
                      },
                      decoration: InputDecoration(
                        // icon: Container(
                        //   width: 10,
                        //   height: 10,
                        //   child: Icon(
                        //     Icons.home,
                        //     color: Colors.black,
                        //   ),
                        // ),
                        hintText: "Enter your shipping address",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 8.0, top: 16.0),
                      ),
                    ),
                    // CustomSingleSearchField(
                    //   textEditingController: _controller,
                    //   hint: "Search...",
                    //   iconData: Icons.search,
                    //   function: (String text) => _search(text, context),
                    // ),
                  ],
                ),
              ),
            ),
            AddressItem(
              iconData: Icons.pin_drop,
              title: 'Set On Map',
              onTap: () => _setOnMapClick(context, widget.addressName),
            ),
            if (widget.addressName == null)
              Container()
            else
              SizedBox(
                height: 68,
                child: Row(
                  children: [
                    Expanded(
                      child: AddressItem(
                        iconData: Icons.save_outlined,
                        title: widget.addressName,
                        onTap: () => {},
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        return _popWithValue(
                            context, widget.addressName, null, null);
                      },
                      // _popWithValue(
                      //     context,
                      //     UserAddressEntity(
                      //         addressName: _addressStringEntity.addressName,
                      //         latLng: _addressStringEntity.latLng)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.done),
                      ),
                    )
                  ],
                ),
              ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}

_search(String text, BuildContext context) {
  print(text);
}

_setOnMapClick(BuildContext context, String addressName) {
  Navigator.push(context,
      MaterialPageRoute(builder: (context) => OpenMapPage(addressName)));
}

_popWithValue(
    BuildContext context, String address, double lat, double long) async {
  if (lat != null || long != null) {
    final SharedReferences _sharedReferences = new SharedReferences();
    await _sharedReferences.setLatLng(lat, long);
  }

  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => DashBoardPage(address)),
      (route) => false);
}

class AddressItemTitle extends StatelessWidget {
  final IconData iconData;
  final String title;
  final Map Function() onTap;

  const AddressItemTitle(
      {Key key,
      @required this.iconData,
      @required this.title,
      @required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StripContainer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 8,
            ),
            InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99.0),
                    child: Container(
                      width: 35,
                      height: 35,
                      color: Colors.grey.shade200,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(
                          iconData,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
