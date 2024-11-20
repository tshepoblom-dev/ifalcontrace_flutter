import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:gpspro/arguments/DeviceArguments.dart';
import 'package:gpspro/arguments/ReportArgumnets.dart';
import 'package:gpspro/src/model/CommandModel.dart';
import 'package:gpspro/src/model/MaintenanceModel.dart';
import 'package:gpspro/model/bottomMenu.dart';
import 'package:gpspro/screens/CommonMethod.dart';
import 'package:gpspro/src/model/MaintenancePermModel.dart';
import 'package:gpspro/storage/dataController/DataController.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:jiffy/jiffy.dart';

import '../../traccar_gennissi.dart';

class DevicePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  TextEditingController textEditingController = new TextEditingController();
  List<Device> _searchResult = [];
  late Locale myLocale;

  final TextEditingController _customCommand = new TextEditingController();
  List<String> _commands = <String>[];
  int _selectedCommand = 0;
  int _selectedperiod = 0;
  double _dialogHeight = 300.0;
  double _dialogCommandHeight = 150.0;

  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();
  TimeOfDay _selectedFromTime = TimeOfDay.now();
  TimeOfDay _selectedToTime = TimeOfDay.now();
  List<CommandModel> savedCommand = [];
  CommandModel _selectedSavedCommand = new CommandModel();

  List<BottomMenu> bottomMenu = [];
  User? user;
  String selectedIndex = "all";

  List<MaintenanceModel> selectedMaintenance = [];
  List<MaintenanceModel> maintenanceList = [];

  final Map<String, Widget> segmentMap = new LinkedHashMap();


 List<Device> devicesList = [];
 Map<int, PositionModel> positions = {};

  @override
  void initState() {
    super.initState();
    fillBottomList();
  }

  void fillBottomList() {
    bottomMenu.add(new BottomMenu(
        title: "liveTracking",
        img: "icons/tracking.png",
        tapPath: "/trackDevice"));
    bottomMenu.add(new BottomMenu(
        title: "info", img: "icons/car.png", tapPath: "/deviceInfo"));
    bottomMenu.add(new BottomMenu(
        title: "playback", img: "icons/route.png", tapPath: "playback"));
    bottomMenu.add(new BottomMenu(
        title: "alarmGeofence",
        img: "icons/fence.png",
        tapPath: "/geofenceList"));
    bottomMenu.add(new BottomMenu(
        title: "report", img: "icons/report.png", tapPath: "report"));
  //  bottomMenu.add(new BottomMenu(
    //    title: "commandTitle", img: "icons/command.png", tapPath: "command"));
    bottomMenu.add(new BottomMenu(
        title: "alarmLock", img: "icons/lock.png", tapPath: "lock"));
    //bottomMenu.add(new BottomMenu(
      //  title: "savedCommand", img: "icons/command.png", tapPath: "savedCommand"));
    //bottomMenu.add(new BottomMenu(title: "info", img: "icons/tracking.png", tapPath: ""));
    //bottomMenu.add(new BottomMenu(title: "assignMaintenance", img: "icons/settings.png", tapPath: "assignMaintenance"));
  }

  void setLocale(locale) async {
    await Jiffy.setLocale(locale);
  }

  void maintenanceData(Device device, StateSetter setState){
    try {
      Traccar.getMaintenanceByDeviceId(device.id.toString()).then((value) => {
        selectedMaintenance.addAll(value!),
        Traccar.getMaintenance().then((val) => {
          val!.forEach((element) {
            if(selectedMaintenance.isNotEmpty) {
              if (selectedMaintenance
                  .singleWhere((e) => element.id == e.id)
                  .id == element.id) {
                print("true");
                element.enabled = true;
              } else {
                element.enabled = false;
              }
            }else{
              element.enabled = false;
            }
            maintenanceList.add(element);
          }),
          setState(() {

          })
        })
      });
    } catch (e) {
      print(e);
    }
  }

  void updateMaintenance(MaintenanceModel m, Device d){
    MaintenancePermModel mPM = MaintenancePermModel();
    mPM.deviceId = d.id;
    mPM.maintenanceId = m.id;

    var maintenancePerm = json.encode(mPM);
    Traccar.addPermission(maintenancePerm).then((value) => {

    });
  }

  void removeMaintenance(MaintenanceModel m, Device d){
    Traccar.deleteMaintenancePermission(d.id, m.id).then((value) => {

    });
  }

  @override
  Widget build(BuildContext context) {

    segmentMap.putIfAbsent(
        "all",
            () => Text(("all").tr,
          style: TextStyle(fontSize: 11),
        ));
    segmentMap.putIfAbsent(
        "online",
            () => Text(("online").tr,
          style: TextStyle(fontSize: 11),
        ));
    segmentMap.putIfAbsent(
        "unknown",
            () => Text(("unknown").tr,
          style: TextStyle(fontSize: 11),
        ));
    segmentMap.putIfAbsent(
        "offline",
            () => Text(("offline").tr,
          style: TextStyle(fontSize: 11),
        ));

    onSearchTextChanged(String text) async {
      _searchResult.clear();

      if (text.toLowerCase().isEmpty) {
        setState(() {});
        return;
      }

      devicesList.forEach((device) {
        if (device.name!.toLowerCase().contains(text.toLowerCase())) {
          _searchResult.add(device);
        }
      });
      setState(() {});
    }

    deviceListFilter(String filterVal) async {
      _searchResult.clear();

      if (filterVal == "all") {
        setState(() {});
        return;
      }

      devicesList.forEach((device) {
        if (device.status!.contains(filterVal)) {
          if (device.status == filterVal) {
            _searchResult.add(device);
          }
        }
      });

      setState(() {});
    }

    return Scaffold(
        body: new Column(children: <Widget>[
          new Container(
            child: new Padding(
              padding: const EdgeInsets.all(1.0),
              child: new Card(
                child: new ListTile(
                  leading: new Icon(Icons.search),
                  title: new TextField(
                    controller: textEditingController,
                    decoration: new InputDecoration(
                        hintText: ('search').tr,
                        border: InputBorder.none),
                    onChanged: onSearchTextChanged,
                  ),
                  trailing: user != null
                      ? user!.deviceReadonly!
                      ? new IconButton(
                    icon: new Icon(Icons.cancel),
                    onPressed: () {
                      textEditingController.clear();
                      onSearchTextChanged('');
                    },
                  )
                      :FloatingActionButton(
                    heroTag: "addButton",
                    onPressed: () {
                      Navigator.pushNamed(context, "/addDevice");
                    },
                    mini: true,
                    child: const Icon(Icons.add),
                    backgroundColor: CustomColor.primaryColor,
                  )
                      : new IconButton(
                    icon: new Icon(Icons.cancel),
                    onPressed: () {
                      textEditingController.clear();
                      onSearchTextChanged('');
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.all(3)),
          SizedBox(
            width: 500.0,
            child: CupertinoSegmentedControl<String>(
              children: segmentMap,
              selectedColor: CustomColor.primaryColor,
              unselectedColor: CustomColor.secondaryColor,
              groupValue: selectedIndex,
              onValueChanged: (String val) {
                setState(() {
                  selectedIndex = val;
                  deviceListFilter(val);
                });
              },
            ),
          ),
          Padding(padding: EdgeInsets.all(3)),
          GetX<DataController>(
              init: DataController(),
              builder: (controller) {
                devicesList = controller.devices.values.toList();
                positions = controller.positions;
                return !controller.isLoading.value ? Expanded(
                    child: _searchResult.length != 0 || textEditingController.text.isNotEmpty
                        ? new ListView.builder(
                      itemCount: _searchResult.length,
                      itemBuilder: (context, index) {
                        final device = _searchResult[index];
                        return deviceCard(device, context);
                      },
                    )
                        : selectedIndex == "all"
                        ? new ListView.builder(
                        itemCount: devicesList.length,
                        itemBuilder: (context, index) {
                          final device = devicesList[index];
                          return deviceCard(device, context);
                        })
                        : new ListView.builder(
                        itemCount: 0,
                        itemBuilder: (context, index) {
                          return Text(("noDeviceFound").tr);
                        })) : CircularProgressIndicator();
              })
        ]));
  }



  Widget deviceCard(Device device, BuildContext context) {
    Color color;

    if (device.status == "online") {
      color = Colors.green;
    } else if (device.status == "unknown") {
      color = Colors.yellow;
    } else {
      color = Colors.red;
    }

    String fLastUpdate = ('noData').tr;
    if (device.lastUpdate != null) {
      fLastUpdate = formatTime(device.lastUpdate!);
    }

    double subtext = 13;
    double title = 14;

    bool _fuelCutStatus = positions.containsKey(device.id)
                         ? positions[device.id]!.attributes!.containsKey('fuelCutStatus')
                         ? positions[device.id]!.attributes!["fuelCutStatus"]
                         : false : false;
    return new Card(
      elevation: 1.0,
      shadowColor: color.withOpacity(0.5),
      color: color.withOpacity(0.1),
      child: Padding(
          padding: new EdgeInsets.all(10.0),
          child: Column(children: <Widget>[
            InkWell(
              onTap: () {
                FocusScope.of(context).unfocus();
                onSheetShowContents(context, device);
              },
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Row(children: <Widget>[
                            Icon(Icons.radio_button_checked,
                                color: color, size: 18.0),
                            Padding(
                                padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.60,
                                child: Text(
                                  utf8.decode(device.name!.codeUnits),
                                  style: TextStyle(
                                      fontSize: title,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ))
                          ]),
                          new Row(children: <Widget>[
                           positions.containsKey(device.id)
                                ? positions[device.id]!.attributes!.containsKey("ignition")
                                ? positions[device.id]!.attributes!["ignition"]
                                ? Icon(Icons.vpn_key, color: CustomColor.onColor,
                                size: 18.0)
                                : Icon(Icons.vpn_key, color: CustomColor.offColor, size: 18.0)
                                : Icon(Icons.vpn_key, color: CustomColor.offColor, size: 18.0)
                                : new Container(), 
                          positions.containsKey(device.id) ? positions[device.id]!.attributes!.containsKey("charge")
                                ? positions[device.id]!.attributes!["charge"]
                                ? Icon(Icons.battery_charging_full,  color: CustomColor.onColor, size: 18.0)
                                : Icon(Icons.battery_std, color: CustomColor.offColor, size: 18.0)
                                : Icon(Icons.battery_std, color: CustomColor.offColor, size: 18.0)
                                : new Container(),
                            positions.containsKey(device.id) 
                                ? positions[device.id]!.attributes!.containsKey("batteryLevel")
                                ? Container(
                                width:  20,
                                child: Text(
                                  positions[device.id]!.attributes!["batteryLevel"].toString() + "%",
                                  style: TextStyle(color: CustomColor.primaryColor, fontSize: 10), overflow: TextOverflow.ellipsis,))
                                : Text("")
                                : new Container()
                          ]),
                        ]),
                    new Row(children: <Widget>[
                      Icon(Icons.speed, color: color, size: 18.0),
                      Padding(padding: new EdgeInsets.fromLTRB(5, 5, 0, 0)),
                      positions.containsKey(device.id) ? Text(device.status![0].toUpperCase() + device.status!.substring(1) + " " + convertSpeed(positions[device.id]!.speed!),
                        style: TextStyle(fontSize: subtext),overflow: TextOverflow.ellipsis,
                      )
                          : Text(device.status![0].toUpperCase() +device.status!.substring(1), style: TextStyle(fontSize: subtext), overflow: TextOverflow.ellipsis),
                    ]),
                    positions.containsKey(device.id)
                        ? positions[device.id]!.address != null
                        ? new Row(children: <Widget>[
                      Icon(Icons.location_on_outlined,
                          color: color, size: 18.0),
                      Expanded(
                          child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    utf8.decode(positions[device.id]!
                                        .address!.codeUnits),
                                    style: TextStyle(fontSize: subtext),
                                    textAlign: TextAlign.left,
                                    maxLines: 2,
                                  ),
                                )
                              ]))
                    ])
                        : new Container()
                        : new Container(),
                    positions.containsKey(device.id)
                        ? positions[device.id]!.attributes!.containsKey('idleDuration')
                        ? 
                    new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: [
                              Icon(Icons.car_crash, color: color, size: 18.0),
                              Padding(
                                  padding: new EdgeInsets.fromLTRB(5, 5, 0, 0)),
                                Text(positions[device.id]!.attributes!['idleDuration'],
                                style: TextStyle(fontSize: subtext),
                                overflow: TextOverflow.ellipsis,)                              
                            ],
                          )
                        ]) : new Container()
                          : new Container(),
                    new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: [
                              Icon(Icons.timer_rounded, color: color, size: 18.0),
                              Padding(padding: new EdgeInsets.fromLTRB(5, 5, 0, 0)),
                              Text(fLastUpdate, style: TextStyle(fontSize: subtext), overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Text(
                            device.lastUpdate != null ? Jiffy.parse(fLastUpdate, pattern: 'dd-MM-yyyy hh:mm:ss aa').fromNow() : "-",
                            style: TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          )
                        ]),
                  /* new Row(mainAxisAlignment: MainAxisAlignment.end,  
                        children: [
                            Icon(Icons.vpn_key, color: positions.containsKey(device.id)
                                                      ? positions[device.id]!.attributes!.containsKey('fuelCutStatus')
                                                      ? positions[device.id]!.attributes!["fuelCutStatus"] 
                                                      ? CustomColor.onColor : CustomColor.offColor : CustomColor.offColor : CustomColor.offColor,
                                                       size: 18.0),
                                 Switch(value:  positions.containsKey(device.id)
                                                ? positions[device.id]!.attributes!.containsKey('fuelCutStatus')
                                                ? positions[device.id]!.attributes!["fuelCutStatus"] : _fuelCutStatus : false,
                                          onChanged: (bool newValue) {
                                            // Handle the toggle action here
                                            setState((){
                                                _fuelCutStatus = newValue;
                                            });
                                            if(newValue == true)
                                            {
                                              sendLockCommand_('engineResume', device);                                              
                                            }else
                                            {
                                              sendLockCommand_('engineStop', device);
                                            }
                                          },
                               ) 
                            ],)*/
                  ],
                ),
              ),
            ),
          ])),
    );
  }

  void onSheetShowContents(BuildContext context, Device device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.40,
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(15.0),
            topRight: const Radius.circular(15.0),
          ),
        ),
        child: bottomSheetContent(device),
      ),
    );
  }

  Widget bottomSheetContent(Device device) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.all(5)),
          Center(
            child: Container(
              width: 100,
              padding: EdgeInsets.fromLTRB(0, 7, 0, 0),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                device.name!,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              )),
          positions[device.id] != null ? Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: CustomColor.primaryColor,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Text(
                        '${positions[device.id]!.address}',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ))
                ],
              )) : Container(),
          Divider(),
          Padding(padding: EdgeInsets.all(3)),
          // ConstrainedBox(
          //   constraints: BoxConstraints.tightFor(width: 250, height: 40),
          //   child: ElevatedButton.icon(
          //     icon: Icon(
          //       Icons.my_location_sharp,
          //       size: 15,
          //     ),
          //     onPressed: () {
          //       FocusScope.of(context).unfocus();
          //       Navigator.pushNamed(context, "/trackDevice",
          //           arguments:
          //               DeviceArguments(device.id!, device.name!, device));
          //     },
          //     label:
          //         Text(AppLocalizations.of(context)!.translate('trackDevice')),
          //   ),
          // ),
          Flexible(child: bottomButton(device))
        ],
      ),
    );
  }

  Widget bottomButton(Device device) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      padding: const EdgeInsets.all(1.0),
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
      children: List.generate(6, (index) {
        final menu = bottomMenu[index];
        return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              if (menu.tapPath == "/trackDevice") {
                Navigator.pushNamed(context, menu.tapPath,
                    arguments:
                    DeviceArguments(device.id!, device.name!, device, positions[device.id]));
              } else if (menu.tapPath == "/deviceInfo") {
                Navigator.pushNamed(context, menu.tapPath,
                    arguments:
                    DeviceArguments(device.id!, device.name!, device, positions[device.id]));
              } else if (menu.tapPath == "playback") {
                showReportDialog(
                    context, ('playback').tr,
                    device);
              } else if (menu.tapPath == "/geofenceList") {
                Navigator.pushNamed(context, menu.tapPath,
                    arguments: ReportArguments(
                        device.id!, "", "", device.name!, device));
              } else if (menu.tapPath == "report") {
                showReportDialog(context, "report", device);
              } else if (menu.tapPath == "command") {
                showCommandDialog(context, device);
              } else if (menu.tapPath == "lock") {
                _showEngineOnOFF(device);
              }else if (menu.tapPath == "savedCommand") {
                showSavedCommandDialog(context, device);
              }
              else if (menu.tapPath == "assignMaintenance") {
                if(maintenanceList.isNotEmpty) {
                  showMaintenanceDialog(context, device);
                }else{
                  Fluttertoast.showToast(
                      msg: ("noData").tr,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              }
            },
            child: Column(
              children: [
                Image.asset(
                  menu.img,
                  width: 30,
                ),
                Padding(padding: EdgeInsets.all(7)),
                Text((menu.title).tr,
                  style: TextStyle(fontSize: 10),
                )
              ],
            ));
      }),
    );
  }


  void showMaintenanceDialog(BuildContext context, Device device){
    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              if(maintenanceList.isEmpty) {
                setState(() {
                  maintenanceData(device, setState);
                });
              }
              return new ListView.builder(
                itemCount: maintenanceList.length,
                itemBuilder: (context, index) {
                  final m = maintenanceList[index];
                  return maintenanceCard(m, context, setState, device);
                },
              );
            }));
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  Widget maintenanceCard(MaintenanceModel m, BuildContext context, StateSetter setState, Device device){
    return ListTile(
      leading: Checkbox(
        value: m.enabled,
        onChanged: (val){
          setState(() {
            m.enabled = val;
          });
          if(val!) {
            updateMaintenance(m, device);
          }else{
            removeMaintenance(m, device);
          }
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(m.name!,
              style: TextStyle(
                  fontSize: 13.0, fontWeight: FontWeight.bold)),
          Divider()
        ],
      ),
    );
  }

  void showSavedCommandDialog(BuildContext context, device) {
    savedCommand.clear();
    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              Iterable list;
              try {
                Traccar.getSavedCommands(device.id.toString()).then((value) => {
                  if (value != null)
                    {
                      if (savedCommand.length == 0)
                        {
                          value.forEach((element) {
                            savedCommand.add(element);
                          }),
                          _selectedSavedCommand.description = savedCommand.first.description,
                        },
                    }
                  else
                    {},
                  setState(() {})
                });
              } catch (e) {
                print(e);
              }
              return Container(
                height: _dialogCommandHeight,
                width: 300.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    savedCommand.length > 0 ?
                    Column(
                      children: <Widget>[
                        Padding(
                          padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(('commandTitle').tr),
                                ],
                              ),
                              new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new DropdownButton<CommandModel>(
                                      hint: new Text(_selectedSavedCommand.description != null ? _selectedSavedCommand.description! : ""),
                                      items: savedCommand.map((CommandModel value) {
                                        return new DropdownMenuItem<CommandModel>(
                                          value: value,
                                          child: new Text(
                                            value.description!,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedSavedCommand = value!;
                                        });
                                      },
                                    )
                                  ]),
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
                                      sendSavedCommand(device);
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
                    ) : savedCommand.length < 0 ? Center(child: Text(("noData").tr)) :Center(child: Text(("noData").tr, style: TextStyle(color: CustomColor.primaryColor)))
                  ],
                ),
              );
            }));
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  void sendSavedCommand(Device device) {
    Command command = Command();
    command.deviceId = device.id.toString();
    command.type = "custom";
    command.attributes = _selectedSavedCommand.attributes;

    String request = json.encode(command.toJson());

    Traccar.sendCommands(request).then((res) => {
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

  void showReportDialog(BuildContext context, String heading, Device device) {
    Dialog simpleDialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return new Container(
            height: _dialogHeight,
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Radio(
                                value: 0,
                                groupValue: _selectedperiod,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedperiod =
                                        int.parse(value.toString());
                                    _dialogHeight = 300.0;
                                  });
                                },
                              ),
                              new Text(('reportToday').tr,
                                style: new TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Radio(
                                value: 1,
                                groupValue: _selectedperiod,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedperiod =
                                        int.parse(value.toString());
                                    _dialogHeight = 300.0;
                                  });
                                },
                              ),
                              new Text(('reportYesterday').tr,
                                style: new TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Radio(
                                value: 2,
                                groupValue: _selectedperiod,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedperiod =
                                        int.parse(value.toString());
                                    _dialogHeight = 300.0;
                                  });
                                },
                              ),
                              new Text(('reportThisWeek').tr,
                                style: new TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Radio(
                                value: 3,
                                groupValue: _selectedperiod,
                                onChanged: (value) {
                                  setState(() {
                                    _dialogHeight = 400.0;
                                    _selectedperiod =
                                        int.parse(value.toString());
                                  });
                                },
                              ),
                              new Text(('reportCustom').tr,
                                style: new TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                          _selectedperiod == 3
                              ? new Container(
                              child: new Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      ElevatedButton(
                                        onPressed: () => _selectFromDate(
                                            context, setState),
                                        child: Text(
                                            formatReportDate(
                                                _selectedFromDate),
                                            style: TextStyle(
                                                color: Colors.white)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => _selectFromTime(
                                            context, setState),
                                        child: Text(
                                            formatReportTime(
                                                _selectedFromTime),
                                            style: TextStyle(
                                                color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      ElevatedButton(
                                        onPressed: () =>
                                            _selectToDate(context, setState),
                                        child: Text(
                                            formatReportDate(_selectedToDate),
                                            style: TextStyle(
                                                color: Colors.white)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            _selectToTime(context, setState),
                                        child: Text(
                                            formatReportTime(_selectedToTime),
                                            style: TextStyle(
                                                color: Colors.white)),
                                      ),
                                    ],
                                  )
                                ],
                              ))
                              : new Container(),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  showReport(heading, device);
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
                ),
              ],
            ),
          );
        },
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  Future<void> _selectFromDate(
      BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedFromDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedFromDate)
      setState(() {
        _selectedFromDate = picked;
      });
  }

  Future<void> _selectToDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedToDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedToDate)
      setState(() {
        _selectedToDate = picked;
      });
  }

  Future<void> _selectFromTime(
      BuildContext context, StateSetter setState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: m.TextDirection.rtl,
          child: child != null ? child : new Container(),
        );
      },
    );
    if (picked != null && picked != _selectedFromTime)
      setState(() {
        _selectedFromTime = picked;
      });
  }

  Future<void> _selectToTime(BuildContext context, setState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: m.TextDirection.rtl,
          child: child != null ? child : new Container(),
        );
      },
    );
    if (picked != null && picked != _selectedToTime)
      setState(() {
        _selectedToTime = picked;
      });
  }

  void showCommandDialog(BuildContext context, Device device) {
    _commands.clear();

    // if (_commands[_selectedCommand] == "custom") {
    //   _dialogCommandHeight = 220.0;
    // }

    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              Iterable list;
              try {
                Traccar.getSendCommands(device.id.toString()).then((value) => {
                  // ignore: unnecessary_null_comparison
                  if (value.body != null)
                    {
                      list = json.decode(value.body),
                      if (_commands.length == 0)
                        {
                          list.forEach((element) {
                            if (list.length == 1) {
                              _dialogCommandHeight = 200;
                            }
                            _commands.add(element["type"]);
                          })
                        }
                    }
                  else
                    {},
                  setState(() {})
                });
              } catch (e) {
                print(e);
              }
              return Container(
                height: _dialogCommandHeight,
                width: 300.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _commands.length > 0
                        ? Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              new Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(('commandTitle').tr),
                                ],
                              ),
                              new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new DropdownButton<String>(
                                      hint: new Text(('select_command').tr),
                                      // ignore: unnecessary_null_comparison
                                      value: _selectedCommand == null
                                          ? null
                                          : _commands[_selectedCommand],
                                      items: _commands.map((String value) {
                                        return new DropdownMenuItem<String>(
                                          value: value,
                                          child: new Text((value).tr,
                                            style: TextStyle(),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == "custom") {
                                            _dialogCommandHeight = 250.0;
                                          } else {
                                            _dialogCommandHeight = 150.0;
                                          }
                                          _selectedCommand =
                                              _commands.indexOf(value!);
                                        });
                                      },
                                    )
                                  ]),
                              _commands[_selectedCommand] == "custom"
                                  ? new Container(
                                child: new TextField(
                                  controller: _customCommand,
                                  decoration: new InputDecoration(
                                      labelText: ('commandCustom').tr),
                                ),
                              )
                                  : new Container(),
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
                                          fontSize: 18.0,
                                          color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      sendCommand(device);
                                    },
                                    child: Text(('ok').tr,
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                        : new CircularProgressIndicator(),
                  ],
                ),
              );
            }));
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  void sendCommand(Device device) {
    Map<String, dynamic> attributes = new HashMap();
    if (_commands[_selectedCommand] == "custom") {
      attributes.putIfAbsent("data", () => _customCommand.text);
    } else {
      attributes.putIfAbsent("data", () => _commands[_selectedCommand]);
    }

    Command command = Command();
    command.deviceId = device.id.toString();
    command.type = _commands[_selectedCommand];
    command.attributes = attributes;

    String request = json.encode(command.toJson());

    Traccar.sendCommands(request).then((res) => {
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

  void showReport(String heading, Device device) {
    String from;
    String to;

    DateTime current = DateTime.now();

    String month;
    String day;
    if (current.month < 10) {
      month = "0" + current.month.toString();
    } else {
      month = current.month.toString();
    }

    if (current.day < 10) {
      day = "0" + current.day.toString();
    } else {
      day = current.day.toString();
    }

    if (_selectedperiod == 0) {
      var date = DateTime.parse("${current.year}-"
          "$month-"
          "$day "
          "00:00:00");
      from = date.toUtc().toIso8601String();
      to = DateTime.now().toUtc().toIso8601String();
    } else if (_selectedperiod == 1) {
      String yesterday;

      int dayCon = current.day - 1;
      if (current.day <= 10) {
        yesterday = "0" + dayCon.toString();
      } else {
        yesterday = dayCon.toString();
      }

      var start = DateTime.parse("${current.year}-"
          "$month-"
          "$yesterday "
          "00:00:00");

      var end = DateTime.parse("${current.year}-"
          "$month-"
          "$yesterday "
          "24:00:00");

      from = start.toUtc().toIso8601String();
      to = end.toUtc().toIso8601String();
    } else if (_selectedperiod == 2) {
      String sevenDay, currentDayString;
      DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);
      int dayCon = getDate(current.subtract(Duration(days: current.weekday - 1))).day;
      int currentDay = current.day;
      if (dayCon < 10) {
        sevenDay = "0" + dayCon.toString();
      } else {
        sevenDay = dayCon.toString();
      }
      if (currentDay < 10) {
        currentDayString = "0" + currentDay.toString();
      } else {
        currentDayString = currentDay.toString();
      }

      var start = DateTime.parse("${current.year}-"
          "$month-"
          "$sevenDay "
          "24:00:00");

      var end = DateTime.parse("${current.year}-"
          "$month-"
          "$currentDayString "
          "24:00:00");

      print("start"+start.toString());
      print("end"+end.toString());

      from = start.toUtc().toIso8601String();
      to = end.toUtc().toIso8601String();
    } else {
      String startMonth, endMoth;
      if (_selectedFromDate.month < 10) {
        startMonth = "0" + _selectedFromDate.month.toString();
      } else {
        startMonth = _selectedFromDate.month.toString();
      }

      if (_selectedToDate.month < 10) {
        endMoth = "0" + _selectedToDate.month.toString();
      } else {
        endMoth = _selectedToDate.month.toString();
      }

      String startHour, endHour;
      if (_selectedFromTime.hour < 10) {
        startHour = "0" + _selectedFromTime.hour.toString();
      } else {
        startHour = _selectedFromTime.hour.toString();
      }

      String startMin, endMin;
      if (_selectedFromTime.minute < 10) {
        startMin = "0" + _selectedFromTime.minute.toString();
      } else {
        startMin = _selectedFromTime.minute.toString();
      }

      if (_selectedFromTime.minute < 10) {
        endMin = "0" + _selectedToTime.minute.toString();
      } else {
        endMin = _selectedToTime.minute.toString();
      }

      if (_selectedToTime.hour < 10) {
        endHour = "0" + _selectedToTime.hour.toString();
      } else {
        endHour = _selectedToTime.hour.toString();
      }

      String startDay, endDay;
      if (_selectedFromDate.day < 10) {
        if (_selectedFromDate.day == 10) {
          startDay = _selectedFromDate.day.toString();
        } else {
          startDay = "0" + _selectedFromDate.day.toString();
        }
      } else {
        startDay = _selectedFromDate.day.toString();
      }

      if (_selectedToDate.day < 10) {
        if (_selectedToDate.day == 10) {
          endDay = _selectedToDate.day.toString();
        } else {
          endDay = "0" + _selectedToDate.day.toString();
        }
      } else {
        endDay = _selectedToDate.day.toString();
      }

      var start = DateTime.parse("${_selectedFromDate.year}-"
          "$startMonth-"
          "$startDay "
          "$startHour:"
          "$startMin:"
          "00");

      var end = DateTime.parse("${_selectedToDate.year}-"
          "$endMoth-"
          "$endDay "
          "$endHour:"
          "$endMin:"
          "00");

      from = start.toUtc().toIso8601String();
      to = end.toUtc().toIso8601String();
    }

    Navigator.pop(context);
    if (heading == "report") {
      Navigator.pushNamed(context, "/reportList",
          arguments:
          ReportArguments(device.id!, from, to, device.name!, device));
    } else {
      Navigator.pushNamed(context, "/playback",
          arguments:
          ReportArguments(device.id!, from, to, device.name!, device));
    }
  }

  Future<void> _showEngineOnOFF(Device device) async {
    Widget cancelButton = TextButton(
      child: Text(('cancel').tr),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget onButton = TextButton(
      child: Text('Reactivate'),
      onPressed: () {
        sendLockCommand('engineResume', device);
      },
    );
    Widget offButton = TextButton(
      child: Text('Cut Off'),
      onPressed: () {
        sendLockCommand('engineStop', device);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(('fuelCutOff').tr),
      //content: Text(('areYouSure').tr),
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

  void sendLockCommand(String commandTxt, Device device) {
    Command command = Command();
    command.deviceId = device.id.toString();
    command.type = commandTxt;

    String request = json.encode(command.toJson());

    Traccar.sendCommands(request).then((res) => {
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
  void sendLockCommand_(String commandTxt, Device device) {
    Command command = Command();
    command.deviceId = device.id.toString();
    command.type = commandTxt;

    String request = json.encode(command.toJson());

    Traccar.sendCommands(request).then((res) => {
      if (res.statusCode == 200)
        {
          Fluttertoast.showToast(
              msg: ('command_sent').tr,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0)
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
              fontSize: 16.0)
        }
    });
  }

}
