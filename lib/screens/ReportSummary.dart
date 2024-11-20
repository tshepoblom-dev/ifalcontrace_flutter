import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gpspro/arguments/ReportArgumnets.dart';
import 'package:gpspro/screens/CommonMethod.dart';
import 'package:gpspro/theme/CustomColor.dart';

import '../../traccar_gennissi.dart';

class ReportSummaryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ReportSummaryPageState();
}

class _ReportSummaryPageState extends State<ReportSummaryPage> {
  late ReportArguments args;
  List<Summary> _summaryList = [];
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
      // ignore: unnecessary_null_comparison
      if (args != null) {
        _timer.cancel();
        Traccar.getSummary(args.id.toString(), args.from, args.to)
            .then((value) => {
                  _summaryList.addAll(value!),
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
        title: Text(args.name,
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
      itemCount: _summaryList.length,
      itemBuilder: (context, index) {
        final summary = _summaryList[index];
        return reportRow(summary);
      },
    );
  }

  Widget reportRow(Summary s) {
    return Card(
        child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(("positionDistance").tr,
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      convertDistance(s.distance!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(("reportStartOdometer").tr,
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      convertDistance(s.startOdometer!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(("reportEndOdometer").tr,
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      convertDistance(s.endOdometer!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(("reportAverageSpeed").tr,
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      convertSpeed(s.averageSpeed!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(("reportMaximumSpeed").tr,
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      convertSpeed(s.maxSpeed!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(('reportEngineHours').tr,
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      convertDuration(s.engineHours!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(('reportSpentFuel'),
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      s.spentFuel.toString(),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
              ],
            )));
  }
}
