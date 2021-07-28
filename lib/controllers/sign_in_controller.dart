import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';
import 'package:smart_parking_solutions_rest/smart_parking_solutions_rest.dart';

class SignInController extends ResourceController {
  Future prepare() async {  
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.get()
  Future<Response> get(@Bind.query('email') String email,
      @Bind.query('password') String password) async {
    final searchResult = await DataBase.search(
        table: 'tbl_user', searchTermVal: {'email': email});
    final user = User.fromMap(map: searchResult as Map);
    if (user.password == 'unset') {
      ///User created account through google and needs to create a password
      return Response.badRequest();
    }
    else if (password != user.password) {
      return Response.unauthorized();
    }
    return Response.accepted();
  }
}