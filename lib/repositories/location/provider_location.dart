import 'dart:async';
import 'dart:convert';
import 'package:mario_provider/resources/app_constants.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:http/http.dart' as http;

class ProviderLocationRepo {
  Future<Map<String, dynamic>> updateProviderLocation(
      double lat, double long) async {
    try {
      Map<String, dynamic> data = {};
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url = Uri.parse(AppEndPoints.BASE_URL +
          AppEndPoints.USER_LOCATION +
          '?latitude=' +
          lat.toString() +
          '&longitude=' +
          long.toString());
      final http.Response response = await http.post(url, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer ' + token
      });
      data = json.decode(response.body);
      print(data);
      return data;
    } catch (err) {
      print(err);
      Map<String, dynamic> data = {'error': 'Error While Updating'};
      return data;
    }
  }
}
