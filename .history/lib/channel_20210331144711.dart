import 'dart:convert';

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
    router.route("/createUser").linkFunction((request) async {
      var responseCode = [];
      var accessToken = '';
      try {
        responseCode = request.raw.uri.queryParametersAll.entries
            .firstWhere((entries) => entries.key == 'code')
            .value;
      } on Exception catch (_) {
        ///TODO Display error message "User must accept permissions to login through google".
      }

      final client = HttpClient();
      final HttpClientRequest req = await client.postUrl(Uri.parse(
          'https://oauth2.googleapis.com/token?code=${responseCode[0]}&client_id=${Credentials.clientID}&client_secret=${Credentials.clientSecret}&redirect_uri=http://localhost:8888/createUser&grant_type=authorization_code'));
      final response = (await req.close()).transform(const Utf8Decoder());
      await for (var data in response) {
        accessToken += data;
      }
      accessToken = accessToken.split('access_token')[1].split(':')[1].split('\"')[1];
      print(accessToken);
      return Response.ok({"key": "value"});
    });

    return router;
  }
}
