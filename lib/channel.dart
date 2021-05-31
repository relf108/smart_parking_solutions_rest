import 'dart:convert';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';
import 'package:smart_parking_solutions_rest/credentials.dart';
import 'package:smart_parking_solutions_rest/database.dart';
import 'package:smart_parking_solutions_rest/controller/parking_controller.dart';
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
      var tokenCreated = DateTime.now().toUtc();
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
      final Map accessTokenDecoded = json.decode(accessToken) as Map;

      final accessTokenVal = accessTokenDecoded.entries
          .firstWhere((element) => element.key == 'access_token');

      final HttpClientRequest userInfo = await client.getUrl(Uri.parse(
          'https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=${accessTokenVal.value}'));
      final userInfoResp =
          (await userInfo.close()).transform(const Utf8Decoder());
      var userInfoString = '';
      await for (var data in userInfoResp) {
        // ignore: use_string_buffers
        userInfoString += data;
      }
      final userInfoDecoded = json.decode(userInfoString) as Map;
      final User newUser = User.fromMap(map: userInfoDecoded);
      await DataBase.createUser(
          givenName: newUser.givenName,
          familyName: newUser.familyName,
          email: newUser.email,
          handicapped: newUser.disabled,
          googleUserID: newUser.googleUserID);

      final AccessToken newToken = AccessToken(
          createdDate: tokenCreated,
          owner: newUser,
          value: accessTokenVal.value.toString());
      await DataBase.createToken(
          tokenValue: newToken.value,
          owner: newUser,
          createdDate: tokenCreated);
      return Response.ok({"key": "value"});
    });
    router
        .route("/parking")
        .link(() => ParkingController());

    return router;
  }
}
