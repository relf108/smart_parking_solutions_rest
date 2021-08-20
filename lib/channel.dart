import 'package:smart_parking_solutions_rest/controllers/user_controllers/change_password_controller.dart';
import 'package:smart_parking_solutions_rest/controllers/oaut_controllers/oauth_controller.dart';
import 'package:smart_parking_solutions_rest/controllers/booking_controllers/reserve_space_controller.dart';
import 'package:smart_parking_solutions_rest/controllers/bay_controllers/search_spaces_controller.dart';
import 'package:smart_parking_solutions_rest/controllers/user_controllers/sign_in_controller.dart';
import 'controllers/booking_controllers/current_bookings_controller.dart';
import 'controllers/booking_controllers/delete_booking_controller.dart';
import 'smart_parking_solutions_rest.dart';

class SmartParkingSolutionsRestChannel extends ApplicationChannel {
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route("/authUser").link(() => OAuthController());
    router.route("/searchSpaces").link(() => SearchSpacesController());
    router.route("/signInUser").link(() => SignInController());
    router.route("/changePassword").link(() => ChangePasswordController());
    router.route("/reserveSpace").link(() => ReserveSpaceController());
    router.route("/currentBookings").link(() => CurrentBookingsController());
    router.route("/deleteBooking").link(() => DeleteBookingController());
    return router;
  }
}
