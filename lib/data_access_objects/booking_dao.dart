import 'dart:convert';

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

  BookingDAO.fromBooking({required Booking booking}) {
    bookingID = booking.bookingID;
    owner = booking.owner;
    createdDate = booking.createdDate;
    startDate = booking.startDate;
    endDate = booking.endDate;
    bookedSpace = booking.bookedSpace;
  }

  late int bookingID;
  late User owner;
  late DateTime createdDate;
  late DateTime startDate;
  late DateTime endDate;
  late ParkingSpace bookedSpace;

  Future<Results> insert() async {
    final conn = await DataBase.getConnection();
    final result = await conn.query(
        'insert into tbl_booking (createdDate, startDate, endDate, owner, bookedSpace) values(?, ?, ?, ?, ?)',
        [
          DateTime.now().toUtc(),
          startDate,
          endDate,
          jsonEncode(owner.toJson()),
          jsonEncode(bookedSpace.toJson())
        ]);
    await conn.close();

    return result;
  }

  Future<Results> update({
    required String column,
    required String newVal,
  }) async {
    final conn = await DataBase.getConnection();
    final result = await conn.query(
        'update tbl_booking set $column = \'$newVal\' where bookingID = ?',
        [bookingID]);
    await conn.close();
    return result;
  }

  //ToDo, add SearchTime for Start/End DateTimes and CreateedDates

  Future<Results> delete() async {
    final conn = await DataBase.getConnection();
    final result = await conn
        .query('delete from tbl_booking where bookingID = ?', [bookingID]);
    return result;
  }
}
