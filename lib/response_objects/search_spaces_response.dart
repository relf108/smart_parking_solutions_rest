class SearchSpacesResponse {
  SearchSpacesResponse(
      {required this.distance,
      required this.lat,
      required this.long,
      required this.bayID,
      required this.streetMarkerID,
      required this.description});

  String distance;
  String lat;
  String long;
  String bayID;
  String streetMarkerID;
  Map description;

  Map toJson() {
    final map = {
      'distance': distance,
      'lat': lat,
      'long': long,
      'bayID': bayID,
      'streetMarkerID': streetMarkerID,
      'description': description
    };
    return map;
  }
}
