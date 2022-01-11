import 'dart:async';
import 'dart:convert';
import 'package:mario_provider/resources/app_constants.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:http/http.dart' as http;

class OrderRepo {
  Future<Map<String, dynamic>> scheduleOrder(
      String slat,
      String slong,
      String dlat,
      String dlong,
      String service,
      String scheduleD,
      String scheduleT) async {
    try {
      final Map<String, dynamic> formData = {
        's_latitude': slat,
        's_longitude': slong,
        'd_latitude': dlat,
        'd_longitude': dlong,
        'service_type': service,
        'payment_mode': 'CASH',
        'schedule_date': scheduleD,
        'schedule_time': scheduleT,
      };
      print(formData);
      Map<String, dynamic> data = {};
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url = Uri.parse(AppEndPoints.BASE_URL + AppEndPoints.ORDER);
      final http.Response response =
          await http.post(url, body: json.encode(formData), headers: {
        'Accept': 'application/json',
        'content-type': 'application/json',
        'Authorization': 'Bearer ' + token
      });

      print(response.headers);

      data = json.decode(response.body);
      return data;
    } catch (err) {
      print(err);
      Map<String, dynamic> data = {
        'errors': 'Something went wrong try again',
      };
      return data;
    }
  }

  Future<Map<String, dynamic>> cancelRequest(String requestID) async {
    try {
      Map<String, dynamic> data = {};
      final Map<String, dynamic> formData = {
        'cancel_reason': "Just i wanted to",
        'id': requestID,
      };
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url = Uri.parse(AppEndPoints.BASE_URL + AppEndPoints.CANCEl_ORDER);
      final http.Response response =
          await http.post(url, body: json.encode(formData), headers: {
        'Authorization': 'Bearer ' + token,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      });

      data = json.decode(response.body);

      return data;
    } catch (err) {
      Map<String, dynamic> data = {
        'error': 'Something went wrong try again',
      };
      return data;
    }
  }

  Future<Map<String, dynamic>> acceptRequest(String requestID) async {
    try {
      Map<String, dynamic> data = {};
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url = Uri.parse(
          AppEndPoints.BASE_URL + AppEndPoints.ACCEPT_TRIP + requestID);
      final http.Response response = await http.post(url, headers: {
        'Authorization': 'Bearer ' + token,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      });

      data = json.decode(response.body);

      print(data);
      return data;
    } catch (err) {
      Map<String, dynamic> data = {
        'error': 'error',
        'message': 'Something went wrong try again'
      };
      return data;
    }
  }

  Future<Map<String, dynamic>> updateRequest(
      String status, String tripid) async {
    try {
      final Map<String, dynamic> formData = {
        'status': status,
        'payment_mode': 'CASH',
        '_method': 'PATCH',
        'after_comment': 'After comment',
        'before_comment': 'Before comment'
      };
      Map<String, dynamic> data = {};
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url =
          Uri.parse(AppEndPoints.BASE_URL + AppEndPoints.ACCEPT_TRIP + tripid);
      final http.Response response =
          await http.post(url, body: json.encode(formData), headers: {
        'Authorization': 'Bearer ' + token,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      });

      data = json.decode(response.body);

      print(data);
      return data;
    } catch (err) {
      Map<String, dynamic> data = {
        'errors': 'error',
        'message': 'Something went wrong try again'
      };
      return data;
    }
  }

