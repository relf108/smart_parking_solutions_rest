import 'dart:convert';
import 'dart:core';

import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';
// ignore: implementation_imports
import 'package:smart_parking_solutions_common/src/credentials.dart';
import 'package:smart_parking_solutions_rest/data_access_objects/user_dao.dart';
import 'package:smart_parking_solutions_rest/smart_parking_solutions_rest.dart';

class OAuthController extends Controller {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @override
  FutureOr<RequestOrResponse> handle(Request request) async {
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
        'https://oauth2.googleapis.com/token?code=${responseCode[0]}&client_id=${Credentials.clientID}&client_secret=${Credentials.clientSecret}&redirect_uri=http://geekayk.ddns.net:8888/authUser&grant_type=authorization_code'));

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
    final User newUser = User(
        googleUserID: userInfoDecoded['id'] as String,
        givenName: userInfoDecoded['given_name'] as String,
        familyName: userInfoDecoded['family_name'] as String,
        email: userInfoDecoded['email'] as String,
        handicapped: false);
    final exists = await DataBase.search(
        table: 'tbl_user',
        searchTermVal: {'googleUserID': '${newUser.googleUserID}'});
    if (exists.isNotEmpty) {
      return Response.conflict(body: 'User exists');
    }
    await UserDAO.fromUser(user: newUser).insert();

    return Response.ok({});
  }
}
