import 'dart:isolate';

class CommunicationChannel {
  static Map<String, Map> descriptions = {};
  static Map<String, String> distances = {};
  static Map<String, Map> status = {};
  static List<Isolate> isolates = [];
}
