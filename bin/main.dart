import 'package:smart_parking_solutions_rest/smart_parking_solutions_rest.dart';

Future main() async {
  final app = Application<SmartParkingSolutionsRestChannel>()
    ..options.configurationFilePath = "config.yaml"
    ..options.port = 8888;

  final count = Platform.numberOfProcessors ~/ 2;
  await app.start(numberOfInstances: count > 0 ? count : 1);

  try {
    await DataBase.initDB();
  } on Exception catch (_) {
    //On socket closed exception make sure this is the only connection to the database
    print('DB: Failed to initialise database');
    print(_.toString());
  }

  print("Application started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");
}
