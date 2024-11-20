// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
//import 'package:duration/duration.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:gpspro/traccar_gennissi.dart';
import 'package:web_socket_channel/io.dart';



class DataController extends GetxController {
  RxMap<int, Device> devices = <int, Device>{}.obs;
  RxMap<int, PositionModel> positions = <int, PositionModel>{}.obs;
 // RxMap<int, DateTime> lastStoppedTimes = <int, DateTime>{}.obs; // To track the last stop time for each device
 // RxMap<int, Duration> idleDurations = <int, Duration>{}.obs;   // To store the idle durations
 // List<Stop> _stopList = [];

  RxList<Event> events = <Event>[].obs;
  var counter = 0.obs;
  RxBool isLoading = true.obs;
  RxBool isEventLoading = true.obs;
  IOWebSocketChannel? socketChannel;

  @override
  Future<void> onInit() async {
    super.onInit();
    getDevices();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
  }

  void getDevices(){
    Traccar.getDevices().then((List<Device>? value) {
      initSocket();
      value!.forEach((element) {
        devices.putIfAbsent(element.id!, () => element);
        devices.update(element.id!, (value) => element);
      });
    });
  }

  void initSocket(){
    var uri = Uri.parse(Traccar.serverURL!);
    String socketScheme, socketURL;
    if (uri.scheme == "http") {
      socketScheme = "ws://";
    } else {
      socketScheme = "wss://";
    }

    if (uri.hasPort) {
      socketURL =
          socketScheme + uri.host + ":" + uri.port.toString() + "/api/socket";
    } else {
      socketURL = socketScheme + uri.host + "/api/socket";
    }

    socketChannel =
    new IOWebSocketChannel.connect(socketURL, headers: Traccar.headers);

    try {
      socketChannel!.stream.listen(
            (event) {
          var data = json.decode(event);
          print(data);
          if (data["events"] != null) {
            Iterable events = data["events"];
            List<Event> eventList =
            events.map((model) => Event.fromJson(model)).toList();
          }

          if (data["positions"] != null) {
            
            Iterable pos = data["positions"];
            List<PositionModel> posList =
            pos.map((model) => PositionModel.fromJson(model)).toList();

            posList.forEach((PositionModel element) async {
              //check if the address is empty
             if(element.address == null || element.address!.isEmpty)
              {
                String? resolvedAddress = await this.getAddressFromLatLng(element.latitude!, element.longitude!);
                if(resolvedAddress != null) {
                element.address = resolvedAddress;
                }
              }
              /*              
              if(element.speed! > 0 || element.attributes!['motion'] == true)
              {
                // If the car is moving, reset the last stopped time
                lastStoppedTimes.remove(element.deviceId!);
              }         
              // Determine if the car has stopped (speed = 0 or motion = false)
              else if (element.speed! == 0 || element.attributes!['motion'] == false || element.attributes!['ignition'] == false) {
                var fromDate = DateTime.now().toString();
                var tillDate = DateTime.now().toString();
                  // Calculate idle duration since the car has stopped
                  Traccar.getStops(element.deviceId!.toString(), fromDate, tillDate).then((value) => {
                    
                  });
               if (lastStoppedTimes.containsKey(element.deviceId!)) {
                  Duration idleDuration = DateTime.now().difference(lastStoppedTimes[element.deviceId!]!);
                  idleDurations[element.deviceId!] = idleDuration;
                }  
                else{
                // Store the last stopped time if it's not already stored
                lastStoppedTimes.putIfAbsent(element.deviceId!, () => DateTime.now());
                }
              } 

              // Add idle duration to the element's attributes (you can update this to fit your pin data structure)
              var devDur = idleDurations[element.deviceId!];
              element.attributes!['idleDuration'] = devDur != null ? prettyDuration(devDur) : "Not yet available";
              */
              // Update positions with the new data
              positions.putIfAbsent(element.deviceId!, () => element);
              positions.update(element.deviceId!, (value) => element);

            });
          }         


          if (data["devices"] != null) {
            Iterable events = data["devices"];
            List<Device> deviceList =
            events.map((model) => Device.fromJson(model)).toList();
            deviceList.forEach((Device element) {
              devices.putIfAbsent(element.id!, () => element);
              devices.update(element.id!, (value) => element);
            });
          }
          isLoading.value = false;
        },
        onDone: () {
          isLoading.value = false;
          socketChannel!.sink.close();
        },
        onError: (error) {
          isLoading.value = false;
          socketChannel!.sink.close();
          print('ws error $error');
        },
      );
    } catch (error) {
      isLoading.value = false;
      socketChannel!.sink.close();
      print('ws error $error');
    }
  }

  Future<String?> getAddressFromLatLng(double lat, double lng) async {
    final String apiKey = "AIzaSyDiA_r18xLZ5BPEu6xuFfmeX8mP0p_15Qs";
    //final String url = 'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng';
    final String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey";
try{
  
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
     if (jsonResponse['status'] == 'OK') {
       return jsonResponse['results'][0]['formatted_address'];
       //var res = jsonResponse['display_name']; 
        //return res;
      } else {
        print('Could not load address: ${jsonResponse['status']}');
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
}catch(error){
  print('getAddressFromLatLng error: $error');
}
    return null;
  }
  
}