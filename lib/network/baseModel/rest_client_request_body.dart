import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

class RestClientRequestBody<T> {
  String url;
  List<RequestHeader> requestHeaders;
  T body;
  FormData formData;

  RestClientRequestBody(
      {@required String url,
      List<RequestHeader> requestHeaders,
      T body,
      FormData formData})
      : url = url,
        requestHeaders = requestHeaders,
        body = body,
        formData = formData;
}

class RequestHeader {
  String key;
  String value;

  RequestHeader(this.key, this.value);

  @override
  String toString() {
    return 'RequestHeader{_key: $key, _value: $value}';
  }
}
