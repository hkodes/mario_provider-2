// class RestResponse<T> {
//   T responseData;
//   String message;
//   int status;
//
//   RestResponse({this.responseData, this.message, this.status});
//
//   RestResponse.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     responseData = json['data'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.responseData != null) {
//       data['data'] = this.responseData;
//     }
//     return data;
//   }
// }
