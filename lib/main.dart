
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gpspro/locale/translation_service.dart';
import 'package:gpspro/routes.dart';
import 'package:gpspro/storage/user_repository.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  UserRepository.prefs = await SharedPreferences.getInstance(); 
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  runApp(Phoenix(child:MyApp()));
}

SharedPreferences? prefs;
String langCode = "en";
Locale? _locale;
// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MyAppPageState();
}

class _MyAppPageState extends State<MyApp> {
  GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();
    checkPreference();
  }


  Future<String> checkPreference() async {
    if (UserRepository.getLanguage() == null) {
      UserRepository.setLanguage("en");
      _locale = TranslationService.locale;
      Get.updateLocale(const Locale('en', 'US'));
    } else {
      langCode = UserRepository.getLanguage()!;
      _locale = Locale(langCode);
      if(langCode == "en") {
        Get.updateLocale(const Locale('en', 'US'));
      }else if(langCode == "es") {
        Get.updateLocale(const Locale('te', 'IN'));
      }else{
        langCode = UserRepository.getLanguage()!;
        _locale = Locale(langCode);
      }
    }
    return langCode;
  }


  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GetMaterialApp(
      enableLog: true,
      locale: _locale,
      fallbackLocale: TranslationService.fallbackLocale,
      translations: TranslationService(),
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'OpenSans',
        primarySwatch: CustomColor.primaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: routes,
    );
  }
}
