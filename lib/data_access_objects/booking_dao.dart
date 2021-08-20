import 'package:galileo_mysql/galileo_mysql.dart';
import 'package:smart_parking_solutions_common/smart_parking_solutions_common.dart';

import 'database.dart';

class BookingDAO {
  BookingDAO(
      {required this.bookingID,
      required this.owner,
      required this.createdDate,
      required this.startDate,
      required this.endDate,
      required this.bookedSpace});

  late int bookingID;
  late User owner;
  late DateTime createdDate;
  late DateTime startDate;
  late DateTime endDate;
  late ParkingSpace bookedSpace;

  Future<Results> createBooking() async {
    final conn = await DataBase.getConnection();
    final result = await conn.query(
        'insert into tbl_booking (createdDate, startDate, endDate, owner, bookedSpace) values(?, ?, ?, ?, ?, ?, ?, ?)',
        [
          bookedSpace.bayID,
          DateTime.now().toUtc(),
          startDate,
          endDate,
          owner.toJson(),
          bookedSpace.toJson()
        ]);
    await conn.close();
    return result;
  }

  Future<Results> deleteBooking() async {
    final conn = await DataBase.getConnection();
    final result = await conn
        .query('delete from tbl_booking where bookingID = ?', [bookingID]);
    return result;
  }
}
