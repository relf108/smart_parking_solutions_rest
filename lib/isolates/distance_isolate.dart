import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:smart_parking_solutions_rest/isolates/communication_channel.dart';

class DistanceIsolateFactory {
  static Future<SendPort> initDistanceIsolate() async {
    final Completer completer = Completer<SendPort>();
    final isolateToMainStream = ReceivePort();

    isolateToMainStream.listen((data) {
      if (data is SendPort) {
        final mainToIsolateStream = data;
        completer.complete(mainToIsolateStream);
      } else {
        data = data as Map;
        final bayID = data.entries.first.key.toString();
        CommunicationChannel.distances
            .addAll({bayID: data.entries.first.value.toString()});
        CommunicationChannel.status.entries
            .firstWhere((element) => element.key == bayID)
            .value['dist'] = true;
      }
    });

    CommunicationChannel.isolates.add(
        await Isolate.spawn(distanceIsolate, isolateToMainStream.sendPort));
    return completer.future as Future<SendPort>;
  }

  static void distanceIsolate(SendPort isolateToMainStream) {
    final client = HttpClient();
    final mainToIsolateStream = ReceivePort();
    isolateToMainStream.send(mainToIsolateStream.sendPort);
    String response = '';
    mainToIsolateStream.listen((data) async {
      response = await getRequest(
          (data as Map).entries.first.value.toString(), client);
      //print('[mainToIsolateStream] ${response.first}');
      isolateToMainStream.send({data.entries.first.key.toString(): response});
    });
  }

  static Future<String> getRequest(String data, HttpClient client) async {
    final uri = Uri.parse(data);
    final req = await client.getUrl(uri);
    final distanceResp = (await req.close()).transform(const Utf8Decoder());
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
}
