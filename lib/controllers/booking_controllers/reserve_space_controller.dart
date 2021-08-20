import 'dart:convert';

import 'package:conduit/conduit.dart';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';

import '../../smart_parking_solutions_rest.dart';

class ReserveSpaceController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.get()
  Future<Response> get(
      @Bind.query('bayID') String bayID,
      @Bind.query('email') String email,
      @Bind.query('startTime') DateTime startDate,
      @Bind.query('duration') String durationString) async {
    final durationArr = durationString.split(':');
    final duration = Duration(
        hours: int.tryParse(durationArr[0])!,
        minutes: int.tryParse(durationArr[1])!,
        seconds: int.tryParse(durationArr[2])!);
    final bookingSearch = await DataBase.search(
        table: 'tbl_booking', searchTermVal: {'bayID': '$bayID'});
    final endDate = startDate.add(duration);
    if (bookingSearch.isEmpty ||
        isAvailable(start: startDate, end: endDate, results: bookingSearch)) {
      final usrSearch = await DataBase.search(
          table: 'tbl_user', searchTermVal: {'email': email});
      final user = User.fromDBObj(userBinary: usrSearch.first);
      final bayDetails = await _getDescription(bayID);
      final streetMarkerID = bayDetails!.entries
          .firstWhere((entry) => entry.key == 'st_marker_id')
          .value
          .toString();
      final lat = bayDetails.entries
          .firstWhere((entry) => entry.key == 'lat')
          .value
          .toString();
      final lon = bayDetails.entries
          .firstWhere((entry) => entry.key == 'lon')
          .value
          .toString();
      await DataBase.createBooking(
          bayID: bayID,
          startDate: startDate,
          endDate: endDate,
          owner: user,
          streetMarkerID: streetMarkerID,
          lat: lat,
          lon: lon);
    } else {
      return Response.badRequest();
    }

    return Response.accepted();
  }

  bool isAvailable(
      {required DateTime start,
      required DateTime end,
      required Results results}) {
    for (var result in results) {
      final booking = Booking.fromDBObj(dbBinary: result);
      if (booking.isOverlapping(start: start, end: end)) {
        return false;
      }
    }
    return true;
  }

  Future<Map?> _getDescription(String bayID) async {
    final client = HttpClient();
    final descUri = Uri.parse(
        "https://data.melbourne.vic.gov.au/resource/vh2v-4nfs.json?bay_id=$bayID");
    final HttpClientRequest descReq = await client.getUrl(descUri);
    final descResponse = (await descReq.close()).transform(const Utf8Decoder());
    var descString = '';
    await for (var data in descResponse) {
      // ignore: use_string_buffers
      descString += data;
    }
    descString = descString.replaceAll('[', '').replaceAll(']', '');
    return jsonDecode(descString) as Map;
  }
}
