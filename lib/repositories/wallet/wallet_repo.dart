import 'dart:async';
import 'dart:convert';
import 'package:mario_provider/resources/app_constants.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:http/http.dart' as http;

class WalletRepo {
  Future<Map<String, dynamic>> getWalletInfo() async {
    try {
      Map<String, dynamic> data = {};
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url = Uri.parse(AppEndPoints.BASE_URL + AppEndPoints.USER_WALLET);
      final http.Response response = await http.get(url, headers: {
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
