import 'dart:async';
import 'package:conduit/conduit.dart';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';

class ChangePasswordController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.post()
  FutureOr<RequestOrResponse> post(@Bind.query("email") String email,
      @Bind.query("password") String password) async {
    final result = await DataBase.search(
        table: 'tbl_user', searchTermVal: {'email': email});
    final user = User.fromMap(map: result.fields.asMap());
    await DataBase.updateUser(column: 'password', newVal: password, user: user);
    return Response.ok("");
  }
}
