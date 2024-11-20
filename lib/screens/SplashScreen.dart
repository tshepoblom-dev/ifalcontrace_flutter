import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:gpspro/Config.dart';
import 'package:gpspro/storage/dataController/DataController.dart';
import 'package:gpspro/storage/user_repository.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../traccar_gennissi.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  late SharedPreferences prefs;

  String _notificationToken = "RzBFAiEAk7acoUqz1u34y608t3Je-H5QaCnWNqFu5AD2061Fn-MCIBHodz6vt4sdsU5bJzTccWPtSt1sUnjqkVZUhB9aBxZTeyJ1IjoxLCJlIjoiMjAyNC0xMi0zMFQyMjowMDowMC4wMDArMDA6MDAifQ";
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    checkPreference();
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.notification,
    ].request();
    prefs.setBool("ads", true);
    if (prefs.get('email') != null) {
      if (prefs.get("popup_notify") == null) {
        prefs.setBool("popup_notify", true);
      }
      initFirebase();
      checkLogin();
    } else {
      prefs.setBool("popup_notify", true);
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.getToken().then((value) => {_notificationToken = value!});

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(message.notification!.title);
      print(message.notification!.body);
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              "0", message.notification!.title.toString(),
              channelDescription: message.notification!.body.toString(),
              channelShowBadge: false,
              importance: Importance.max,
              priority: Priority.high,
              onlyAlertOnce: true);
      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(0, message.notification!.title,
          message.notification!.body, platformChannelSpecifics,
          payload: 'item x');
    });

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void checkLogin() {
    DataController? _dataController;
    Future.delayed(const Duration(milliseconds: 5000), () {
      Traccar.login(UserRepository.getEmail(), UserRepository.getPassword())
          .then((response) {
        _dataController = Get.put(DataController());
        if (response != null) {
          if (response.statusCode == 200) {
            prefs.setString("user", response.body);
            final user = User.fromJson(jsonDecode(response.body));
            updateUserInfo(user, user.id.toString());
            prefs.setString("userId", user.id.toString());
            prefs.setString("userJson", response.body);
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            Navigator.pushReplacementNamed(context, '/login');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    });
  }

  void updateUserInfo(User user, String id) {
    if (user.attributes != null) {
      var oldToken =
          user.attributes!["notificationTokens"].toString().split(",");
      var tokens = user.attributes!["notificationTokens"];

      if (user.attributes!.containsKey("notificationTokens")) {
        if (!oldToken.contains(_notificationToken)) {
          user.attributes!["notificationTokens"] =
              _notificationToken + "," + tokens;
        }
      } else {
        user.attributes!["notificationTokens"] = _notificationToken;
      }
    } else {
      user.attributes = new HashMap();
      user.attributes?["notificationTokens"] = _notificationToken;
    }

    String userReq = json.encode(user.toJson());

    Traccar.updateUser(userReq, id).then((value) => {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Container(
            child: new Column(children: <Widget>[
              new Image.asset(
                  'images/logo.png',
                  height: 250.0,
                  fit: BoxFit.contain,
                ),
              Padding(
                padding: EdgeInsets.all(20),
              ),
              Text(SPLASH_SCREEN_TEXT1,
                  style:
                      TextStyle(color: CustomColor.primaryColor, fontSize: 20)),
              Text(SPLASH_SCREEN_TEXT2,
                  style:
                      TextStyle(color: CustomColor.primaryColor, fontSize: 15)),
              Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )
            ]),
          ),
        ],
      ),
    );
  }
}
