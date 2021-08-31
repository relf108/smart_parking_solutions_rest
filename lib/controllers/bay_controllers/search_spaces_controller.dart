import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:conduit/conduit.dart';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';
import 'package:smart_parking_solutions_rest/isolates/communication_channel.dart';
import 'package:smart_parking_solutions_rest/isolates/description_isolate.dart';
import 'package:smart_parking_solutions_rest/isolates/distance_isolate.dart';
import 'package:smart_parking_solutions_rest/isolates/human_address.dart';

import '../../../smart_parking_solutions_rest.dart';

class SearchSpacesController extends ResourceController {
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @Operation.get()
  Future<Response> get(@Bind.query('address') String address,
      @Bind.query('distance') int distance) async {
    final List<SearchSpacesResponse> responses = [];
    final List<ParkingSpace> spaces = [];
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
          spaces.add(ParkingSpace.fromJson(
              json: json.decode(space) as Map<String, dynamic>));
        }
      }
    }

    await _addressToCoordinates();
    await _getSpaces();
    final descriptionIsolateStream =
        await DescriptionIsolateFactory.initDescriptionIsolate();
    final distanceIsolateStream =
        await DistanceIsolateFactory.initDistanceIsolate();
    final humanAddressIsolateStream =
        await HumanAddressIsolateFactory.initHumanAddressIsolate();
    for (ParkingSpace space in spaces) {
      CommunicationChannel.status.addAll({
        space.bayID!: {'desc': false, 'dist': false, 'humanAddress': false}
      });
      descriptionIsolateStream.send({
        space.bayID:
            "https://data.melbourne.vic.gov.au/resource/ntht-5rk7.json?BayID=${space.bayID!}"
      });

      distanceIsolateStream.send({
        space.bayID:
            "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=${space.lat},${space.lon}&destinations=$lat,$long&key=${Credentials.googleKey}"
      });
      humanAddressIsolateStream.send({
        space.bayID:
            "https://maps.googleapis.com/maps/api/geocode/json?latlng=${space.lat},${space.lon}&key=${Credentials.googleKey}"
      });
    }
    if (await _ready()) {
      for (Isolate isolate in CommunicationChannel.isolates) {
        isolate.kill(priority: Isolate.immediate);
      }
      for (ParkingSpace space in spaces) {
        responses.add(SearchSpacesResponse(
            distance: CommunicationChannel.distances.entries
                .firstWhere((element) => element.key == space.bayID)
                .value,
            humanAddress: CommunicationChannel.humanAddress.entries
                .firstWhere((element) => element.key == space.bayID)
                .value
                .toString() ,
            space: space,
            description: CommunicationChannel.descriptions.entries
                .firstWhere((element) => element.key == space.bayID)
                .value));
      }
      final List jsonResponses = [];
      for (var response in responses) {
        jsonResponses.add(response.toJson());
      }
      return Response.ok(
          {'numberOfSpaces': jsonResponses.length, 'bays': jsonResponses});
    }
    return Response.noContent();
  }
}

Future<bool> _ready() async {
  bool result = false;
  for (var statusMap in CommunicationChannel.status.entries) {
    for (var status in statusMap.value.values) {
      if (status == false) {
        await Future.delayed(const Duration(milliseconds: 100))
            .then((value) => _ready());
      } else {
        result = true;
      }
    }
  }
  return result;
}
