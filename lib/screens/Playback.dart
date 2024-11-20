import 'dart:async';
import 'dart:typed_data';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpspro/arguments/ReportArgumnets.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:gpspro/widgets/AlertDialogCustom.dart';
import 'package:gpspro/widgets/CustomProgressIndicatorWidget.dart';

import '../../traccar_gennissi.dart';
import 'CommonMethod.dart';

class PlaybackPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PlaybackPageState();
}

class _PlaybackPageState extends State<PlaybackPage> {
  CustomInfoWindowController _customInfoWindowController =
  CustomInfoWindowController();

  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  bool _isPlaying = false;
  var _isPlayingIcon = Icons.pause_circle_outline;
  bool _trafficEnabled = false;
  bool _parkingEnabled = false;
  Color _parkingButtonColor = CustomColor.primaryColor;
  MapType _currentMapType = MapType.normal;
  Color _trafficButtonColor = CustomColor.primaryColor;
  Set<Marker> _markers = Set<Marker>();
  double currentZoom = 14.0;
  late StreamController<PositionModel> _postsController;
  late Timer _timer;
  Timer? timerPlayBack;
  late ReportArguments args;
  List<PositionModel> routeList = [];
  late bool isLoading;
  int _sliderValue = 0;
  int _sliderValueMax = 0;
  int playbackTime = 200;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  List<Choice> choices = [];
  List<Stop> _stopList = [];

  late Choice _selectedChoice; // The app's "state".