  Future<List<Map<String, dynamic>>> getUpcomingTrips() async {
    try {
      List<Map<String, dynamic>> data = [];
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri _url = Uri.parse(AppEndPoints.BASE_URL + AppEndPoints.UPCOMING_TRIPS);
      final http.Response _response = await http.get(_url, headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer ' + token
      });
      List<dynamic> _data = json.decode(_response.body);

      Uri __url = Uri.parse(AppEndPoints.BASE_URL + AppEndPoints.TRIP);
      final http.Response __response = await http.get(__url, headers: {
        'Accept-Encoding': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer ' + token
      });

      Map<String, dynamic> _result = json.decode(__response.body);
      print(_result);
      if (_result['requests'].length > 0) {
        for (int i = 0; i < _result['requests'].length; i++) {
          if (_result['requests'][i]['request']['status'] != 'COMPLETED') {
            data.add({
              'id': _result['requests'][i]['request']['id'],
              'booking_id': _result['requests'][i]['request']['booking_id'],
              'user_id': _result['requests'][i]['request']['user_id'],
              'estimated_fare': _result['requests'][i]['request']
                  ['estimated_fare'],
              'service_type_id': _result['requests'][i]['request']
                  ['service_type_id'],
              'before_image': _result['requests'][i]['request']['before_image'],
              'status': _result['requests'][i]['request']['status'],
              'cancelled_by': _result['requests'][i]['request']['cancelled_by'],
              'cancel_reason': _result['requests'][i]['request']
                  ['cancel_reason'],
              'payment_mode': _result['requests'][i]['request']['payment_mode'],
              'paid': _result['requests'][i]['request']['paid'],
              'is_track': _result['requests'][i]['request']['is_track'],
              'distance': _result['requests'][i]['request']['distance'],
              'travel_time': _result['requests'][i]['request']['travel_time'],
              'unit': _result['requests'][i]['request']['unit'],
              's_latitude': _result['requests'][i]['request']['s_latitude'],
              's_longitude': _result['requests'][i]['request']['s_longitude'],
              's_address': _result['requests'][i]['request']['s_address'],
              'd_address': _result['requests'][i]['request']['d_address'],
              'd_latitude': _result['requests'][i]['request']['d_latitude'],
              'd_longitude': _result['requests'][i]['request']['d_longitude'],
              'track_distance': _result['requests'][i]['request']
                  ['track_distance'],
              'track_latitude': _result['requests'][i]['request']
                  ['track_latitude'],
              'track_longitude': _result['requests'][i]['request']
                  ['track_longitude'],
              'is_drop_location': _result['requests'][i]['request']
                  ['is_drop_location'],
              'is_instant_ride': _result['requests'][i]['request']
                  ['is_instant_ride'],
              'is_dispute': _result['requests'][i]['request']['is_dispute'],
              'assigned_at': _result['requests'][i]['request']['assigned_at'],
              'schedule_at': _result['requests'][i]['request']['schedule_at'],
              'started_at': _result['requests'][i]['request']['started_at'],
              'finished_at': _result['requests'][i]['request']['finished_at'],
              'is_scheduled': _result['requests'][i]['request']['is_scheduled'],
              'user_rated': _result['requests'][i]['request']['user_rated'],
              'provider_rated': _result['requests'][i]['request']
                  ['provider_rated'],
              'route_key': _result['requests'][i]['request']['route_key'],
              'created_at': _result['requests'][i]['request']['created_at'],
              'updated_at': _result['requests'][i]['request']['updated_at'],
              'static_map': _result['requests'][i]['request']['static_map'],
              'service_type_name': _result['requests'][i]['request']
                  ['service_type']['name'],
              'service_type_provider': _result['requests'][i]['request']
                  ['service_type']['provider_name'],
              'service_type_image': _result['requests'][i]['request']
                  ['service_type']['image'],
              'service_type_marker': _result['requests'][i]['request']
                  ['service_type']['marker'],
              'service_type_fixed': _result['requests'][i]['request']
                  ['service_type']['fixed'],
              'service_type_description': _result['requests'][i]['request']
                  ['service_type']['description'],
              'service_type_price': _result['requests'][i]['request']
                  ['service_type']['price'],
            });
          }
        }
      }

      if (_data.length > 0) {
        for (int i = 0; i < _data.length; i++) {
          data.add({
            'id': _data[i]['id'],
            'booking_id': _data[i]['booking_id'],
            'user_id': _data[i]['user_id'],
            'estimated_fare': _data[i]['estimated_fare'],
            'service_type_id': _data[i]['service_type_id'],
            'before_image': _data[i]['before_image'],
            'status': _data[i]['status'],
            'cancelled_by': _data[i]['cancelled_by'],
            'cancel_reason': _data[i]['cancel_reason'],
            'payment_mode': _data[i]['payment_mode'],
            'paid': _data[i]['paid'],
            'is_track': _data[i]['is_track'],
            'distance': _data[i]['distance'],
            'travel_time': _data[i]['travel_time'],
            'unit': _data[i]['unit'],
            's_latitude': _data[i]['s_latitude'],
            's_longitude': _data[i]['s_longitude'],
            's_address': _data[i]['s_address'],
            'd_address': _data[i]['d_address'],
            'd_latitude': _data[i]['d_latitude'],
            'd_longitude': _data[i]['d_longitude'],
            'track_distance': _data[i]['track_distance'],
            'track_latitude': _data[i]['track_latitude'],
            'track_longitude': _data[i]['track_longitude'],
            'is_drop_location': _data[i]['is_drop_location'],
            'is_instant_ride': _data[i]['is_instant_ride'],
            'is_dispute': _data[i]['is_dispute'],
            'assigned_at': _data[i]['assigned_at'],
            'schedule_at': _data[i]['schedule_at'],
            'started_at': _data[i]['started_at'],
            'finished_at': _data[i]['finished_at'],
            'is_scheduled': _data[i]['is_scheduled'],
            'user_rated': _data[i]['user_rated'],
            'provider_rated': _data[i]['provider_rated'],
            'route_key': _data[i]['route_key'],
            'created_at': _data[i]['created_at'],
            'updated_at': _data[i]['updated_at'],
            'static_map': _data[i]['static_map'],
            'service_type_name': _data[i]['service_type']['name'],
            'service_type_provider': _data[i]['service_type']['provider_name'],
            'service_type_image': _data[i]['service_type']['image'],
            'service_type_marker': _data[i]['service_type']['marker'],
            'service_type_fixed': _data[i]['service_type']['fixed'],
            'service_type_description': _data[i]['service_type']['description'],
            'service_type_price': _data[i]['service_type']['price'],
          });
        }
      }
      return data;
    } catch (err) {
      print(err);
      List<Map<String, dynamic>> data = [];
      return data;
    }
  }

  Future<List<Map<String, dynamic>>> getTrips() async {
    try {
      List<Map<String, dynamic>> data = [];
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url = Uri.parse(AppEndPoints.BASE_URL + AppEndPoints.HISTORY_TRIPS);
      final http.Response response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer ' + token
      });
      List<dynamic> _data = json.decode(response.body);
      if (_data.length > 0) {
        for (int i = 0; i < _data.length; i++) {
          data.add({
            'id': _data[i]['id'],
            'booking_id': _data[i]['booking_id'],
            'user_id': _data[i]['user_id'],
            'estimated_fare': _data[i]['estimated_fare'],
            'service_type_id': _data[i]['service_type_id'],
            'before_image': _data[i]['before_image'],
            'status': _data[i]['status'],
            'cancelled_by': _data[i]['cancelled_by'],
            'cancel_reason': _data[i]['cancel_reason'],
            'payment_mode': _data[i]['payment_mode'],
            'paid': _data[i]['paid'],
            'is_track': _data[i]['is_track'],
            'distance': _data[i]['distance'],
            'travel_time': _data[i]['travel_time'],
            'unit': _data[i]['unit'],
            's_latitude': _data[i]['s_latitude'],
            's_longitude': _data[i]['s_longitude'],
            's_address': _data[i]['s_address'],
            'd_address': _data[i]['d_address'],
            'd_latitude': _data[i]['d_latitude'],
            'd_longitude': _data[i]['d_longitude'],
            'track_distance': _data[i]['track_distance'],
            'track_latitude': _data[i]['track_latitude'],
            'track_longitude': _data[i]['track_longitude'],
            'is_drop_location': _data[i]['is_drop_location'],
            'is_instant_ride': _data[i]['is_instant_ride'],
            'is_dispute': _data[i]['is_dispute'],
            'assigned_at': _data[i]['assigned_at'],
            'schedule_at': _data[i]['schedule_at'],
            'started_at': _data[i]['started_at'],
            'finished_at': _data[i]['finished_at'],
            'is_scheduled': _data[i]['is_scheduled'],
            'user_rated': _data[i]['user_rated'],
            'provider_rated': _data[i]['provider_rated'],
            'route_key': _data[i]['route_key'],
            'created_at': _data[i]['created_at'],
            'updated_at': _data[i]['updated_at'],
            'static_map': _data[i]['static_map'],
            'service_type_name': _data[i]['service_type']['name'],
            'payment_id': _data[i]['payment']['id'],
            'payment_request_id': _data[i]['payment']['request_id'],
            'payment_fixed': _data[i]['payment']['fixed'],
            'payment_distance': _data[i]['payment']['distance'],
            'payment_time_price': _data[i]['payment']['time_price'],
            'payment_minute': _data[i]['payment']['minute'],
            'payment_hour': _data[i]['payment']['hour'],
            'payment_commission': _data[i]['payment']['commission'],
            'payment_commission_per': _data[i]['payment']['commission_per'],
            'payment_agent': _data[i]['payment']['agent'],
            'payment_agent_per': _data[i]['payment']['agent_per'],
            'payment_discount': _data[i]['payment']['discount'],
            'payment_dicount_per': _data[i]['payment']['discount_per'],
            'payment_tax': _data[i]['payment']['tax'],
            'payment_tax_per': _data[i]['payment']['tax_per'],
            'payment_cash': _data[i]['payment']['cash'],
            'payment_round_of': _data[i]['payment']['round_of'],
            'payment_peak_amount': _data[i]['payment']['peak_amount'],
            'payment_toll_charge': _data[i]['payment']['toll_charge'],
            'payment_peak_comm_amount': _data[i]['payment']['peak_comm_amount'],
            'payment_total_waiting_time': _data[i]['payment']
                ['total_waiting_time'],
            'payment_waiting_amount': _data[i]['payment']['waiting_amount'],
            'payment_waiting_comm_amount': _data[i]['payment']
                ['waiting_comm_amount'],
            'payment_tips': _data[i]['payment']['tips'],
            'payment_total': _data[i]['payment']['total'],
            'payment_payable': _data[i]['payment']['payable'],
            'payment_provider_commission': _data[i]['payment']
                ['provider_commission'],
            'payment_provider_pay': _data[i]['payment']['provider_pay'],
            'service_type_provider': _data[i]['service_type']['provider_name'],
            'service_type_image': _data[i]['service_type']['image'],
            'service_type_marker': _data[i]['service_type']['marker'],
            'service_type_fixed': _data[i]['service_type']['fixed'],
            'service_type_description': _data[i]['service_type']['description'],
            'service_type_price': _data[i]['service_type']['price'],
            'after_image': _data[i]['updated_at']
          });
        }
      }
      return data;
    } catch (err) {
      print(err);
      List<Map<String, dynamic>> data = [];
      return data;
    }
  }

  Future<Map<String, dynamic>> rateTrip(
      String tripId, int rating, String comment) async {
    try {
      final Map<String, dynamic> formData = {
        'rating': rating,
        'comment': comment,
      };
      Map<String, dynamic> data = {};
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url = Uri.parse(
          AppEndPoints.BASE_URL + AppEndPoints.ACCEPT_TRIP + tripId + '/rate');
      final http.Response response =
          await http.post(url, body: json.encode(formData), headers: {
        'Authorization': 'Bearer ' + token,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      });

      data = json.decode(response.body);

      print(data);
      return data;
    } catch (err) {
      Map<String, dynamic> data = {'error': 'Something went wrong try again'};
      return data;
    }
  }
}
