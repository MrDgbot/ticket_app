import 'package:ticket_app/model/train_info.dart';

class TicketItem {
  // 座位名称
  final String name;

  // 车票价格
  final double price;

  // 座位信息
  Seat seat;

  // 座位等级
  final String seatLevel;

  TicketItem(
      {required this.name,
      required this.price,
      required this.seat,
      required this.seatLevel});

  @override
  toString() {
    return 'TicketItem{name: $name, price: $price}';
  }
}
