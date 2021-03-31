import 'package:smart_parking_solutions_rest/credentials.dart';

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

    // Prefer to use `link` instead of `linkFunction`.
    // See: https://aqueduct.io/docs/http/request_controller/
    // router.route("/googleSignIn").linkFunction((request) async {
    //   final client = HttpClient();
    //   await client.postUrl(Uri.parse(
    //       'https://accounts.google.com/o/oauth2/v2/auth?scope=https%3A//www.googleapis.com/auth/drive.metadata.readonly&response_type=code&redirect_uri=http://localhost:8888/createUser&client_id=${Credentials.clientID}'));
    //   return Response.ok({"key": "value"});
    // });

    router.route("/createUser").linkFunction((request) {
      print(request.raw.uri.queryParametersAll.containsKey);
      return Response.ok({"key": "value"});
    });

    return router;
  }
}
