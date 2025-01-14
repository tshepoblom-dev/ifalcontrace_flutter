import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gpspro/arguments/DeviceArguments.dart';
import 'package:gpspro/screens/CommonMethod.dart';
import 'package:gpspro/theme/CustomColor.dart';

import '../../traccar_gennissi.dart';

class DeviceInfo extends StatefulWidget {
  @override
  _DeviceInfoState createState() => _DeviceInfoState();
}

class _DeviceInfoState extends State<DeviceInfo> {
  DeviceArguments? args;

  @override
  initState() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (args != null) {
        timer.cancel();
        setState(() {

        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as DeviceArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args!.name,
            style: TextStyle(color: CustomColor.secondaryColor)),
        iconTheme: IconThemeData(
          color: CustomColor.secondaryColor, //change your color here
        ),
      ),
      body: args != null ? SingleChildScrollView(child: loadDevice()) : Center(child: CircularProgressIndicator()),
    );
  }

  Widget loadDevice() {
    Device? d = args!.device;
    String iconPath = "images/marker_default_offline.png";
    Map<String, dynamic> attributes = d.attributes!;
    String status;
    String driverName="";

    for(var entry in attributes.entries){
      if(entry.key == "driver"){
        driverName = entry.value.toString();
      }
    }
    if (d.status == "unknown") {
      status = 'static';
    } else {
      status = d.status!;
    }
    if (d.category != null) {
      iconPath = "images/marker_" + d.category! + "_" + status + ".png";
    } else {
      iconPath = "images/marker_default" + "_" + status + ".png";
    }
    return new Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(1.0),
        ),
        new Container(
          child: new Padding(
            padding: const EdgeInsets.all(1.0),
            child: new Card(
              elevation: 5.0,
              child: Column(children: <Widget>[
                Container(
                    child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 10.0, left: 5.0),
                      child: Image.asset(
                        iconPath,
                        width: 50,
                        height: 50,
                      ),
                    ),
                      Container(
                      padding: EdgeInsets.only(top: 10.0, left: 5.0),
                      child: Text(driverName, 
                            overflow: TextOverflow.ellipsis, 
                            maxLines: 2,  
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),),
                    ),
                    Container(
                        width: 200,
                        padding: EdgeInsets.only(top: 10.0, left: 5.0),
                        child: Text(
                          d.status!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                )),
                SizedBox(height: 5.0),
              ]),
            ),
          ),
        ),
        Container(child: mainInfo()),
        Container(child: positionDetails()),
      //Container(child: Text("Sensors", style: TextStyle(fontSize: 16))),
      //Container(child: sensorInfo())
      ],
    );
  }

  Widget positionDetails() {
    if (args!.positionModel != null) {
      return Card(
        elevation: 5.0,
        child: Container(
              padding: const EdgeInsets.all(10.0),
              child:
               Column(
          children: <Widget>[          
       
         
        //  SizedBox(height: 5.0),
          args!.positionModel!.address != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                   //   padding: EdgeInsets.only(left: 5.0),
                      child: Icon(Icons.location_on_outlined,
                          color: CustomColor.primaryColor, size: 25.0),
                    ),
                    Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                               padding: EdgeInsets.only(
                                    top: 10.0, left: 5.0, right: 0),
                                child: Text(
                                  utf8.decode(args!.positionModel!.address!.codeUnits),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ]),
                    )
                  ],
                )
              : new Container(),
                new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: <Widget>[
           new Expanded(child: Text(('positionLatitude').tr)),
           new Expanded(child: Text(args!.positionModel!.latitude!.toStringAsFixed(5)))
         ]),
         new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: <Widget>[
           new Expanded(child: Text(('positionLongitude').tr)),
           new Expanded(child: Text(args!.positionModel!.longitude!.toStringAsFixed(5)))
         ]),
          new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: <Widget>[
           new Expanded(child: Text(('positionSpeed').tr)),
           new Expanded(child: Text(convertSpeed(args!.positionModel!.speed!)))
         ]),
          new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: <Widget>[
           new Expanded(child: Text(('positionCourse').tr)),
           new Expanded(child: Text(convertCourse(args!.positionModel!.course!)))
         ]),
          SizedBox(height: 5.0),
        ]),)
      );
    } else {
      return Container(
        child: Text(('noData').tr),
      );
    }
  }

  Widget sensorInfo() {
    if (args!.positionModel != null) {
      Map<String, dynamic> attributes = args!.positionModel!.attributes!;
      List<Widget> keyList = [];

      for (var entry in attributes.entries) {
       if (entry.key == "totalDistance" || entry.key == "distance") {
         /* keyList.add(new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Expanded(
                  child: Text((entry.key).tr)),
              new Expanded(child: Text(convertDistance(entry.value)))
            ],
          ));*/
        } else if (entry.key == "hours") {
          keyList.add(new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Expanded(
                  child: Text((entry.key).tr)),
              new Expanded(child: Text(convertDuration(entry.value)))
            ],
          ));
        } else if (entry.key == "ignition") {
          keyList.add(new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Expanded(
                  child: Text((entry.key).tr)),
              new Expanded(
                  child: Text((entry.value.toString().tr) == "true" ? "on" : "off"))
            ],
          ));
        } else if (entry.key == "motion") {
          keyList.add(new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Expanded(
                  child: Text((entry.key).tr)),
              new Expanded(
                  child: Text((entry.value.toString().tr) == "true" ? "moving" : "not moving"))
            ],
          ));
        } else {
          keyList.add(new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Expanded(
                  child: Text((entry.key).tr)),
              new Expanded(child: Text(entry.value.toString()))
            ],
          ));
        }
      }
      return new Card(
          elevation: 5.0,
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(children: keyList)));
    } else {
      return new Container();
    }
  }

  Widget mainInfo(){
    if(args!.positionModel != null){
       Map<String, dynamic> attributes = args!.device.attributes!;
       Map<String, dynamic> attributes2 = args!.positionModel!.attributes!;
       List<Widget> keyList = [];

      if(args!.device.phone != null){
        keyList.add(new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [new Expanded(child: Text('Vehicle Make')), 
            new Expanded(child: Text(args!.device.phone!))]));
      }
      if(args!.device.model != null){
        keyList.add(new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
          new Expanded(child: Text('Vehicle Model')), 
            new Expanded(child: Text(args!.device.model!))
        ]));
      }
     
      for(var entry in attributes.entries){
        if(entry.key == "VIN"){
              keyList.add(new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [new Expanded(child: Text('VIN')), 
                  new Expanded(child: Text(entry.value.toString()))]));
        }else if(entry.key == "Engine_Number"){
              keyList.add(new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [new Expanded(child: Text('Engine Number')), 
                  new Expanded(child: Text(entry.value.toString()))]));
        }else if(entry.key == "Registration_Number"){
              keyList.add(new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [new Expanded(child: Text('Registration Number')), 
                  new Expanded(child: Text(entry.value.toString()))]));
        }else if(entry.key == "Number_Plate"){
              keyList.add(new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [new Expanded(child: Text('Number Plate')), 
                  new Expanded(child: Text(entry.value.toString()))]));
        }else if(entry.key == "Color"){
               keyList.add(new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [new Expanded(child: Text('Color')), 
                  new Expanded(child: Text(entry.value.toString()))]));
        }else if(entry.key == "Driver"){
               keyList.add(new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [new Expanded(child: Text('Driver Name')), 
                  new Expanded(child: Text(entry.value.toString()))]));
        }else {
               keyList.add(new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [new Expanded(child: Text(entry.key.tr)), 
                  new Expanded(child: Text(entry.value.toString()))]));
        }
      }

       for(var entry in attributes2.entries){
       if (entry.key == "totalDistance") {
          keyList.add(new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Expanded(
                  child: Text('Odometer')),
              new Expanded(child: Text(convertDistance(entry.value)))
            ],
          ));
        }
      }

      return new Card(
          elevation: 5.0,
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(children: keyList)));
    }
    else{
      return new Container();
    }
  }
}
