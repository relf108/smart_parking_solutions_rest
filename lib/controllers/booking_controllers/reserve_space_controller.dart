import 'package:conduit/conduit.dart';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';
import 'package:smart_parking_solutions_rest/data_access_objects/booking_dao.dart';
import 'package:smart_parking_solutions_rest/isolates/communication_channel.dart';
import 'package:smart_parking_solutions_rest/isolates/human_address.dart';

import '../../smart_parking_solutions_rest.dart';

class ReserveSpaceController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.post()
  Future<Response> post(
      {@Bind.body() required Map<String, dynamic> json}) async {
    acceptedContentTypes.add(ContentType.json);
    var booking = Booking.fromJson(json: json);
    booking = await setHumanAddress(booking);
    final bookingSearch = await DataBase.searchJson(
        table: 'tbl_booking',
        jsonColumnKey: {'bookedSpace': 'bay_id'},
        searchTerm: booking.bookedSpace.bayID);
    if (bookingSearch.isEmpty ||
        isAvailable(booking: booking, results: bookingSearch)) {
      try {
        await BookingDAO.fromBooking(booking: booking).insert();
      } on Exception catch (_) {
        return Response.badRequest();
      }
    } else {
      return Response.conflict();
    }

    return Response.accepted();
  }

  Future<Booking> setHumanAddress(Booking booking) async {
    final humanAddressIsolateStream =
        await HumanAddressIsolateFactory.initHumanAddressIsolate();
    humanAddressIsolateStream.send({
      booking.bookedSpace.bayID:
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=${booking.bookedSpace.lat},${booking.bookedSpace.lon}&key=${Credentials.googleKey}"
    });
    try {
      booking.bookedSpace.location!.humanAddress = CommunicationChannel
          .humanAddress.entries
          .firstWhere((element) => element.key == booking.bookedSpace.bayID)
          .value
          .toString();
    } on StateError catch (_) {
      await Future.delayed(const Duration(milliseconds: 100))
          .then((value) => setHumanAddress(booking));
    }

    return booking;
  }

  bool isAvailable({required Booking booking, required Results results}) {
    for (var result in results) {
      final bookingRes = Booking.fromDBObj(dbBinary: result);
      if (bookingRes.isOverlapping(booking: booking)) {
        return false;
      }
    }
    return true;
  }
}
