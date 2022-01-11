import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mario_provider/resources/app_constants.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:http/http.dart' as http;

class UserRepo {
  Future<Map<String, dynamic>> getUserDetail() async {
    try {
      Map<String, dynamic> data = {};
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url =
          Uri.parse(AppEndPoints.BASE_URL + AppEndPoints.UPDATE_USER_DETAIL);
      final http.Response response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      });
      data = json.decode(response.body);
      return data;
    } catch (err) {
      Map<String, dynamic> data = {'sucess': false};
      return data;
    }
  }

  Future<Map<String, dynamic>> setStatus(bool status) async {
    try {
      String available = 'active';

      if (!status) {
        available = 'offline';
      }
      Map<String, dynamic> data = {};
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url = Uri.parse(AppEndPoints.BASE_URL +
          AppEndPoints.SET_USER_STATUS +
          '?service_status=' +
          available);
      final http.Response response = await http.post(url, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      });
      data = json.decode(response.body);
      return data;
    } catch (err) {
      Map<String, dynamic> data = {'sucess': false};
      return data;
    }
  }

  Future<Map<String, dynamic>> updateUserDetails(String fName, String lName,
      String email, String phone, String gender, String multipartFile) async {
    try {
      Map<String, dynamic> data = {};
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url = Uri.parse(AppEndPoints.BASE_URL +
          AppEndPoints.UPDATE_USER_DETAIL +
          '?first_name=' +
          fName +
          '&last_name=' +
          lName +
          '&email=' +
          email +
          '&mobile=' +
          phone +
          '&gender=' +
          gender);
      final http.Response response = await http.post(url, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer ' + token
      });

      if (multipartFile != null) {
        Map<String, String> headers = {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'Authorization': 'Bearer ' + token
        };
        Uri url =
            Uri.parse(AppEndPoints.BASE_URL + AppEndPoints.UPDATE_USER_DETAIL);
        var request = new http.MultipartRequest("POST", url);
        request.headers.addAll(headers);
        request.files
            .add(await http.MultipartFile.fromPath('picture', multipartFile));
        await request.send();
      }
      data = json.decode(response.body);

      return data;
    } catch (err) {
      print(err);
      Map<String, dynamic> data = {
        'errors': 'error',
        'message': 'Could not update'
      };
      return data;
    }
  }

  Future<Map<String, dynamic>> getDocument() async {
    try {
      Map<String, dynamic> data = {};
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url = Uri.parse(AppEndPoints.BASE_URL + AppEndPoints.GET_DOCUMENT);
      final http.Response response =
          await http.get(url, headers: {'Authorization': 'Bearer ' + token});
      data = json.decode(response.body);

      return data;
    } catch (err) {
      print(err);
      Map<String, dynamic> data = {};
      return data;
    }
  }

  Future<Map<String, dynamic>> uploadDocument(String file) async {
    try {
      bool hasError = true;
      String message = 'Document not uploaded,try again';
      SharedReferences references = new SharedReferences();
      String token = await references.getAccessToken();
      Uri url = Uri.parse(AppEndPoints.BASE_URL + AppEndPoints.POST_DOCUMENT);
      Map<String, String> headers = {
        // 'Accept': 'application/json',
        // 'Accept-Encoding': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer ' + token
      };
      var request = new http.MultipartRequest("POST", url);
      request.headers.addAll(headers);
      print(url);
      request.files.add(await http.MultipartFile.fromPath('document', file));
      var res = await request.send();
      if (res.statusCode == 200) {
        hasError = false;
        message = "Successfully Uploaded Image";
      }
      return {'success': !hasError, 'message': message};

      // final http.Response response =
      //     await http.post(url, body: json.encode(formData), headers:);
      // data = json.decode(response.body);

    } catch (err) {
      print(err);
      Map<String, dynamic> data = {
        'success': false,
        'message': 'Document not uploaded,try again'
      };
      return data;
    }
  }
}
