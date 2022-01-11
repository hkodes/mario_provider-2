import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mario_provider/views/login_register/login_register.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:mario_provider/external_svg_resources/svg_resources.dart';
import 'package:mario_provider/common/base.dart';
import 'package:mario_provider/repositories/order/order_repo.dart';
import 'package:mario_provider/common/empty_widget.dart';
import 'package:mario_provider/views/trip_detail/trip_detail.dart';

class HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StackOver();
  }
}

class StackOver extends StatefulWidget {
  @override
  _StackOverState createState() => _StackOverState();
}

class _StackOverState extends State<StackOver>
    with SingleTickerProviderStateMixin {
  final OrderRepo _orderRepo = new OrderRepo();

  List<Map<String, dynamic>> _ongoingTrip = [];
  List<Map<String, dynamic>> _pastTrip = [];

  bool _isLoading = true;
  TabController _tabController;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    getTripDetails();
    super.initState();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      getTripDetails();
    }
  }

  getTripDetails() async {
    _ongoingTrip = await _orderRepo.getUpcomingTrips();
    _pastTrip = await _orderRepo.getTrips();
    if (_pastTrip.length > 0 && _ongoingTrip.length > 0) {
      if (_pastTrip[0]['error'] == 'Token has expired' ||
          _ongoingTrip[0]['error'] == 'Token has expired') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginRegisterPage()),
            (route) => false);
        return;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted)
      setState(() {
        _isLoading = true;
      });

    getTripDetails();

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
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // give the tab bar a height [can change er
                  //
                  // hheight to preferred height]
                  Container(
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      // give the indicator a decoration (color and border radius)
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          30.0,
                        ),
                        color: Colors.deepPurple,
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        // first tab [you can add an icon using the icon property]
                        Tab(
                          text: 'On Going',
                        ),

                        // second tab [you can add an icon using the icon property]
                        Tab(
                          text: 'Past',
                        ),
                      ],
                    ),
                  ),
                  // tab bar view here
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // first tab bar view widget
                        UpComingTripView(_ongoingTrip),

                        // second tab bar view widget
                        CompletedTripView(_pastTrip),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class CompletedTripView extends StatelessWidget {
  final List<Map<String, dynamic>> _past;

  CompletedTripView(this._past);
  @override
  Widget build(BuildContext context) {
    return UpComingTripContent(
      upcomingTripModel: this._past,
      isOngoing: false,
    );
  }
}

class UpComingTripView extends StatelessWidget {
  final List<Map<String, dynamic>> _upcoming;

  UpComingTripView(this._upcoming);
  @override
  Widget build(BuildContext context) {
    return UpComingTripContent(
      upcomingTripModel: this._upcoming,
      isOngoing: true,
    );
  }
}

class UpComingTripContent extends StatelessWidget {
  final List<Map<String, dynamic>> upcomingTripModel;
  final bool isOngoing;

  UpComingTripContent(
      {@required this.upcomingTripModel, @required this.isOngoing})
      : assert(upcomingTripModel != null);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 8,
        ),
        Expanded(
          child: upcomingTripModel.length == 0
              ? EmptyOrder()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  // itemCount: upcomingTripModel.length,
                  itemCount: upcomingTripModel.length,
                  itemBuilder: (context, index) {
                    return UpComingTripItem(
                        upcomingTripModel[index], isOngoing);
                  },
                ),
        ),
      ],
    );
  }
}

class UpComingTripItem extends StatelessWidget {
  final Map<String, dynamic> upComingTripModel;
  final bool isOngoing;

  UpComingTripItem(this.upComingTripModel, this.isOngoing);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTap: () => _gotoDetail(context, upComingTripModel, isOngoing),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color(0xff9059ff),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 2.0,
                spreadRadius: 0.0,
                offset: Offset(2.0, 2.0), // shadow direction: bottom right
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Text(
                        upComingTripModel['service_type_id'] == null
                            ? "Unknown Service Type"
                            : upComingTripModel['service_type_name'] == null
                                ? ""
                                : upComingTripModel['service_type_name'],
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 15,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                    Text(
                      upComingTripModel['created_at'] == null
                          ? ""
                          : upComingTripModel['created_at'],
                      style: TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 11,
                        color: Colors.white,
                        height: 1,
                      ),
                      textHeightBehavior:
                          TextHeightBehavior(applyHeightToFirstAscent: false),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.white,
                    )
                  ],
                ),
                upComingTripModel['service_type_id'] == null
                    ? Container()
                    : Text(
                        upComingTripModel['service_type_description'] ?? "",
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 11,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                Divider(
                  color: Colors.white,
                ),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(42.0),
                      child: CachedNetworkImage(
                        imageUrl: upComingTripModel['service_type_id'] == null
                            ? ""
                            : upComingTripModel['service_type_image'],
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  upComingTripModel['service_type_id'] == null
                                      ? ""
                                      : upComingTripModel[
                                              'service_type_provider'] ??
                                          "",
                                  style: TextStyle(
                                    fontFamily: 'Metropolis',
                                    fontSize: 14,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                _getStatusView(upComingTripModel['status']),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                SvgPicture.string(
                                  start_orange,
                                  width: 11,
                                  height: 11,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  '${upComingTripModel['user_rated']}',
                                  style: TextStyle(
                                    fontFamily: 'Metropolis',
                                    fontSize: 11,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                  textHeightBehavior: TextHeightBehavior(
                                      applyHeightToFirstAscent: false),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _getStatusColor(String status) {
    if (status == "SCHEDULED") {
      return Colors.green.shade400;
    } else
      return Colors.red;
  }

  Widget _getStatusView(String status) {
    return Container(
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(
          15.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          status,
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 11,
            color: const Color(0xffffffff),
          ),
          textHeightBehavior:
              TextHeightBehavior(applyHeightToFirstAscent: false),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _gotoDetail(BuildContext context, Map<String, dynamic> upComingTripModel,
      bool isOngOing) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TripDetail(
                upComingTripModel: upComingTripModel, isOngoing: isOngOing)));
  }
}
