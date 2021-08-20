import 'dart:async';
import 'package:conduit/conduit.dart';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';
import 'package:smart_parking_solutions_rest/data_access_objects/user_dao.dart';

class ChangePasswordController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.get()
  FutureOr<Response> get(
      {@Bind.query("user") required User user,
      @Bind.query("password") required String password}) async {
    final userDAO = UserDAO.fromUser(user: user);
    try {
      await userDAO.update(column: 'password', newVal: password);
    } on Exception catch (_) {
      return Response.badRequest();
    }
    return Response.ok("");
  }
}
