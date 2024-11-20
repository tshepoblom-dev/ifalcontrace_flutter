import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:gpspro/storage/user_repository.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:gpspro/widgets/AlertDialogCustom.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../traccar_gennissi.dart';

class SettingsPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? user;
  late SharedPreferences prefs;

  //StreamController<Device> _postsController;
  bool isLoading = true;
  final TextEditingController _newPassword = new TextEditingController();
  final TextEditingController _retypePassword = new TextEditingController();

  @override
  initState() {
    //_postsController = new StreamController();
    super.initState();
    getUser();
  }

  getUser() async {
    prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString("user");

    final parsed = json.decode(userJson ?? '');
    user = User.fromJson(parsed);
    setState(() {});
  }

  logout() {
    Traccar.sessionLogout().then((value) => {
      UserRepository.doLogout(),
      Phoenix.rebirth(context)
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return Scaffold(
          appBar: AppBar(
            title: Text(('settings').tr,
                style: TextStyle(color: CustomColor.secondaryColor)),
            iconTheme: IconThemeData(
              color: CustomColor.secondaryColor, //change your color here
            ),
          ),
          body: new Column(children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(1.0),
            ),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: new Card(
                elevation: 1.0,
                child: ListTile(
                  title: Text(
                    new String.fromCharCodes(new Runes(user!.name!)),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    new String.fromCharCodes(new Runes(user!.email!)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: OutlinedButton(
                    onPressed: () {
                      logout();
                    },
                    child: Text(
                        ("logout").tr,
                        style: TextStyle(fontSize: 15)),
                  ),
                ),
              ),
            ),
            new Expanded(
              child: settings(),
            ),
          ]));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(('settings').tr),
        ),
        body: new Center(
          child: new CircularProgressIndicator(),
        ),
      );
    }
  }

  Widget settings() {
    return new Card(
        elevation: 1.0,
        child: Column(
          children: <Widget>[
            // ListTile(
            //   title: Text(
            //     AppLocalizations.of(context)
            //         .translate("diablePopupNotification"),
            //     style: TextStyle(fontSize: 13),
            //   ),
            //   trailing: Switch(
            //       value: prefs.getBool("popup_notify"),
            //       onChanged: (bool x) {
            //         prefs.setBool("popup_notify", x);
            //         setState(() {});
            //       }),
            // ),
            // Divider(),
           /* ListTile(
              title: Text("Notifications"),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.pushNamed(context, "/enableNotifications");
              },
            ),*/
            Divider(),
            ListTile(
              title: Text(
                ("changePassword").tr,
                style: TextStyle(fontSize: 13),
              ),
              onTap: () {
                changePasswordDialog(context);
              },
            ),
          /*  Divider(),
            ListTile(
              title: Text(
                ("userExpirationTime").tr,
                style: TextStyle(fontSize: 13),
              ),
              trailing: Text(
                user!.expirationTime != null
                    ? formatTime(user!.expirationTime!)
                    : 'Not Found',
                style: TextStyle(fontSize: 13),
              ),
            ),
            Divider(),
            ListTile(
                title: Text(
                  ("sharedMaintenance").tr,
                  style: TextStyle(fontSize: 13),
                ),
                onTap: (){
                  Navigator.pushNamed(context, "/maintenance");
                }
            ),
            Divider(),*/
          ],
        ));
  }

  void changePasswordDialog(BuildContext context) {
    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: 220.0,
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
                          new Container(
                            child: new TextField(
                              controller: _newPassword,
                              decoration: new InputDecoration(
                                  labelText: ('newPassword').tr),
                              obscureText: true,
                            ),
                          ),
                          new Container(
                            child: new TextField(
                              controller: _retypePassword,
                              decoration: new InputDecoration(
                                  labelText: ('retypePassword').tr),
                              obscureText: true,
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
                                child: Text(
                                  ('cancel').tr,
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  updatePassword();
                                },
                                child: Text(('ok').tr,
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
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

  void updatePassword() {
    if (_newPassword.text == _retypePassword.text) {
      final user = User.fromJson(jsonDecode(prefs.getString("userJson")!));
      user.password = _newPassword.text;
      String userReq = json.encode(user.toJson());

      Traccar.updateUser(userReq, prefs.getString("userId")!).then((value) => {
            AlertDialogCustom().showAlertDialog(
                context,('passwordUpdatedSuccessfully').tr,
                ('changePassword').tr,
                ('ok').tr)
          });
    } else {
      AlertDialogCustom().showAlertDialog(
          context,
          ('passwordNotSame').tr,
          ('failed').tr,
          ('ok').tr);
    }
  }
}
