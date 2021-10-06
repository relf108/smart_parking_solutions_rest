import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:smart_parking_solutions_rest/isolates/communication_channel.dart';

class HumanAddressIsolateFactory {
  static Future<SendPort> initHumanAddressIsolate() async {
    final Completer completer = Completer<SendPort>();
    final isolateToMainStream = ReceivePort();

    isolateToMainStream.listen((data) {
      if (data is SendPort) {
        final mainToIsolateStream = data;
        completer.complete(mainToIsolateStream);
      } else {
        data = data as Map;
        final bayID = data.entries.first.key.toString();
        CommunicationChannel.humanAddress
            .addAll({bayID: data.entries.first.value.toString()});
        CommunicationChannel.status.entries
            .firstWhere((element) => element.key == bayID)
            .value['humanAddress'] = true;
      }
    });

    CommunicationChannel.isolates.add(
        await Isolate.spawn(humanAddressIsolate, isolateToMainStream.sendPort));
    return completer.future as Future<SendPort>;
  }

  static void humanAddressIsolate(SendPort isolateToMainStream) {
    final client = HttpClient();
    final mainToIsolateStream = ReceivePort();
    isolateToMainStream.send(mainToIsolateStream.sendPort);
    var response = '';
    mainToIsolateStream.listen((data) async {
      response = await getRequest(
          (data as Map).entries.first.value.toString(), client);
      isolateToMainStream.send({data.entries.first.key.toString(): response});
    });
  }

  static Future<String> getRequest(String data, HttpClient client) async {
    final uri = Uri.parse(data);
    final req = await client.getUrl(uri);
    final geocodeResp = (await req.close()).transform(const Utf8Decoder());
    var geoRespString = '';
    var formattedAddress = '';
    await for (var data in geocodeResp) {
      // ignore: use_string_buffers
      geoRespString += data;
    }
    if (!geoRespString.contains('{')) {
    } else {
      final geoMap = json.decode(geoRespString);
      final results = geoMap.entries
          .firstWhere((element) => element.key == 'results')
          .value;
      formattedAddress = (results.first as Map)
          .entries
          .firstWhere((element) => element.key == 'formatted_address')
          .value.toString();
    }
    return formattedAddress;
  }
}
