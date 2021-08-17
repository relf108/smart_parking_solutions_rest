import 'dart:convert';
import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';

import '../smart_parking_solutions_rest.dart';

class SearchSpacesController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.get()
  Future<Response> get(@Bind.query('address') String address,
      @Bind.query('distance') int distance) async {
    final List<SearchSpacesResponse> responses = [];
    final List<Map> spaces = [];
    String lat = '';
    String long = '';
    final addressRequest = address.replaceAll(' ', '+');
    final client = HttpClient(); //

    Future<Response?> _addressToCoordinates() async {
      final geocodeUri = Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?address=$addressRequest&key=${Credentials.googleKey}");
      final HttpClientRequest geoReq = await client.getUrl(geocodeUri);
      final geocodeResp = (await geoReq.close()).transform(const Utf8Decoder());
      var geoRespString = '';
      await for (var data in geocodeResp) {
        // ignore: use_string_buffers
        geoRespString += data;
      }
      if (!geoRespString.contains('{')) {
        return Response.noContent();
      } else {
        final geoMap = json.decode(geoRespString);
        final results = geoMap.entries
            .firstWhere((element) => element.key == 'results')
            .value;
        final geometry = (results.first as Map)
            .entries
            .firstWhere((element) => element.key == 'geometry')
            .value;
        final location = geometry.entries
            .firstWhere((element) => element.key == 'location')
            .value as Map;
        lat = location.entries
            .firstWhere((element) => element.key == 'lat')
            .value
            .toString();
        long = location.entries
            .firstWhere((element) => element.key == 'lng')
            .value
            .toString();
      }
    }

    Future<Response?> _getSpaces() async {
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

        for (var space in respString.split('\n,')) {
          spaces.add(json.decode(space) as Map);
        }
      }
    }

    Future<Map?> _getDescription(String bayID) async {
      final descUri = Uri.parse(
          "https://data.melbourne.vic.gov.au/resource/ntht-5rk7.json?BayID=$bayID");
      final HttpClientRequest descReq = await client.getUrl(descUri);
      final descResponse =
          (await descReq.close()).transform(const Utf8Decoder());
      var descString = '';
      await for (var data in descResponse) {
        // ignore: use_string_buffers
        descString += data;
      }
      descString = descString.replaceAll('[', '').replaceAll(']', '');
      return jsonDecode(descString) as Map;
    }

    Future<String> distanceFromPoint(
        {required String newLat, required String newLong}) async {
      final distanceMatrix = Uri.parse(
          "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$newLat,$newLong&destinations=$lat,$long&key=${Credentials.googleKey}");
      final HttpClientRequest distanceReq = await client.getUrl(distanceMatrix);
      final distanceResp =
          (await distanceReq.close()).transform(const Utf8Decoder());
      var distanceRespString = '';
      await for (var data in distanceResp) {
        // ignore: use_string_buffers
        distanceRespString += data;
      }
      final distMap = jsonDecode(distanceRespString) as Map;
      final distance = distMap.entries
          .firstWhere((element) => element.key == 'rows')
          .value[0]
          .entries
          .first
          .value[0]
          .entries
          .first
          .value
          .entries
          .firstWhere((element) => element.key == 'value')
          .value
          .toString();
      return distance;
    }

    await _addressToCoordinates();
    await _getSpaces();
    for (Map element in spaces) {
      final bayID = element.entries
          .firstWhere((entry) => entry.key == 'bay_id')
          .value
          .toString();
      final streetMarkerID = element.entries
          .firstWhere((entry) => entry.key == 'st_marker_id')
          .value
          .toString();
      final spaceLat = element.entries
          .firstWhere((entry) => entry.key == 'lat')
          .value
          .toString();
      final spaceLon = element.entries
          .firstWhere((entry) => entry.key == 'lon')
          .value
          .toString();
      final location = element.entries
          .firstWhere((entry) => entry.key == 'location')
          .value as Map;
      final humanAddress = location.entries
          .firstWhere((element) => element.key == 'human_address')
          .value.toString();
      final descMapFull = await _getDescription(bayID);
      final descMap = {};
      for (var entry in descMapFull!.entries) {
        if (entry.key.toString().contains('description')) {
          descMap.addAll({entry.key: entry.value});
        }
      }
      responses.add(SearchSpacesResponse(
          distance:
              await distanceFromPoint(newLat: spaceLat, newLong: spaceLon),
          humanAddress: humanAddress,
          lat: spaceLat,
          long: spaceLon,
          bayID: bayID,
          streetMarkerID: streetMarkerID,
          description: descMap));
    }
    final List jsonResponses = [];
    for (var response in responses) {
      jsonResponses.add(response.toJson());
    }
    return Response.ok(
        {'numberOfSpaces': jsonResponses.length, 'bays': jsonResponses});
  }
}
