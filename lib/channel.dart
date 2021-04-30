import 'dart:convert';

import 'package:smart_parking_solutions_rest/credentials.dart';

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

    ///This channel is used when performing Google OAuth registration.
    router.route("/authUser").linkFunction((request) async {
      var responseCode = [];
      var accessToken = '';
      try {
        responseCode = request.raw.uri.queryParametersAll.entries
            .firstWhere((entries) => entries.key == 'code')
            .value;
      } on Exception catch (_) {
        return Response.unauthorized();
      }

      final client = HttpClient();
      final HttpClientRequest req = await client.postUrl(Uri.parse(
          'https://oauth2.googleapis.com/token?code=${responseCode[0]}&client_id=${Credentials.clientID}&client_secret=${Credentials.clientSecret}&redirect_uri=http://localhost:8888/authUser&grant_type=authorization_code'));
      final response = (await req.close()).transform(const Utf8Decoder());
      await for (var data in response) {
        // ignore: use_string_buffers
        accessToken += data;
      }
      accessToken =
          accessToken.split('access_token')[1].split(':')[1].split('\"')[1];

      ///push to db along with user
      print(accessToken);
      return Response.ok({"key": "value"});
    });

    return router;
  }
}
