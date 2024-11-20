import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:gpspro/Config.dart';
import 'package:gpspro/screens/WebViewScreen.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:gpspro/traccar_gennissi.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gpspro/storage/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gpspro/widgets/AlertDialogCustom.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AboutPageState();
}
  
class _AboutPageState extends State<AboutPage> {
  
  User? user;
  late SharedPreferences prefs;

  //StreamController<Device> _postsController;
  bool isLoading = true;
  final TextEditingController _newPassword = new TextEditingController();
  final TextEditingController _retypePassword = new TextEditingController();

  List<AboutModel> aboutList = [];
  @override
  initState() {
    super.initState();
    getUser();
  }

  getUser() async 
  {
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
    if(aboutList.isEmpty){
      aboutList.add(new AboutModel(("termsAndCondition").tr, TERMS_AND_CONDITIONS));
      aboutList.add(new AboutModel(("privacyPolicy").tr, PRIVACY_POLICY));
      aboutList.add(new AboutModel(("contactUs").tr, CONTACT_US));
   //   aboutList.add(new AboutModel(("Telegram").tr, WHATS_APP));
    }
    return new Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Container(
            color: CustomColor.primaryColor,
            padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
            child: new Column(children: <Widget>[
              Card(
                  color: CustomColor.primaryColor,
                  elevation: 30,
                  child: new Image.asset(
                    'images/logo.png',
                    height: 120.0,
                    fit: BoxFit.contain,
                  )),
              Text(APP_NAME,
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              Text(EMAIL,
                  style: TextStyle(color: Colors.white, fontSize: 13)),
              InkWell(
                onTap: () {
                  launch("tel://"+PHONE_NO);
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        child: Icon(Icons.call, color: Colors.white, size: 14),
                      ),
                      TextSpan(
                        text: PHONE_NO,
                      ),
                    ],
                  ),
                ),
              ), 
            ]),
          ),
          Container(
              color: Colors.white,
              child: new Column(
                children: <Widget>[aboutList.isNotEmpty ? loadList() : new Container()],
              )
          ),
           user != null ?
          //Container(child: 
       new Column(children: <Widget>[
         /*   const Padding(
              padding: EdgeInsets.all(1.0),
            ),*/
            new Container(
              //padding: const EdgeInsets.all(1.0),
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
         /*   new Container(
              child: settings(),
            ),*/
         ]) : new Center(child: new CircularProgressIndicator())   
        ],
      ),
    );
  }

  Widget loadList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: aboutList.length,
      itemBuilder: (context, index) {
        final urlItem = aboutList[index];
        return new Container(
            padding: const EdgeInsets.all(1.0), child: itemCardList(urlItem));
      },
    );
  }

  Widget itemCardList(AboutModel aboutItem) {
    return new Card(
        elevation: 1.0,
        child: InkWell(
          onTap: () async {
            if (aboutItem.title == ("whatsApp").tr) {
                await launch(aboutItem.url!);
            } else {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) =>  WebViewScreen(title: aboutItem.title!, url: aboutItem.url!)));
            }
          },
          child: Row(
            children: <Widget>[
              new Container(
                padding: EdgeInsets.only(left: 10.0, top: 5, bottom: 5),
                child: Text(aboutItem.title!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.0,
                    )),
              )
            ],
          ),
        ));
  }

  Widget logoutButton(){
  return user != null ?
       new Column(children: <Widget>[
         /*   const Padding(
              padding: EdgeInsets.all(1.0),
            ),*/
            new Expanded(
              //padding: const EdgeInsets.all(1.0),
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
          ])
    :
       new Center(
          child: new CircularProgressIndicator(),
        );      
    }
      
  Widget settings() {
    return new Card(
        elevation: 1.0,
        child: Column(
          children: <Widget>[            
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