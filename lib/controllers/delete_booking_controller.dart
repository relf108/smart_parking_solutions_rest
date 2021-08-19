import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';
import 'package:smart_parking_solutions_rest/smart_parking_solutions_rest.dart';

class DeleteBookingController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.get()
  Future<Response> get(
      {@Bind.query("email") required String email,
      @Bind.query("createdDate") required DateTime createdDate}) async {
    final Booking booking;
    final userBin = await DataBase.search(
        table: 'tbl_user', searchTermVal: {'email': email});
    final user = User.fromDBObj(userBinary: userBin.first);
    try {
      booking = (await user.getBookings())
          .firstWhere((element) => element.createdDate == createdDate);
    } on Exception catch (_) {
      return Response.badRequest();
    }

    await DataBase.deleteBooking(bookingID: booking.getBookingID());
    return Response.accepted();
  }
}
