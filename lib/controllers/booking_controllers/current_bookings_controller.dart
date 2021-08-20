import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';

import '../../smart_parking_solutions_rest.dart';

class CurrentBookingsController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.get()
  Future<Response> get(
      {@Bind.body() required Map<String, dynamic> json}) async {
    acceptedContentTypes.add(ContentType.json);
    final user = User.fromJson(json: json);
    final result = [];
    //   if (email != null) {
    final bookings = await DataBase.search(
        table: 'tbl_booking',
        searchTermVal: {'owner': (user.toJson()).toString()});
    for (var booking in bookings) {
      result.add(Booking.fromDBObj(dbBinary: booking).toJson());
    }
    return Response.ok({'numberOfBookings': result.length, 'bookings': result});
  }
}
