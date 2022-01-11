import 'dart:async';
import 'dart:convert';
import 'package:mario_provider/resources/app_constants.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:http/http.dart' as http;

class ServicesRepo {
  Future<List<Map<String, dynamic>>> getAllServices() async {
    try {
      List<Map<String, dynamic>> data = [];
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url = Uri.parse(AppEndPoints.BASE_URL + AppEndPoints.GET_SERVICES);
      final http.Response response =
          await http.get(url, headers: {'Authorization': 'Bearer ' + token});
      List<dynamic> _data = json.decode(response.body);
      if (_data.length > 0) {
        for (int i = 0; i < _data.length; i++) {
          data.add({
            'id': _data[i]['id'],
            'parent_id': _data[i]['parent_id'],
            'agent_id': _data[i]['agent_id'],
            'name': _data[i]['name'],
            'provider_name': _data[i]['provider_name'],
            'image': _data[i]['image'],
            'marker': _data[i]['marker'],
            'fixed': _data[i]['fixed'],
            'price': _data[i]['price'],
            'type_price': _data[i]['type_price'],
            'calculator': _data[i]['calculator'],
            'description': _data[i]['description'],
            'status': _data[i]['status'],
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

  Future<Map<String, dynamic>> addService(
      int service, String name, String model) async {
    try {
      Map<String, dynamic> data = {};

      final Map<String, dynamic> formData = {
        'service_type': service,
        'service_number': name,
        'service_model': model,
        'method': 'create'
      };
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url = Uri.parse(AppEndPoints.BASE_URL + AppEndPoints.ADD_SERVICE);
      final http.Response response =
          await http.post(url, body: json.encode(formData), headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer ' + token
      });
      data = json.decode(response.body);
      return data;
    } catch (err) {
      Map<String, dynamic> data = {};
      return data;
    }
  }
}
