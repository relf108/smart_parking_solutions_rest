import 'package:conduit/conduit.dart';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';

import '../smart_parking_solutions_rest.dart';

class CurrentBookingsController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.get()
  Future<Response> get({@Bind.query("email") String? email}) async {
    final result = [];
    if (email != null) {
      final userDB = await DataBase.search(
          table: 'tbl_user', searchTermVal: {'email': email});
      final user = User.fromDBObj(userBinary: userDB.first);
      final bookings = await DataBase.search(
          table: 'tbl_booking', searchTermVal: {'ownerFK': await user.getUserID()});
      for (var booking in bookings) {
        result.add(Booking.fromDBObj(dbBinary: booking).toJson());
      }
    } else {
      final bookings = await DataBase.select(table: 'tbl_booking');
      for (var booking in bookings) {
        result.add(Booking.fromDBObj(dbBinary: booking).toJson());
      }
    }
    return Response.ok({'numberOfBookings': result.length, 'bookings': result});
  }
}
