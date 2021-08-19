import 'package:smart_parking_solutions_rest/smart_parking_solutions_rest.dart';

class DeleteBookingController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.get()
  Future<Response> get({@Bind.query("email") String? email}) async {
    return Response.ok("");
    
  }
}
