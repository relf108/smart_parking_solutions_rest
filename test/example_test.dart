import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';

import 'harness/app.dart';

Future main() async {
  test("search user", () async {
    final result = await DataBase.search(
        table: 'tbl_user',
        searchTermVal: {'googleUserID': '116902257632708248933'});
    print(result.fields);
  });
  final harness = Harness()..install();

  test("GET /example returns 200 {'key': 'value'}", () async {
    expectResponse(await harness.agent!.get("/example"), 200,
        body: {"key": "value"});
  });
}
