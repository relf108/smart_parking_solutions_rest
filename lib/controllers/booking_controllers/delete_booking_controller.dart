import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';
import 'package:smart_parking_solutions_rest/data_access_objects/booking_dao.dart';
import 'package:smart_parking_solutions_rest/smart_parking_solutions_rest.dart';

class DeleteBookingController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.get()
  Future<Response> get(
      {@Bind.body() required Map<String, dynamic> json}) async {
    acceptedContentTypes.add(ContentType.json);
    final booking = Booking.fromJson(json: json);
    try {
      final dao = BookingDAO.fromBooking(booking: booking);
      await dao.delete();
    } on Exception catch (_) {
      return Response.badRequest();
    }
    return Response.accepted();
  }
}
