import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:gpspro/Config.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../traccar_gennissi.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType { login, register }

class _LoginPageState extends State<LoginPage> {
  late SharedPreferences prefs;

  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  final TextEditingController _serverFilter = new TextEditingController();

  String? dropdownValue;
  String _url = "http://ifalcontrace.cloud:8082";
  String _email = "";
  String _password = "";
  String _notificationToken = "";
  FormType _form = FormType
      .login; // our default setting is to login, and we should switch to creating an account when the user chooses to

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
    //_serverFilter.addListener(_urlListen);
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);

    Permission _permission2 = Permission.notification;
    _permission2.request();

    checkPreference();
    initFirebase();
    super.initState();
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


  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();

    prefs.setString("url", _url);
    if (prefs.getString("language") != null) {
      if(prefs.getString("language") == "es"){
        dropdownValue =  "Español";
      }else if(prefs.getString("language") == "en"){
        dropdownValue =  "English";
      }else if(prefs.getString("language") == "pt"){
        dropdownValue =  "Portugués";
      }else if(prefs.getString("language") == "fr"){
        dropdownValue =  "French";
      }
    }else{
      dropdownValue = "English";
    }

  /*  if (prefs.get('url') != null) {
      _serverFilter.text = prefs.getString('url')!;
    } else {
      _serverFilter.text = _url;
    }*/

    if (prefs.get('email') != null) {
      _emailFilter.text = prefs.getString('email')!;
      _passwordFilter.text = prefs.getString('password')!;
      _serverFilter.text = prefs.getString('url')!;
      _loginPressed();
    } else {
      setState(() {});
    }
  }
  //
  // void _urlListen() {
  //   if (_serverFilter.text.isEmpty) {
  //     _url = "";
  //   } else {
  //     _url = _serverFilter.text;
  //   }
  // }

  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _email = "";
    } else {
      _email = _emailFilter.text;
    }
  }

  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
    }
  }

  // Swap in between our two forms, registering and logging in
  void _formChange() async {
    setState(() {
      if (_form == FormType.register) {
        _form = FormType.login;
      } else {
        _form = FormType.register;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: CustomColor.primaryColor,
      appBar: new AppBar(
        elevation: 0,
        title: new Text(('loginTitle').tr,
            style: TextStyle(color: CustomColor.secondaryColor)),
        centerTitle: true,
       /* actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: GestureDetector(
                onTap: () {
                  showServerDialog(context);
                },
                child: Icon(Icons.settings)),
          )
        ],*/
      ),
      body: new Container(
          padding: EdgeInsets.all(16.0),
          child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(15.0),
              children: <Widget>[
              Column(
                            children: <Widget>[_buildTextFields()],
                          )
              ])),
    );
  }

  void showServerDialog(BuildContext context) {
    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: 170,
            width: 300.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Text(('serverURl').tr),
                            ],
                          ),
                          new Container(
                            child: new TextField(
                              controller: _serverFilter,
                              decoration: new InputDecoration(
                                  labelText:
                                      'Server Url eg: http://demo.ifalcontrace.com'),
                            ),
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Colors.red, // foreground
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(('cancel').tr,
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  prefs.setString("url", _serverFilter.text);
                                  Navigator.pop(context);
                                },
                                child: Text(('ok').tr,
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }));
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  Widget _buildTextFields() {
    return new Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(50.0),
      child: new Column(
        children: <Widget>[
          new Container(
            child:Image.asset(
                'images/logo.png',
                width: 200,
                height: 200,
              ),
          ),
         /* new Container(
              child: DropdownButton<String>(
                value: dropdownValue,
                elevation: 16,
                style: TextStyle(color: CustomColor.primaryColor),
                underline: Container(
                  height: 2,
                  color:  CustomColor.primaryColor,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                    print(dropdownValue);
                    if (newValue == "French") {
                      prefs.setString("language", "fr");
                      Get.updateLocale(Locale("fr", ''));
                    } else if (newValue == "Español") {
                      prefs.setString("language", "es");
                      Get.updateLocale(Locale("es", ''));
                    } else if (newValue == "English") {
                      prefs.setString("language", "en");
                      Get.updateLocale(Locale("en", ''));
                    }else if (newValue == "Portugués") {
                      prefs.setString("language", "pt");
                      Get.updateLocale(Locale("pt", ''));
                    }
                  });
                  Phoenix.rebirth(context);
                },
                items: <String>["English",'French', 'Español', 'Portugués']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )),*/
          new Container(
            child: new TextField(
              controller: _emailFilter,
              decoration: new InputDecoration(
                  labelText:('username').tr),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _passwordFilter,
              decoration: new InputDecoration(
                  labelText:('userPassword').tr),
              obscureText: false,
            ),
          ),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    if (_form == FormType.login) {
      return new Container(
        width: MediaQuery.of(context).size.width,
        child: new Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(5),
            ),
            GestureDetector(
                onTap: () {
                  _loginPressed();
                },
                child:
                Container(
                    width: 160,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: CustomColor.primaryColor,
                        border: Border.all(
                          color: CustomColor.primaryColor,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 15.0,
                            offset: Offset(2, 10.0),
                          )
                        ]
                    ),
                    child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        crossAxisAlignment:
                        CrossAxisAlignment.center,
                        children: <Widget>[ Text(('loginTitle').tr,
                          style: TextStyle(color: Colors.white),)
                        ]))),
            new TextButton(
              child: new Text(DEVELOPED_BY),
              onPressed: (){

              },
            ),
          ],
        ),
      );
    } else {
      return new Container(
        child: new Column(
          children: <Widget>[
            new Container(
              child: ElevatedButton(
                onPressed: () {
                  _createAccountPressed();
                },
                child: Text("Submit", style: TextStyle(fontSize: 18)),
              ),
            ),
            new TextButton(
              child: new Text('Have an account? Click here to login.'),
              onPressed: _formChange,
            )
          ],
        ),
      );
    }
  }

  void _loginPressed() async {
    try {
      _showProgress(true);
      Traccar.login(_email, _password).then((response) {
        if (response != null) {
          if (response.statusCode == 200) {
            prefs.setString("user", response.body);
            _showProgress(false);
            final user = User.fromJson(jsonDecode(response.body));
            prefs.setString("userId", user.id.toString());
            prefs.setString("userJson", response.body);
            updateUserInfo(user, user.id.toString());
            Navigator.pushReplacementNamed(context, '/home');
          } else if (response.statusCode == 401) {
            _showProgress(false);
            Fluttertoast.showToast(
                msg: ("loginFailed").tr,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0);
            setState(() {});
          } else if (response.statusCode == 400) {
            if (response.body ==
                "Account has expired - SecurityException (PermissionsManager:259 < *:441 < SessionResource:104 < ...)") {
              setState(() {});
              showDialog(
                context: context,
                builder: (context) => new AlertDialog(
                  title:
                      Text(("failed").tr),
                  content: Text(
                     ("loginFailed").tr),
                  actions: <Widget>[
                    new TextButton(
                      onPressed: () {
                        _showProgress(false);
                        Navigator.of(context, rootNavigator: true)
                            .pop(); // dismisses only the dialog and returns nothing
                      },
                      child: new Text(
                          ("ok").tr),
                    ),
                  ],
                ),
              );
            }
          } else {
            _showProgress(false);
            Fluttertoast.showToast(
                msg: response.body,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0);
            setState(() {});
          }
        } else {
          setState(() {});
          _showProgress(false);
          Fluttertoast.showToast(
              msg: ("errorMsg").tr,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      });
    } catch (e) {
      _showProgress(false);
      setState(() {});
    }
  }

  void _createAccountPressed() {
    print('The user wants to create an account with $_email and $_password');
  }

  void updateUserInfo(User user, String id) {
    var oldToken = user.attributes!["notificationTokens"].toString().split(",");
    var tokens = user.attributes!["notificationTokens"];

    if (user.attributes!.containsKey("notificationTokens")) {
      if (!oldToken.contains(_notificationToken)) {
        user.attributes!["notificationTokens"] =
            _notificationToken + "," + tokens;
      }
    } else {
      user.attributes!["notificationTokens"] = _notificationToken;
    }

    String userReq = json.encode(user.toJson());

    Traccar.updateUser(userReq, id).then((value) => {});
  }

  Future<void> _showProgress(bool status) async {
    if (status) {
      return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: [
                CircularProgressIndicator(),
                Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text(('sharedLoading').tr)),
              ],
            ),
          );
        },
      );
    } else {
      Navigator.pop(context);
    }
  }
}
