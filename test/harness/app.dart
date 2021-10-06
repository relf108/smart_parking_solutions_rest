import 'package:conduit_test/conduit_test.dart';
import 'package:smart_parking_solutions_rest/smart_parking_solutions_rest.dart';
import 'package:test/test.dart';

export 'package:conduit/conduit.dart';
export 'package:conduit_test/conduit_test.dart';
export 'package:smart_parking_solutions_rest/smart_parking_solutions_rest.dart';
export 'package:test/test.dart';

/// A testing harness for smart_parking_solutions_rest.
///
/// A harness for testing an aqueduct application. Example test file:
///
void main() {
  final Harness harness = Harness()..install();

  test("GET /path returns 200", () async {
    final response = await harness.agent!.get("/path");
    expectResponse(response, 200);
  });
}

class Harness extends TestHarness<SmartParkingSolutionsRestChannel> {
  @override
  Future onSetUp() async {}

  @override
  Future onTearDown() async {}
}
