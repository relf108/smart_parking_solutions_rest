import 'dart:async';
import 'dart:io'; // for exit();
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';

class HardwareIsolateFactory {
  //Todo Add Configuration
  static String hwUri = "http://192.168.1.101:5000/getbays";
  static Future<SendPort> initHardwareIsolate() async {
    final Completer completer = new Completer<SendPort>();
    ReceivePort isolateToMainStream = ReceivePort();
    isolateToMainStream.listen((data) {
      if (data is SendPort) {
        SendPort mainToIsolateStream = data;
        completer.complete(mainToIsolateStream);
      } else {
        print('[isolateToMainStream] $data');
      }
    });
    Isolate myIsolateInstance =
        await Isolate.spawn(hardwareIsolate, isolateToMainStream.sendPort);
    return completer.future as Future<SendPort>;
  }

  static void hardwareIsolate(SendPort isolateToMainStream) async {
    final mainToIsolateStream = ReceivePort();

    isolateToMainStream.send(mainToIsolateStream.sendPort);
    HttpClient httpClient = new HttpClient();
    bool going = true;
    while (going) {
      await getRequest(hwUri, httpClient);
      await Future.delayed(Duration(seconds: 30));
    }
  }

  static Future<List<dynamic>> getRequest(String uri, HttpClient client) async {
    final aUri = Uri.parse(uri);
    final req = await client.getUrl(aUri);
    final bays = [];
    final response = (await req.close()).transform(const Utf8Decoder());
    final jBays = jsonDecode(response.toString()) as List;
    jBays.forEach(bays.add);
    return bays;
  }
}

//ToDo move to commons
class HWBay {
  int? bayID;
  int? status; // 1=Open,2=Booked,3=Other,4=Taken
  HWBay.fromJson({required Map json}) {
    bayID = int.parse(json['bayID'].toString());
    status = int.parse(json['status'].toString());
  }
  Map toJson() {
    final map = {'bayID': bayID, 'status': status};
    return map;
  }
}
