
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:gpspro/screens/About.dart';
import 'package:gpspro/screens/Dashboard.dart';
import 'package:gpspro/screens/Devices.dart';
import 'package:gpspro/screens/MapHome.dart';
import 'package:gpspro/theme/CustomColor.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeState();
}

// ignore: unused_element
String _notificationToken = "";


class _HomeState extends State<HomePage> {
  int _selectedIndex = 0;
  late String email;
  late String password;
  AppLifecycleState? _notification;
  List<String>? devicesId = [];

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Scaffold(
        extendBody: true,
        body: IndexedStack(
                index: _selectedIndex,
                children: <Widget>[
                  MapPage(),
                  DevicePage(),
                  DashboardPage(),
                //  SettingsPage(),
                  AboutPage()
                ],
              ),
        bottomNavigationBar: CurvedNavigationBar(
          color: CustomColor.primaryColor,
          index: _selectedIndex,
          height: 50,
          backgroundColor: Colors.transparent,
          items: [
             Icon(
              Icons.map,
              size: 25,
              color: CustomColor.secondaryColor,
            ),
            Icon(Icons.directions_car_rounded,
                size: 25, color: CustomColor.secondaryColor),
            Icon(Icons.notifications,
                size: 25, color: CustomColor.secondaryColor),
          //  Icon(Icons.settings, size: 25, color: CustomColor.secondaryColor),
            Icon(Icons.info, size: 25, color: CustomColor.secondaryColor),
          ],
          animationDuration: Duration(milliseconds: 300),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            //Handle button tap
          },
        ),
      ));
  }
}
