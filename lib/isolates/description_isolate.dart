import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:smart_parking_solutions_rest/isolates/communication_channel.dart';

class DescriptionIsolateFactory {
  static Future<SendPort> initDescriptionIsolate() async {
    final Completer completer = Completer<SendPort>();
    final isolateToMainStream = ReceivePort();

    isolateToMainStream.listen((data) {
      if (data is SendPort) {
        final mainToIsolateStream = data;
        completer.complete(mainToIsolateStream);
      } else {
        final descMapFull = data as Map;
        final descMap = {};
        for (var entry in descMapFull.entries) {
          if (entry.key.toString().contains('description')) {
            descMap.addAll({entry.key: entry.value});
          }
        }
        final bayID = data.entries.first.value.toString();
        CommunicationChannel.descriptions.addAll({bayID: descMap});
        CommunicationChannel.status.entries
            .firstWhere((element) => element.key == bayID)
            .value['desc'] = true;
      }
    });

    CommunicationChannel.isolates.add(
        await Isolate.spawn(descriptionIsolate, isolateToMainStream.sendPort));
    return completer.future as Future<SendPort>;
  }

  static void descriptionIsolate(SendPort isolateToMainStream) {
    final client = HttpClient();
    final mainToIsolateStream = ReceivePort();
    isolateToMainStream.send(mainToIsolateStream.sendPort);
    Map response = {};
    mainToIsolateStream.listen((data) async {
      response = await getRequest(
          (data as Map).entries.first.value.toString(), client);
      isolateToMainStream.send(response);
    });
  }

  static Future<Map> getRequest(String data, HttpClient client) async {
    final uri = Uri.parse(data);
    final req = await client.getUrl(uri);
    final response = (await req.close()).transform(const Utf8Decoder());
    var descString = '';
    await for (var data in response) {
      // ignore: use_string_buffers
      descString += data;
    }
    descString = descString.replaceAll('[', '').replaceAll(']', '');
    return jsonDecode(descString) as Map;
  }
}
