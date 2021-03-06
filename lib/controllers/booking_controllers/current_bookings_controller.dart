import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';
import 'package:smart_parking_solutions_rest/data_access_objects/user_dao.dart';

import '../../smart_parking_solutions_rest.dart';

class CurrentBookingsController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.post()
  Future<Response> post(
      {@Bind.body() required Map<String, dynamic> jsonUser}) async {
    acceptedContentTypes.add(ContentType.json);
    final user = User.fromJson(json: jsonUser);
    final userDAO = UserDAO.fromUser(user: user);
    final result = [];
    //   if (email != null) {
    final bookings = await userDAO.getBookings();
    bookings.forEach(result.add);
    return Response.ok({'numberOfBookings': result.length, 'bookings': result});
  }
}
