import 'dart:async';
import 'package:meta/meta.dart';

import 'package:mysql1/mysql1.dart';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';
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

  static Future<void> initDB() async {
    final conn = await getConnection();
    await conn.query(
        'CREATE TABLE IF NOT EXISTS tbl_user (userID int NOT NULL AUTO_INCREMENT PRIMARY KEY, givenName varchar(255), familyName varchar(255), email varchar(255), handicapped boolean)');
    await conn.query(
        'CREATE TABLE IF NOT EXISTS tbl_booking (bookingID int NOT NULL AUTO_INCREMENT PRIMARY KEY, bayID varchar(255), createdDate DATETIME, startDate DATETIME, endDate DATETIME, ownerFK int, FOREIGN KEY (ownerFK) REFERENCES tbl_user(userID))');
    await conn.query(
        'CREATE TABLE IF NOT EXISTS tbl_tokens (tokenID int NOT NULL AUTO_INCREMENT PRIMARY KEY, tokenValue VARCHAR(255), ownerFK int, FOREIGN KEY (ownerFK) REFERENCES tbl_user(userID))');
    await conn.close();
  }

  ///TODO prevent inserting duplicates
  static Future<Results> createUser(
      {@required String googleUserID,
      @required String givenName,
      @required String familyName,
      @required String email,
      @required bool handicapped}) async {
    final conn = await getConnection();
    final result = await conn.query(
        'insert into tbl_user (googleUserID, givenName, familyName, email, handicapped) values(?, ?, ?, ?, ?)',
        [googleUserID, givenName, familyName, email, handicapped]);
    await conn.close();
    return result;
  }

  ///tables:<br>
  /// tbl_user, <br>
  /// tbl_booking <br>
  ///searchTermVal example:<br>
  /// {'googleUserID': '${newUser.googleUserID}'}
  static Future<Results> search(
      {@required String table,
      @required Map<String, String> searchTermVal}) async {
    final conn = await getConnection();
    final result = await conn.query(
        'select * from $table where ${searchTermVal.entries.first.key} = ?',
        [searchTermVal.entries.first.value]);
    await conn.close();
    return result;
  }

  static Future<Results> createBooking(
      {@required String bayID,
      @required DateTime startDate,
      @required DateTime endDate,
      @required User owner}) async {
    final conn = await getConnection();
    final result = await conn.query(
        'insert into tbl_booking (bayID, createdDate, startDate, endDate, ownerFK) values(?, ?, ?, ?, ?)',
        [bayID, DateTime.now(), startDate, endDate, owner.getUserID]);
    await conn.close();
    return result;
  }

  static Future<Results> createToken(
      {@required String tokenValue,
      @required User owner,
      @required DateTime createdDate}) async {
    final conn = await getConnection();
    final result = await conn.query(
        'insert into tbl_tokens (tokenValue, ownerFK, createdDate) values(?, ?, ?)',
        [tokenValue, await owner.getUserID(), createdDate]);
    await conn.close();
    return result;
  }
}
