class AppConstants {
  static const double APP_VERSION = 1.0;

  static const String URL_POLICY =
      'https://www.termsandcondiitionssample.com/live.php?token=wCByiKpLOyYRlpi9bwdyH0p0SV93PX3r';
  static const String URL_TERMS_AND_CONDITION =
      'https://www.termsandcondiitionssample.com/live.php?token=wCByiKpLOyYRlpi9bwdyH0p0SV93PX3r';

  ///appStore link
  static const String APP_STORE_LINK = 'https://google.com.np';
  static const String SERVICE_PROVIDER_APP_STORE_LINK = 'https://google.com.np';
}

class AppEndPoints {
  ///base url

  static const String BASE_URL =
      'http://ec2-52-196-238-46.ap-northeast-1.compute.amazonaws.com';
  // static const String BASE_URL = 'https://thinkinservice.thinkindragon.com/';

  ///Key
  // static const String CLIENT_ID = '2';
  // static const String CLIENT_SECRET =
  //     '0b4A1sus2hz9E3AatyxPZJLd1t7AKre4zZTXCAgl';
  static const String CLIENT_ID = '2';
  static const String CLIENT_SECRET =
      'ORW3GSdPSrBbgw6S7PI0SjGMlRvmchd38xFh4WHU';

  /// check api if online or not
  static const String CHECK_API = '/api/user/checkapi';

  ///provider login/logOut
  static const String USER_LOGIN = '/api/provider/oauth/token';
  static const String USER_LOGOUT = '/api/provider/logout';

  ///provider signin
  static const String USER_SIGN_UP = '/api/provider/register';

  /// check api if online or not
  static const String CHANGE_PASSWORD = '/api/provider/profile/password';
  static const String FORGOT_PASSWORD = '/api/provider/forgot/password';
  static const String RESET_PASSWORD = '/api/provider/reset/password';

  static const String CHECK_EMAIL = '/api/user/checkemail';

  ///load all [TRIP] list
  static const String GET_DASHBOARD_LIST = '/api/provider/trip';

  ///load [DOCUMENT]
  static const String GET_DOCUMENT = '/api/provider/profile/documents';
  static const String POST_DOCUMENT = '/api/provider/profile/documents/store';

  ///[OLD_API]
  ///[OLD_API]
  ///[OLD_API]
  ///[OLD_API]
  ///[OLD_API]
  ///get user details
  static const String GET_USER_DETAIL_S = '/api/provider/details';
  static const String UPDATE_USER_DETAIL = '/api/provider/profile';

  ///get Service Categories
  static const String GET_SERVICE_CATEGORIES = '/api/provider/services';

  static const String GET_SERVICES = '/api/provider/get-service';

  ///location service
  static const String UPDATE_USER_LOCATION_UPDATE_USER_LOCATION =
      '/api/provider/update/location';
  static const String USER_LOCATION = '/api/provider/profile/location';

  ///service
  static const String GET_SERVICE_PROVIDER = '/api/provider/show/providers';

  static const String ADD_SERVICE = '/api/provider/create-update-service';

  ///Set User Online Status
  static const String SET_USER_STATUS = '/api/provider/profile/available';

  ///upcoming trip
  static const String UPCOMING_TRIPS = '/api/provider/requests/upcoming';
  static const String GET_UPCOMING_TRIP_DETAIL =
      '/api/provider/requests/upcoming/details';

  ///history trip
  static const String HISTORY_TRIPS = '/api/provider/requests/history';
  static const String HISTORY_TRIPS_DETAIL =
      '/api/provider/requests/history/details';

  ///dispute
  static const String GET_DISPUTE_LIST_USER =
      '/api/provider/dispute-list?dispute_type=provider';

  ///notification
  static const String GET_NOTIFICAION_LIST = '/api/provider/notifications/all';

  ///banner
  static const String GET_BANNER_IMAGE = '/api/provider/banner';

  ///wwallet
  static const String USER_WALLET = '/api/provider/wallettransaction';

  ///promoCode
  static const String GET_PROMO_CODE = '/api/provider/promocodes_list';

  ///help
  static const String GET_HELP = '/api/provider/help';

  ///send message
  static const String SEND_MESSAGE = '/api/provider/chat';

  ///validate Otp
  static const String VALIDATE_OTP = '/api/provider/check-otp';

  ///order service
  static const String ORDER = '/api/provider/send/request';
  static const String CANCEl_ORDER = '/api/provider/cancel';

  static const String TRIP = '/api/provider/trip';

  ///CALCULATE_FARE
  static const String CALCULATE_FARE = '/api/provider/estimated/fare';

  ///RETERIVE SUMMARY
  static const String USER_SUMMARY = '/api/provider/summary';

  static const String ACCEPT_TRIP = '/api/provider/trip/';
  static const String UPDATE_TRIP = '/api/provider/trip/';
  static const String REVIEW_USER = '/api/provider/trip/';
}
