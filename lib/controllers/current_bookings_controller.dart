import 'package:conduit/conduit.dart';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';

import '../smart_parking_solutions_rest.dart';

class CurrentBookingsController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.get()
  Future<Response> get() async {
    final bookings = await DataBase.select(table: 'tbl_booking');
    final result = [];
    for (var booking in bookings) {
      result.add(Booking.fromDBObj(dbBinary: booking).toJson());
    }
    return Response.ok({'bookings': result});
  }
}