  void _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
    });

    if (_selectedChoice.title ==
        ('slow').tr) {
      playbackTime = 400;
      timerPlayBack!.cancel();
      playRoute();
    } else if (_selectedChoice.title ==
        ('medium').tr) {
      playbackTime = 200;
      timerPlayBack!.cancel();
      playRoute();
    } else if (_selectedChoice.title ==
        ('fast').tr) {
      playbackTime = 100;
      timerPlayBack!.cancel();
      playRoute();
    }
  }

  @override
  initState() {
    _postsController = new StreamController();
    getReport();
    super.initState();
  }

  Timer interval(Duration duration, func) {
    Timer function() {
      Timer timer = new Timer(duration, function);

      func(timer);

      return timer;
    }

    return new Timer(duration, function);
  }

  void playRoute() async {
    var iconPath = "images/arrow.png";
    final Uint8List? icon = await getBytesFromAsset(iconPath, 80);
    interval(new Duration(milliseconds: playbackTime), (timer) {
      if (routeList.length != _sliderValue) {
        _sliderValue++;
      }
      timerPlayBack = timer;
      _markers.removeWhere((m) => m.markerId.value == args.id.toString());
      if (routeList.length - 1 == _sliderValue.toInt()) {
        timerPlayBack!.cancel();
      } else if (routeList.length != _sliderValue.toInt()) {
        moveCamera(routeList[_sliderValue.toInt()]);
        _markers.add(
          Marker(
            markerId:
                MarkerId(routeList[_sliderValue.toInt()].deviceId.toString()),
            position: LatLng(routeList[_sliderValue.toInt()].latitude!,
                routeList[_sliderValue.toInt()].longitude!), // updated position
            rotation: routeList[_sliderValue.toInt()].course!,
            icon: BitmapDescriptor.fromBytes(icon!),
          ),
        );
        setState(() {});
      } else {
        timerPlayBack!.cancel();
      }
    });
  }

  void playUsingSlider(int pos) async {
    var iconPath = "images/arrow.png";
    final Uint8List? icon = await getBytesFromAsset(iconPath, 80);
    _markers.removeWhere((m) => m.markerId.value == args.id.toString());
    if (routeList.length != _sliderValue.toInt()) {
      moveCamera(routeList[_sliderValue.toInt()]);
      _markers.add(
        Marker(
          markerId:
              MarkerId(routeList[_sliderValue.toInt()].deviceId.toString()),
          position: LatLng(routeList[_sliderValue.toInt()].latitude!,
              routeList[_sliderValue.toInt()].longitude!), // updated position
          rotation: routeList[_sliderValue.toInt()].course!,
          icon: BitmapDescriptor.fromBytes(icon!),
        ),
      );
      setState(() {});
    }
  }

  void moveCamera(PositionModel pos) async {
    CameraPosition cPosition = CameraPosition(
      target: LatLng(pos.latitude!, pos.longitude!),
      zoom: currentZoom,
    );

    if (isLoading) {
      _showProgress(false);
    }
    isLoading = false;
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(cPosition));
  }

  getReport() {
    _timer = new Timer.periodic(Duration(milliseconds: 1000), (timer) {
      // ignore: unnecessary_null_comparison
      if (args != null) {
        _timer.cancel();
        getStops();
        Traccar.getPositions(args.id.toString(), args.from, args.to)
            .then((value) => {
                  if (value!.length != 0)
                    {
                      routeList.addAll(value),
                      _sliderValueMax = value.length - 1,
                      value.forEach((element) {
                        _postsController.add(element);
                        polylineCoordinates
                            .add(LatLng(element.latitude!, element.longitude!));
                      }),
                      if (value.length != 0) {playRoute(), setState(() {})}
                    }
                  else
                    {
                      if (isLoading)
                        {
                          _showProgress(false),
                          isLoading = false,
                        },
                      AlertDialogCustom().showAlertDialog(
                          context,
                          ('noData').tr,
                          ('failed').tr,
                          ('ok').tr)
                    }
                });
        drawPolyline();
      }
    });
  }

  getStops() {
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      // ignore: unnecessary_null_comparison
      if (args != null) {
        _timer.cancel();
        Traccar.getStops(args.id.toString(), args.from, args.to)
            .then((value) => {
          _stopList.addAll(value!),
          _stopList.forEach((element) {
            addStopMarker(element);
          }),
          setState(() {})
        });
      }
    });
  }


  void addStopMarker(Stop ev) async{
    var iconPath = "images/route-stop.png";
    final Uint8List? icon = await getBytesFromAsset(iconPath, 80);
    _markers.add(
      Marker(
        markerId:
        MarkerId(ev.positionId.toString()),
        position: LatLng(ev.latitude!,ev.longitude!), // up
        icon: BitmapDescriptor.fromBytes(icon!),
          onTap: () {
            _customInfoWindowController.addInfoWindow!(
              Column(
                children: [
                  Expanded(
                    child: Container(
                      width:MediaQuery.of(context).size.width / 1.2,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(ev.address != null ? ev.address! : ev.latitude.toString()+","+ev.longitude.toString(),
                              style: TextStyle(fontSize: 10)
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: TriangleClipper(),
                    child: Container(
                      color: Colors.grey.withOpacity(0.7),
                      width: 20.0,
                      height: 10.0,
                    ),
                  ),
                ],
              ),
              LatLng(ev.latitude!,ev.longitude!),
            );
          }
      ),
    );
    setState(() {});
  }


  void drawPolyline() async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        width: 6,
        polylineId: id,
        color: Colors.greenAccent,
        points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _trafficEnabledPressed() {
    setState(() {
      _trafficEnabled = _trafficEnabled == false ? true : false;
      _trafficButtonColor =
          _trafficEnabled == false ? CustomColor.primaryColor : Colors.green;
    });
  }

  void _parkEnabledPressed() {
    setState(() {
      _parkingEnabled = _parkingEnabled == false ? true : false;
      _parkingButtonColor =
      _parkingEnabled == false ? CustomColor.primaryColor : Colors.green;
    });
  }

  void _playPausePressed() {
    setState(() {
      _isPlaying = _isPlaying == false ? true : false;
      if (_isPlaying) {
        timerPlayBack!.cancel();
      } else {
        playRoute();
      }
      _isPlayingIcon = _isPlaying == false
          ? Icons.pause_circle_outline
          : Icons.play_circle_outline;
    });
  }

  currentMapStatus(CameraPosition position) {
    currentZoom = position.zoom;
  }

  @override
  void dispose() {
    // ignore: unnecessary_null_comparison
    _customInfoWindowController.dispose();
    if (timerPlayBack != null) {
      if (timerPlayBack!.isActive) {
        timerPlayBack!.cancel();
      }
    }
    super.dispose();
  }

  static final CameraPosition _initialRegion = CameraPosition(
    target: LatLng(0, 0),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as ReportArguments;
    choices = <Choice>[
      Choice(
          title: ('slow').tr,
          icon: Icons.directions_car),
      Choice(
          title: ('medium').tr,
          icon: Icons.directions_bike),
      Choice(
          title: ('fast').tr,
          icon: Icons.directions_boat),
    ];
    _selectedChoice = choices[0];
    return Scaffold(
      appBar: AppBar(
        title: Text(args.name,
            style: TextStyle(color: CustomColor.secondaryColor)),
        iconTheme: IconThemeData(
          color: CustomColor.secondaryColor, //change your color here
        ),
      ),
      body: Stack(children: <Widget>[
        GoogleMap(
          mapType: _currentMapType,
          initialCameraPosition: _initialRegion,
          trafficEnabled: _trafficEnabled,
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          onTap: (position) {
            _customInfoWindowController.hideInfoWindow!();
          },
          onCameraMove: (position) {
            currentMapStatus(position);
            _customInfoWindowController.onCameraMove!();
          },
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            _customInfoWindowController.googleMapController = controller;
            mapController = controller;
            CustomProgressIndicatorWidget().showProgressDialog(context,
                ('sharedLoading').tr);
            isLoading = true;
          },
          markers: _markers,
          polylines: Set<Polyline>.of(polylines.values),
        ),
//            TrackMapPinPillComponent(
//                pinPillPosition: pinPillPosition,
//                currentlySelectedPin: currentlySelectedPin
//            ),
        CustomInfoWindow(
          controller: _customInfoWindowController,
          height: 75,
          width: MediaQuery.of(context).size.width / 1.5,
          offset: 50,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Align(
            alignment: Alignment.topRight,
            child: Column(
              children: <Widget>[
                FloatingActionButton(
                  onPressed: _onMapTypeButtonPressed,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: CustomColor.primaryColor,
                  child: const Icon(Icons.map, size: 30.0),
                  mini: true,
                ),
                FloatingActionButton(
                  heroTag: "traffic",
                  onPressed: _trafficEnabledPressed,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: _trafficButtonColor,
                  mini: true,
                  child: const Icon(Icons.traffic, size: 30.0),
                ),
                // FloatingActionButton(
                //   heroTag: "parking",
                //   onPressed: _parkEnabledPressed,
                //   materialTapTargetSize: MaterialTapTargetSize.padded,
                //   backgroundColor: _parkingButtonColor,
                //   mini: true,
                //   child: const Icon(Icons.local_parking, size: 30.0),
                // ),
              ],
            ),
          ),
        ),
        playBackControls(),
      ]),
    );
  }

  Widget playBackControls() {
    String fUpdateTime =
        ('sharedLoading').tr;
    String speed = ('sharedLoading').tr;
    if (routeList.length > _sliderValue.toInt()) {
      fUpdateTime = formatTime(routeList[_sliderValue.toInt()].fixTime!);
      speed = convertSpeed(routeList[_sliderValue.toInt()].speed!);
    }

    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withOpacity(0.5))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(top: 5.0, left: 5.0),
                          child: InkWell(
                            child: Icon(_isPlayingIcon,
                                color: CustomColor.primaryColor, size: 35.0),
                            onTap: () {
                              _playPausePressed();
                            },
                          )),
                      Container(
                          padding: EdgeInsets.only(top: 5.0),child: PopupMenuButton<Choice>(
                        onSelected: _select,
                        icon: Icon(Icons.timer, size: 30, color: CustomColor.primaryColor,),
                        itemBuilder: (BuildContext context) {
                          return choices.map((Choice choice) {
                            return PopupMenuItem<Choice>(
                              value: choice,
                              child: Text(choice.title),
                            );
                          }).toList();
                        },
                      )),
                      Container(
                          padding: EdgeInsets.only(top: 4.0, left: 0.0),
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: Slider(
                            value: _sliderValue.toDouble(),
                            onChanged: (newSliderValue) {
                              setState(
                                  () => _sliderValue = newSliderValue.toInt());
                              // ignore: unnecessary_null_comparison
                              if (timerPlayBack != null) {
                                if (!timerPlayBack!.isActive) {
                                  playUsingSlider(newSliderValue.toInt());
                                }
                              }
                            },
                            min: 0,
                            max: _sliderValueMax.toDouble(),
                          )),
                    ],
                  )),
              // new Container(
              //   margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
              //   child: Row(
              //     children: <Widget>[
              //       Container(
              //         padding: EdgeInsets.only(left: 5.0),
              //         child: Icon(Icons.radio_button_checked,
              //             color: CustomColor.primaryColor, size: 20.0),
              //       ),
              //       Container(
              //         padding: EdgeInsets.only(left: 5.0),
              //         child: Text(AppLocalizations.of(context)!
              //                 .translate('positionSpeed') +
              //             ": " +
              //             speed),
              //       ),
              //     ],
              //   ),
              // ),
              // _sliderValue.toInt() > 0
              //     ? routeList[_sliderValue.toInt()].address != null
              //         ? Row(
              //             children: <Widget>[
              //               Container(
              //                 padding: EdgeInsets.only(left: 5.0),
              //                 child: Icon(Icons.location_on_outlined,
              //                     color: CustomColor.primaryColor, size: 25.0),
              //               ),
              //               Expanded(
              //                 child: Column(
              //                     mainAxisAlignment: MainAxisAlignment.start,
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: [
              //                       Padding(
              //                           padding: EdgeInsets.only(
              //                               top: 10.0, left: 5.0, right: 0),
              //                           child: Text(
              //                             utf8.decode(utf8.encode(
              //                                 routeList[_sliderValue.toInt()]
              //                                     .address!)),
              //                             maxLines: 2,
              //                             overflow: TextOverflow.ellipsis,
              //                           )),
              //                     ]),
              //               )
              //             ],
              //           )
              //         : new Container()
              //     : new Container(),
              // new Container(
              //   margin: EdgeInsets.fromLTRB(5, 5, 0, 5),
              //   child: Row(
              //     children: <Widget>[
              //       Container(
              //         padding: EdgeInsets.only(left: 5.0),
              //         child: Icon(Icons.av_timer,
              //             color: CustomColor.primaryColor, size: 20.0),
              //       ),
              //       Container(
              //         padding: EdgeInsets.only(left: 5.0),
              //         child: Text(AppLocalizations.of(context)!
              //                 .translate('deviceLastUpdate') +
              //             ": " +
              //             fUpdateTime),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
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

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}

class Choice {
  const Choice({required this.title, required this.icon});

  final String title;
  final IconData icon;
}
