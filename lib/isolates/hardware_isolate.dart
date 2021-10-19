import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';
import 'package:smart_parking_solutions_rest/data_access_objects/booking_dao.dart';
import 'package:smart_parking_solutions_rest/smart_parking_solutions_rest.dart';

class HardwareIsolateFactory {
  //Todo Add Configuration
  static String hwUri = "http://192.168.1.101:5000";
  static Future<SendPort> initHardwareIsolate() async {
    final Completer completer = Completer<SendPort>();
    final ReceivePort isolateToMainStream = ReceivePort();
    isolateToMainStream.listen((data) {
      if (data is SendPort) {
        final SendPort mainToIsolateStream = data;
        completer.complete(mainToIsolateStream);
      } else {
        print('[isolateToMainStream] $data');
      }
    });
    await Isolate.spawn(hardwareIsolate, isolateToMainStream.sendPort);
    return completer.future as Future<SendPort>;
  }

//Nested if else
  static void hardwareIsolate(SendPort isolateToMainStream) async {
    final mainToIsolateStream = ReceivePort();
    isolateToMainStream.send(mainToIsolateStream.sendPort);
    final httpClient = HttpClient();
    const bool going = true;
    while (going) {
      final bays = await getRequest(hwUri, httpClient);
      bays.forEach((bay) async {
        final bookings = await getBookingsForBay(bay.bayID);
        if (bookings.isEmpty) {
        } else {
          final bookingDAO = BookingDAO.fromBooking(booking: bookings.first);
          final DateTime current = DateTime.now();
          if (current.difference(bookings.first.startDate).inMinutes <= 30 &&
              bookings.first.bookedSpace.status == "unoccupied") {
            if (bay.status == 4) {
              final currentSpace = bookings.first.bookedSpace;
              currentSpace.status = "occupied";
              final spotJson = jsonEncode(currentSpace.toJson());
              await bookingDAO.update(column: "bookedSpace", newVal: spotJson);
            } else {
              final Uri aUri = Uri.parse("$hwUri/setBay/${bay.bayID}");
              final request = await httpClient.postUrl(aUri);
              bay.status = 2;
              request.write(bay);
              await request.close();
            }
          }
        }
      });
      await Future.delayed(const Duration(seconds: 30));
    }
  }

  static Future<List<HWBay>> getRequest(String uri, HttpClient client) async {
    final aUri = Uri.parse("$uri/getBays");
    final req = await client.getUrl(aUri);
    final bays = <HWBay>[];
    final response =
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
  HWBay.fromJson(dynamic json) {
    bayID = int.parse(json[0]['bayID'].toString());
    status = int.parse(json[0]['status'].toString());
  }
  late int bayID;
  late int status;
  Map toJson() {
    final map = {'bayID': bayID, 'status': status};
    return map;
  }
}
