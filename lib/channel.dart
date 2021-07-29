import 'package:smart_parking_solutions_rest/controllers/change_password_controller.dart';
import 'package:smart_parking_solutions_rest/controllers/oauth_controller.dart';
import 'package:smart_parking_solutions_rest/controllers/parking_controller.dart';
import 'package:smart_parking_solutions_rest/controllers/sign_in_controller.dart';
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
    router.route("/parking").link(() => ParkingController());
    router.route("/signInUser").link(() => SignInController());
    router.route("/changePassword").link(() => ChangePasswordController());
    return router;
  }
}
