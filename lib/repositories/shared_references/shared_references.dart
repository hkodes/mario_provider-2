import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedReferences {
  var isFirst = true;

  Future<bool> getPrefernce() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirst = prefs.getBool('isFirstTime');
    return isFirst;
  }

  Future<void> setPrefernce() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstTime', false);
  }

  Future<void> setAccessToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (await getAccessToken() != null) {
      await removeAccessToken();
    }
    prefs.setString('access_token', token);
  }

  Future<void> setUserId(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (await getUserId() != null) {
      await removeUserId();
    }
    prefs.setInt('userId', id);
  }

  Future<String> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<int> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> removeAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('access_token');
  }

  Future<void> removeUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
  }

  Future<void> setLatLng(double lat, double long) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('user_latitiude', lat);
    prefs.setDouble('user_longitude', long);
  }

  Future<void> removeLatLng() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user_latitiude');
    prefs.remove('user_longitude');
  }

  Future<LatLng> getLatLng() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    double latitude = prefs.getDouble('user_latitiude');
    double longitude = prefs.getDouble('user_longitude');

    return LatLng(latitude, longitude);
  }

  Future<void> setStatus(bool status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('status', status);
  }

  Future<void> removeStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('status');
  }

  Future<bool> getStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('status');
  }

  Future<void> setCurrency(String currency) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('currency', currency);
  }

  Future<String> getCurrency() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('currency');
  }

  Future<void> removeCurrency() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('currency');
  }
}
