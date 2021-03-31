import 'smart_parking_solutions_rest.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class SmartParkingSolutionsRestChannel extends ApplicationChannel {
  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();
    router.route("/createUser").linkFunction((request) {
      var responseCode = [];
      try{
          responseCode = request.raw.uri.queryParametersAll.entries
          .firstWhere((entries) => entries.key == 'code')
          .value;
      }
      on Exception catch(_){
        ///TODO Display error message "User must accept permissions to login through google".
      }

      var client = new HttpClient().post(UriData.fromString(''));

      return Response.ok({"key": "value"});
    });

    return router;
  }
}
