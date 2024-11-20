import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gpspro/arguments/ReportArgumnets.dart';
import 'package:gpspro/screens/CommonMethod.dart';
import 'package:gpspro/theme/CustomColor.dart';

import '../../traccar_gennissi.dart';

class ReportTripPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ReportTripPageState();
}

class _ReportTripPageState extends State<ReportTripPage> {
  ReportArguments? args;
  List<Trip> _tripList = [];
  late StreamController<int> _postsController;
  late Timer _timer;
  bool isLoading = true;

  @override
  void initState() {
    _postsController = new StreamController();
    getReport();
    super.initState();
  }

  getReport() {
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      if (args != null) {
        _timer.cancel();
        Traccar.getTrip(args!.id.toString(), args!.from, args!.to)
            .then((value) => {
                  _tripList.addAll(value!),
                  _postsController.add(1),
                  isLoading = false,
                  setState(() {})
                });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)?.settings.arguments as ReportArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args!.name,
            style: TextStyle(color: CustomColor.secondaryColor)),
            iconTheme: IconThemeData(
              color: CustomColor.secondaryColor, //change your color here
        ),
      ),
      body: StreamBuilder<int>(
          stream: _postsController.stream,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              return loadReport();
            } else if (isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Center(
                child: Text(('noData').tr),
              );
            }
          }),
    );
  }

  Widget loadReport() {
    return ListView.builder(
      itemCount: _tripList.length,
      itemBuilder: (context, index) {
        final trip = _tripList[index];
        return reportRow(trip);
      },
    );
  }

  Widget reportRow(Trip t) {
    return Card(
        child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                   Expanded(child: Text(
                        ("reportStartTrip").tr,
                        style: TextStyle(color: Colors.green), textAlign: TextAlign.left,)),
                    Expanded(child: Text(("reportEndTrip").tr,
                        style: TextStyle(color: Colors.red), textAlign: TextAlign.left,))
                  ],
                ),
                Divider(),
                 Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                     t.startAddress != null
                    ? Expanded(child: Text(('reportStartAddress').tr +
                                ": " + utf8.decode(t.startAddress!.codeUnits),
                            style: TextStyle(fontSize: 11), textAlign: TextAlign.left,
                          ),
                      )
                    : new Container(),
                  t.endAddress != null
                    ? Expanded(child: Text(('reportEndAddress').tr +
                                ": " + utf8.decode(t.endAddress!.codeUnits),
                            style: TextStyle(fontSize: 11), textAlign: TextAlign.left,
                          ),
                      )
                    : new Container(),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                     Expanded(child: Text('Start time: ' + formatTime(t.startTime!), style: TextStyle(fontSize: 11), textAlign: TextAlign.start,
                    )),
                    Expanded(child: Text('End time: ' + formatTime(t.endTime!), style: TextStyle(fontSize: 11), textAlign: TextAlign.start,
                    )),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                   Expanded(child: Text(("positionOdometer").tr + ": " + convertDistance(t.startOdometer!),
                      style: TextStyle(fontSize: 11),textAlign: TextAlign.start,)),
                   Expanded(child: Text(("positionOdometer").tr + ": " + convertDistance(t.endOdometer!),
                      style: TextStyle(fontSize: 11), textAlign: TextAlign.start,
                   )),
                  ],
                ),               
                Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                     Expanded(child: Text(("positionDistance").tr +
                          ": " + convertDistance(t.distance!),style: TextStyle(fontSize: 11),textAlign: TextAlign.left,
                    )),
                     Expanded(child: Text(("reportAverageSpeed").tr + ": " +  convertSpeed(t.averageSpeed!), style: TextStyle(fontSize: 11),
                    )),        
                 
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [ 
                     Expanded(child: Text(("reportDuration").tr + ": " + convertDuration(t.duration!),
                    style: TextStyle(fontSize: 11), textAlign: TextAlign.left,
                    )), 
                    Expanded(child: Text(("reportMaximumSpeed").tr + ": " + convertSpeed(t.maxSpeed!), style: TextStyle(fontSize: 11),
                    )),
                  
                  ],
                ),                             
              ],
            )));
  }
}
