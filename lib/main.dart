import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mario_provider/repositories/shared_references/shared_references.dart';
import 'package:mario_provider/repositories/trip/trip_repo.dart';
import 'package:mario_provider/views/login_register/login_register.dart';
import 'package:mario_provider/views/map_order/map_order.dart';
import 'package:mario_provider/views/splashscreen/splashscreen.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
SharedReferences references = new SharedReferences();
String text;
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();
  print(message.data);
  print(
      'Handling a background message SERVICE mARio PROVUIDER APP ${message.toString()}');

  text = message.data['message'].toString();

  if (message.notification != null) {
    text += message.notification.toString();
  }

  if (text == "New Request") {
    final Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel desc',
      importance: Importance.max,
      vibrationPattern: vibrationPattern,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notify'),
      priority: Priority.high,
    );

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Service Mario Provider Alert',
      text,
      platformChannelSpecifics,
    );
  } else {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'channel id 1',
      'channel name 1',
      'channel desc 1',
      importance: Importance.max,
      playSound: true,
      priority: Priority.high,
    );

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Service Mario Provider Alert',
      text,
      platformChannelSpecifics,
    );
  }
}

Future<void> _requestPermission() async {
  try {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  } catch (e) {
    throw e;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  String a = await FirebaseMessaging.instance.getToken();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');
  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  _requestPermission();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Got a message whilst in the foreground! user ');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }

    text = message.data['message'].toString();

    if (message.notification != null) {
      text += message.notification.toString();
    }

    if (text == "New Request") {
      final Int64List vibrationPattern = Int64List(4);
      vibrationPattern[0] = 0;
      vibrationPattern[1] = 1000;
      vibrationPattern[2] = 5000;
      vibrationPattern[3] = 2000;
      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'channel id 2',
        'channel name 2',
        'channel desc 2',
        importance: Importance.max,
        vibrationPattern: vibrationPattern,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notify'),
        priority: Priority.high,
      );

      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      var platformChannelSpecifics = new NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        'Mario Service Provider Alert',
        text,
        platformChannelSpecifics,
      );
    } else {
      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'channel id 3',
        'channel name 3',
        'channel desc 3',
        importance: Importance.max,
        playSound: true,
        priority: Priority.high,
      );

      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      var platformChannelSpecifics = new NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        'Service Mario Provider Alert',
        text,
        platformChannelSpecifics,
      );
    }
  });
  await SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ],
  );

  //initilize inappbrowswer
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
          AndroidServiceWorkerController.instance();

      serviceWorkerController.serviceWorkerClient = AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      );
    }
  } else {
    //does it require any more installation for iOS?

  }
  runApp(MyApp());
}

Future selectNotification(String payload) async {
  print('payload' + text);

  if (text == 'New Request') {
    final TripRepo _providerRepo = new TripRepo();
    Map<String, dynamic> _trips = await _providerRepo.getTrips();

    if (_trips['error'] == 'Token has expired') {
      await references.removeAccessToken();
      await MyApp.navigatorKey.currentState.pushReplacement(
          MaterialPageRoute(builder: (context) => LoginRegisterPage()));
      return;
    }
    String loc = '';
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // debugPrint('location: ${position.latitude}');
    final coordinates = new Coordinates(
        double.parse(_trips['requests'][0]['request']['s_latitude']),
        double.parse(_trips['requests'][0]['request']['s_longitude']));
    // await _sharedReferences.setLatLng(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    loc = first.addressLine;

    await MyApp.navigatorKey.currentState.push(
        MaterialPageRoute(builder: (context) => MapOrder(_trips, loc, {})));
  }

  await flutterLocalNotificationsPlugin.cancelAll();
}

class MyApp extends StatelessWidget {
  static final navigatorKey = new GlobalKey<NavigatorState>();
  static const base_gray = const Color(0xff85878b);
  static const base_light_gray = const Color(0xffdfe4ef);
  static const primary_color = const Color(0xff6454de);
  static const primary_light_color = const Color(0xff9a81ff);
  static const primary_error_red = Colors.red;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service Mario Provider',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primaryColor: primary_color,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: base_gray),
        textTheme: TextTheme(
          subtitle1: TextStyle(
            fontWeight: FontWeight.w400,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          hintStyle: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 14,
          ),
          filled: true,
          disabledBorder: new OutlineInputBorder(
            borderSide: BorderSide(
              color: primary_color,
            ),
            borderRadius: const BorderRadius.all(
              const Radius.circular(25.0),
            ),
          ),
          enabledBorder: new OutlineInputBorder(
            borderSide: BorderSide(
              color: primary_color,
            ),
            borderRadius: const BorderRadius.all(
              const Radius.circular(25.0),
            ),
          ),
          errorBorder: new OutlineInputBorder(
            borderSide: BorderSide(
              color: primary_error_red,
            ),
            borderRadius: const BorderRadius.all(
              const Radius.circular(25.0),
            ),
          ),
          focusedBorder: new OutlineInputBorder(
            borderSide: BorderSide(color: primary_color),
            borderRadius: const BorderRadius.all(
              const Radius.circular(25.0),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) return Colors.grey;
                return primary_color;
              },
            ),
            minimumSize: MaterialStateProperty.resolveWith<Size>(
              (states) => Size(50, 50),
            ),
            // elevation: MaterialStateProperty.resolveWith<double>(
            //   (Set<MaterialState> states) {
            //     return 0.0;
            //   },
            // ),
            padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
              (Set<MaterialState> states) {
                return const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0);
              },
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                return base_gray;
              },
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white, size: 8),
          textTheme: TextTheme(
            headline6: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          titleTextStyle: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
