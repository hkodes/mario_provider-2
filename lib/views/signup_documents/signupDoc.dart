import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mario_provider/common/base.dart';
import 'package:mario_provider/repositories/services/services_repo.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:mario_provider/utils/snack_util.dart';
import 'package:mario_provider/views/login_register/login_register.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SignupDoc extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignupDocState();
  }
}

class SignupDocState extends State<SignupDoc> {
  SharedReferences _sharedReferences = new SharedReferences();
  final ServicesRepo _servicesRepo = new ServicesRepo();
  List<Map<String, dynamic>> _services = [];
  final List<DropdownMenuItem> items = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<DropdownMenuItem<String>> _dropDownMenuItems = [
    new DropdownMenuItem(
        value: 'Add from Available SignupDoc',
        child: new Text('Add from Available SignupDoc'))
  ];
  String _current = 'Add from Available SignupDoc';

  bool _isLoading = true;

  bool _saving = false;
  String selectedValue;
  @override
  void initState() {
    getServices();
    super.initState();
  }

  getServices() async {
    _services = await _servicesRepo.getAllServices();

    print(_services);

    if (_services.length > 0) {
      if (_services[0]['error'] == 'Token has expired') {
        await _sharedReferences.removeAccessToken();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginRegisterPage()),
            (route) => false);

        return;
      }
    }

    print(_services);

    setState(() {
      getDropDownMenuItems();
      _isLoading = false;
    });
  }

  getDropDownMenuItems() {
    for (int i = 0; i < _services.length; i++) {
      _dropDownMenuItems.add(new DropdownMenuItem(
          value: _services[i]['name'], child: new Text(_services[i]['name'])));
    }
  }

  void changedDropDownItem(String selected) {
    Navigator.pop(context);
    setState(() {
      _current = selected;
    });

    showPopup(context);
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted)
      setState(() {
        _isLoading = true;
      });

    getServices();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();

    // BlocProvider.of<TripHistoryBloc>(context).add(RefreshDataEvent());
    // BlocProvider.of<UpcomingTripsBloc>(context).add(RefreshEvent());
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    _refreshController.loadComplete();
  }

  @override
  void dispose() {
    // userDetailBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Services"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: WaterDropHeader(),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      height: 100,
                      child: StripContainer(
                        child: Row(
                          children: [
                            Container(
                              child: CachedNetworkImage(
                                imageUrl: _services[index]['image'],
                                placeholder: (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  size: 45,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                              height: 12,
                            ),
                            Text(
                              _services[index]['name'],
                              style: TextStyle(
                                fontFamily: 'Metropolis',
                                fontSize: 12,
                                color: const Color(0xff000000),
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: _services.length,
              )),
      floatingActionButton: _isLoading
          ? Container()
          : FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                setState(() {
                  showPopup(context);
                });
              },
              child: Icon(
                Icons.add,
              ),
            ),
    );
  }

  showPopup(BuildContext context) {
    if (!_isLoading) {
      Widget cancelButton = ElevatedButton(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Text("Cancel"),
        ),
        onPressed: _saving
            ? null
            : () {
                Navigator.pop(context);
              },
      );
      Widget continueButton = ElevatedButton(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Text("Add Services"),
        ),
        onPressed: _saving
            ? null
            : () async {
                Navigator.pop(context);
                showPopup(context);
                if (_current == 'Add from Available Services') {
                  showSnackError(context, 'Please select services to add');
                } else {
                  setState(() {
                    _saving = true;
                  });
                  var _service =
                      _services.where((element) => element['name'] == _current);

                  String serviceName = _current;
                  int serviceId = 0;
                  _service.first.forEach((key, value) {
                    if (key == 'id') {
                      serviceId = value;
                    }
                  });

                  Map<String, dynamic> _result = await _servicesRepo.addService(
                      serviceId, serviceName, serviceName);
                  Navigator.pop(context);
                  if (_result['error'] != null || _result['length'] == 0) {
                    showSnackError(context, 'Could not add service');
                  } else {
                    showSnackSuccess(context, 'Service added successfully');
                  }

                  setState(() {
                    _saving = false;
                  });
                }
              },
      );
      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Mario Provider"),
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Padding(
              padding: const EdgeInsets.all(10.0),
              child: StripContainer(
                child: DropdownButton<String>(
                  value: _current,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: changedDropDownItem,
                  items: _dropDownMenuItems,
                ),
              ));
        }),
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
}
