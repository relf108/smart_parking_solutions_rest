import 'dart:convert';
import 'dart:io';

import 'package:conduit/conduit.dart';

import '../smart_parking_solutions_rest.dart';

class ReserveSpaceController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.get()
  Future<Response> get(
      @Bind.query('bayID') String bayID,
      @Bind.query('email') String email,
      @Bind.query('startTime') DateTime startTime,
      @Bind.query('duration') Duration duration) async {
    final client =
        HttpClient(); // Todo client intialization in class constructor or pass throught constructor
    final uri = Uri.parse(
        "https://data.melbourne.vic.gov.au/resource/vh2v-4nfs.json?bay_id=$bayID");
    //HttpClientResponse httpResult;
    final HttpClientRequest req = await client.getUrl(uri);
    final response = (await req.close()).transform(const Utf8Decoder());
    var respString = '';
    await for (var data in response) {
      // ignore: use_string_buffers
      respString += data;
    }
    if (!respString.contains('{')) {
      return Response.noContent();
    } else {
      respString = respString.replaceAll('[', '').replaceAll(']', '');

      ///TODO display decode each result
      final respMap = json.decode(respString.split('\n,').first);

      return Response.ok(respMap);
    }
  }
}
