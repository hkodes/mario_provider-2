import 'dart:async';
import 'dart:convert';
import 'package:mario_provider/resources/app_constants.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:http/http.dart' as http;

class TripRepo {
  Future<Map<String, dynamic>> getTrips() async {
    try {
      Map<String, dynamic> data = {};
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url =
          Uri.parse(AppEndPoints.BASE_URL + AppEndPoints.GET_DASHBOARD_LIST);
      final http.Response response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer ' + token
      });
      data = json.decode(response.body);
      return data;
    } catch (err) {
      Map<String, dynamic> data = {'sucess': false};
      return data;
    }
  }

  Future<Map<String, dynamic>> getsummary() async {
    try {
      Map<String, dynamic> data = {};
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url = Uri.parse(AppEndPoints.BASE_URL + AppEndPoints.USER_SUMMARY);
      final http.Response response = await http.post(url, headers: {
        'Accept': 'application/json',
        'Accept-Encoding': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer ' + token
      });
      data = json.decode(response.body);
      return data;
    } catch (err) {
      Map<String, dynamic> data = {'sucess': false};
      return data;
    }
  }
}
