import 'package:galileo_mysql/galileo_mysql.dart';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';
import 'package:smart_parking_solutions_rest/data_access_objects/database.dart';

class UserDAO {
  UserDAO(
      {required this.userID,
      required this.googleUserID,
      required this.givenName,
      required this.familyName,
      required this.email,
      required this.password,
      required this.handicapped});
  UserDAO.fromUser({required User user}) {
    userID = user.userID;
    googleUserID = user.googleUserID;
    givenName = user.givenName;
    familyName = user.familyName;
    email = user.email;
    password = user.password;
    handicapped = user.handicapped;
  }
  late int userID;
  String? googleUserID;
  String? givenName;
  String? familyName;
  String? email;
  String? password;
  bool? handicapped;

  Future<Results> insert() async {
    final conn = await DataBase.getConnection();
    final Results result;
    final searchResult = await DataBase.search(
        table: 'tbl_user', searchTermVal: {'googleUserID': googleUserID!});
    if (searchResult.isEmpty) {
      result = await conn.query(
          'insert into tbl_user (googleUserID, givenName, familyName, email, password, handicapped) values(?, ?, ?, ?, ?, ?)',
          [googleUserID, givenName, familyName, email, password, handicapped]);
    } else {
      result = await conn.query(
          'update tbl_user set password = ? where googleUserID = ?',
          [password, googleUserID]);
    }

    await conn.close();
    return result;
  }

  Future<Results> update({
    required String column,
    required String newVal,
  }) async {
    final conn = await DataBase.getConnection();
    final result = await conn.query(
        'update tbl_user set $column = \'$newVal\' where googleUserID = ?',
        [googleUserID]);
    await conn.close();
    return result;
  }

//SELECT *, owner->'$.userID' owner
// FROM tbl_booking;
  Future<List<Booking>> getBookings() async {
    final bookings = <Booking>[];
    final bookingBins = await DataBase.searchJson(
        table: 'tbl_booking',
        jsonColumnKey: {'owner': 'userID'},
        searchTerm: userID);
    for (var bin in bookingBins) {
      bookings.add(Booking.fromDBObj(dbBinary: bin));
    }
    return bookings;
  }
}
