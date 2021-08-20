import 'dart:async';

import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';

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

  static Future<void> initDB() async {
    final conn = await getConnection();
    await conn.query(
        'CREATE TABLE IF NOT EXISTS tbl_user (userID int NOT NULL AUTO_INCREMENT PRIMARY KEY, googleUserID varchar(255), givenName varchar(255), familyName varchar(255), email varchar(255), password varchar(255), handicapped boolean)');
    await conn.query(
        'CREATE TABLE IF NOT EXISTS tbl_booking (bookingID int NOT NULL AUTO_INCREMENT PRIMARY KEY, owner JSON, createdDate DATETIME, startDate DATETIME, endDate DATETIME, bookedSpace JSON');
    //  await conn.query(
    //      'CREATE TABLE IF NOT EXISTS tbl_tokens (tokenID int NOT NULL AUTO_INCREMENT PRIMARY KEY, tokenValue VARCHAR(255), createdDate DATETIME, ownerFK int, FOREIGN KEY (ownerFK) REFERENCES tbl_user(userID))');
    await conn.close();
  }

  ///tables:<br>
  /// tbl_user, <br>
  /// tbl_booking <br>
  ///searchTermVal example:<br>
  /// {'googleUserID': '${newUser.googleUserID}'}
  static Future<Results> search(
      {required String? table,
      required Map<String, String>? searchTermVal}) async {
    final conn = await getConnection();
    final result = await conn.query(
        'select * from $table where ${searchTermVal!.entries.first.key} = ?',
        [searchTermVal.entries.first.value]);
    await conn.close();
    return result;
  }

  static Future<Results> selectAll({required String? table}) async {
    final conn = await getConnection();
    final result = await conn.query('select * from $table');
    await conn.close();
    return result;
  }

  // static Future<Results> createToken(
  //     {required String? tokenValue,
  //     required User? owner,
  //     required DateTime? createdDate}) async {
  //   final conn = await getConnection();
  //   final result = await conn.query(
  //       'insert into tbl_tokens (tokenValue, ownerFK, createdDate) values(?, ?, ?)',
  //       [tokenValue, await owner!.userID, createdDate!.toUtc()]);
  //   await conn.close();
  //   return result;
  // }
}
