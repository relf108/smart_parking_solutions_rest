import 'dart:convert';
import 'dart:io';

import 'package:conduit/conduit.dart';

import '../smart_parking_solutions_rest.dart';

class ParkingController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.get()
  Future<Response> get(
      @Bind.query('lat') double lat,
      @Bind.query('long') double long,
      @Bind.query('distance') int distance) async {
    final client =
        HttpClient(); // Todo client intialization in class constructor or pass throught constructor
    final uri = Uri.parse(
        "http://data.melbourne.vic.gov.au/resource/vh2v-4nfs.json?\$where=within_circle(location,$lat,$long,$distance)");
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
      final respMap = json.decode(respString);
      return Response.ok(respMap);
    }
  }
}
