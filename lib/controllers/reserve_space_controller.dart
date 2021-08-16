import 'package:conduit/conduit.dart';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';

import '../smart_parking_solutions_rest.dart';

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
      await DataBase.createBooking(
          bayID: bayID, startDate: startDate, endDate: endDate, owner: user);
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
}
