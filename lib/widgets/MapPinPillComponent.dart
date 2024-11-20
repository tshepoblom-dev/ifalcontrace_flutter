import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:gpspro/arguments/DeviceArguments.dart';
import 'package:gpspro/model/PinInformation.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../traccar_gennissi.dart';

// ignore: must_be_immutable
class MapPinPillComponent extends StatefulWidget {
  double pinPillPosition;
  PinInformation currentlySelectedPin;

  MapPinPillComponent(
      {required this.pinPillPosition, required this.currentlySelectedPin});

  @override
  State<StatefulWidget> createState() => MapPinPillComponentState();
}

class MapPinPillComponentState extends State<MapPinPillComponent> {

  @override
  Widget build(BuildContext context) {
    Color color;

    if (widget.currentlySelectedPin.status == "online") {
      color = Colors.green;
    } else if (widget.currentlySelectedPin.status == "unknown") {
      color = Colors.yellow;
    } else {
      color = Colors.red;
    }

    return AnimatedPositioned(
      bottom: widget.pinPillPosition,
      right: 0,
      left: 0,
      duration: Duration(milliseconds: 200),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          //margin: EdgeInsets.all(10),
          margin: EdgeInsets.fromLTRB(10, 0, 10, 30),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withOpacity(0.5))
              ]),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Container(
              //   width: 50, height: 50,
              //   margin: EdgeInsets.only(left: 5),
              //   child: ClipOval(child: Image.asset(widget.currentlySelectedPin.avatarPath, fit: BoxFit.cover )),
              // ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(children: <Widget>[
                              Icon(Icons.radio_button_checked,
                                  color: color, size: 20.0),
                              Padding(
                                  padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.38,
                                child: Text(
                                  utf8.decode(widget.currentlySelectedPin.name!.codeUnits),
                                  style: TextStyle(
                                      color: widget
                                          .currentlySelectedPin.labelColor,
                                      fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ]),
                            new Row(children: <Widget>[
                              // widget.currentlySelectedPin.blocked != null
                              //     ? Icon(
                              //         widget.currentlySelectedPin.blocked
                              //             ? Icons.lock
                              //             : Icons.lock_open,
                              //         color: widget.currentlySelectedPin.blocked
                              //             ? CustomColor.onColor
                              //             : CustomColor.offColor,
                              //         size: 28.0)
                              //     : new Container(),
                              Padding(
                                  padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                              InkWell(
                                child: Icon(Icons.info,
                                    color: CustomColor.primaryColor,
                                    size: 30.0),
                                onTap: () {
                                  Navigator.pushNamed(context, "/deviceInfo",
                                      arguments: DeviceArguments(
                                          widget.currentlySelectedPin.deviceId!,
                                          widget.currentlySelectedPin.name!,
                                          widget.currentlySelectedPin.device!,
                                          widget.currentlySelectedPin.positionModel
                                      ));
                                },
                              ),
                              Padding(
                                  padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                              InkWell(
                                child: Icon(Icons.directions,
                                    color: CustomColor.primaryColor,
                                    size: 30.0),
                                onTap: () async {
                                  String origin = widget.currentlySelectedPin
                                          .location!.latitude
                                          .toString() +
                                      "," +
                                      widget.currentlySelectedPin.location!
                                          .longitude
                                          .toString(); // lat,long like 123.34,68.56

                                  var url = '';
                                  var urlAppleMaps = '';
                                  if (Platform.isAndroid) {
                                    String query = Uri.encodeComponent(origin);
                                    url =
                                        "https://www.google.com/maps/search/?api=1&query=$query";
                                    await launch(url);
                                  } else {
                                    urlAppleMaps =
                                        'https://maps.apple.com/?q=$origin';
                                    url =
                                        "comgooglemaps://?saddr=&daddr=$origin&directionsmode=driving";
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else if (await canLaunch(
                                          urlAppleMaps)) {
                                        await launch(urlAppleMaps);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                      throw 'Could not launch $url';
                                    }
                                  }
                                },
                              ),
                              Padding(
                                  padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                              InkWell(
                                child: Image.asset("images/engine.png",
                                    width: 30, height: 30),
                                onTap: () {
                                  _showEngineOnOFF();
                                },
                              ),
                              // Icon(Icons.streetview,
                              //     color: CustomColor.primaryColor, size: 30.0),
                            ]),
                          ]),
                      Divider(),
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(children: <Widget>[
                              Icon(Icons.speed, color: color, size: 18.0),
                              Padding(
                                  padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                              Text(
                                ('positionSpeed').tr +
                                    ': ${widget.currentlySelectedPin.speed}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ]),
                            new Row(children: <Widget>[
                              widget.currentlySelectedPin.ignition != null
                                  ? Icon(Icons.vpn_key,
                                      color:
                                          widget.currentlySelectedPin.ignition!
                                              ? CustomColor.onColor
                                              : CustomColor.offColor,
                                      size: 18.0)
                                  : Icon(Icons.vpn_key,
                                      color: CustomColor.offColor),
                              Icon(
                                  widget.currentlySelectedPin.charging != null
                                      ? widget.currentlySelectedPin.charging!
                                          ? Icons.battery_charging_full
                                          : Icons.battery_std
                                      : Icons.battery_std,
                                  color: widget.currentlySelectedPin.charging !=
                                          null
                                      ? widget.currentlySelectedPin.charging!
                                          ? CustomColor.onColor
                                          : CustomColor.offColor
                                      : CustomColor.offColor,
                                  size: 18.0),
                              Text(
                                widget.currentlySelectedPin.batteryLevel!,
                                style: TextStyle(
                                    color:
                                        widget.currentlySelectedPin.labelColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ]),
                          ]),
                  widget.currentlySelectedPin.address != null ?  new Row(children: <Widget>[
                        Icon(Icons.location_on_outlined,
                            color: color, size: 18.0),
                        Padding(padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                        Expanded(
                          child: GestureDetector(
                            child: Text(
                              '${widget.currentlySelectedPin.address}',
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ) ,
                          ),
                        )
                      ]): Container(),
                      widget.currentlySelectedPin.idleDuration != null 
                      ?
                      widget.currentlySelectedPin.idleDuration!.isNotEmpty
                      ? 
                      new Row(children: <Widget>[
                        Icon(Icons.car_crash, color: color, size: 18.0),
                        Padding(padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                        Text(('idleDuration').tr +
                                ': ${widget.currentlySelectedPin.idleDuration}',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ]) : Container() : Container(),
                      new Row(children: <Widget>[
                        Icon(Icons.timer_rounded, color: color, size: 18.0),
                        Padding(padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                        Text(('deviceLastUpdate').tr +
                                ': ${widget.currentlySelectedPin.updatedTime}',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ]),
                   /*   new Row(children: <Widget>[
                        Icon(Icons.stacked_line_chart,
                            color: color, size: 18.0),
                        Padding(padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                        widget.currentlySelectedPin.calcTotalDist != null
                            ? Text(('distanceLength').tr +
                                    ': ${widget.currentlySelectedPin.calcTotalDist}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey))
                            : new Container(),
                      ]),*/
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEngineOnOFF() async {
    Widget cancelButton = TextButton(
      child: Text(('cancel').tr),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget onButton = TextButton(
      child: Text('Reactivate'),
      onPressed: () {
        sendCommand('engineResume');
      },
    );
    Widget offButton = TextButton(
      child: Text('Cut off'),
      onPressed: () {
        sendCommand('engineStop');
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(('fuelCutOff').tr),
    //  content: Text(('areYouSure').tr),
      actions: [
        cancelButton,
        onButton,
        offButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void sendCommand(String commandTxt) {
    Command command = Command();
    command.deviceId = widget.currentlySelectedPin.deviceId.toString();
    command.type = commandTxt;

    String request = json.encode(command.toJson());
    print(request);

    Traccar.sendCommands(request).then((res) => {
          print(res.body),
          if (res.statusCode == 200)
            {
              Fluttertoast.showToast(
                  msg: ('command_sent').tr,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0),
              Navigator.of(context).pop()
            }
          else
            {
              Fluttertoast.showToast(
                  msg: ('errorMsg').tr,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black54,
                  textColor: Colors.white,
                  fontSize: 16.0),
              Navigator.of(context).pop()
            }
        });
  }
}
