import 'dart:async';

import 'package:mysql1/mysql1.dart';
import 'package:smart_parking_solutions_rest/credentials.dart';

class DataBase {
  static Future<MySqlConnection> getConnection() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(

        ///Localhost will be host server's ip or remain localhost if we use one server
        ///for the db and REST API
        host: 'localhost',
        port: 3306,
        user: Credentials.dbUser,
        db: 'smart_parking',
        password: Credentials.dbSecret));
    return conn;
  }

  static initDB() async {
    final conn = await getConnection();
    await conn.query(
        'CREATE TABLE IF NOT EXISTS tbl_user userID int NOT NULL AUTO_INCREMENT PRIMARY KEY, givenName varchar(255), familyName varchar(255), email varchar(255) disabled boolean');
    await conn.query(
        'CREATE TABLE IF NOT EXISTS tbl_booking id int NOT NULL AUTO_INCREMENT PRIMARY KEY');
  }
}
