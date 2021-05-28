
// TODO: Update this import with your application name to import all required aqueduct imports.
import 'dart:io';
import 'dart:convert';
import 'package:conduit/conduit.dart';
import '../smart_parking_solutions_rest.dart';

class ParkingController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }
  @Operation.get()
  Future<Response> get(@Bind.query('lat')double lat, @Bind.query('long')double long,@Bind.query('distance')int distance ) async {
    final client = HttpClient(); // Todo client intialization in class constructor or pass throught constructor 
    final uri = Uri.parse("http://data.melbourne.vic.gov.au/resource/vh2v-4nfs.json?\$where=within_circle(location,$lat,$long,$distnace)");
    HttpClientResponse httpResult;
    final HttpClientRequest req = await client.getUrl(uri);
    final response = (await req.close()).transform(const Utf8Decoder());
    return Response.ok(response);
  }
  

  @Operation.post()
  Future<Response> post() async {
    //TODO: Implement post method
  }

  @Operation.put()
  Future<Response> put() async {
    //TODO: Implement put method
  }

  @Operation.delete()
  Future<Response> delete() async {
    //TODO: Implement delete method
  }
}