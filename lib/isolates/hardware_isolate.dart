import 'dart:async';
import 'dart:io'; // for exit();
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';
import 'package:smart_parking_solutions_rest/data_access_objects/booking_dao.dart';
import 'package:smart_parking_solutions_rest/smart_parking_solutions_rest.dart';

class HardwareIsolateFactory {
  //Todo Add Configuration
  static String hwUri = "http://192.168.1.101:5000";
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
    final httpClient = new HttpClient();
    bool going = true;
    while (going) {
      var bays = await getRequest(hwUri, httpClient);
      bays.forEach((bay) async {
        final bookings = await getBookingsForBay(bay.bayID);
        if (bookings.isEmpty) {
        } else {
          final Uri aUri = Uri.parse("$hwUri/setBay/${bay.bayID}");
          final request = await httpClient.postUrl(aUri);
          request.write(bookings.first);
          await request.close();
        }
      });
      await Future.delayed(Duration(seconds: 30));
    }
  }

  static Future<List<HWBay>> getRequest(String uri, HttpClient client) async {
    final aUri = Uri.parse(uri + "/getBays");
    final req = await client.getUrl(aUri);
    final bays = <HWBay>[];
    var response =
        (await req.close()).transform(const Utf8Decoder()).asBroadcastStream();
    await response.forEach((element) {
      final elementJson = jsonDecode(element);
      final elementObj = HWBay.fromJson(elementJson);
      bays.add(elementObj);
    });
    return bays;
  }

  static Future<List<Booking>> getBookingsForBay(int bayID) async {
    final bookings = <Booking>[];
    final bookingBins = await DataBase.searchJson(
        table: 'tbl_booking',
        jsonColumnKey: {'bookedSpace': 'bay_id'},
        searchTerm: bayID);
    for (var bin in bookingBins) {
      bookings.add(Booking.fromDBObj(dbBinary: bin));
    }
    return bookings;
  }
}

//ToDo move to commons
class HWBay {
  late int bayID;
  late int status; // 1=Open,2=Booked,3=Other,4=Taken Todo make enum
  HWBay.fromJson(dynamic json) {
    bayID = int.parse(json[0]['bayID'].toString());
    status = int.parse(json[0]['status'].toString());
  }
  Map toJson() {
    final map = {'bayID': bayID, 'status': status};
    return map;
  }
}
