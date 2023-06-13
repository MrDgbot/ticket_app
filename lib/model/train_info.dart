import 'package:intl/intl.dart';
import 'package:ticket_app/model/passenger_info.dart';

enum TicketStatus { sold, available, reserved }

class TrainInfo {
  String title;
  String trainNumber;
  String licensePlate;

  TrainInfo(
      {required this.trainNumber,
      required this.licensePlate,
      required this.title});

  factory TrainInfo.fromJson(Map<String, dynamic> json) {
    return TrainInfo(
      title: json['title'],
      trainNumber: json['train_number'],
      licensePlate: json['license_plate'],
    );
  }
}

class TicketInfo {
  DateTime time;
  double totalAmount;

  TicketInfo({required this.time, required this.totalAmount});

  factory TicketInfo.fromJson(Map<String, dynamic> json) {
    return TicketInfo(
      // 格式化时间，便于数据利用
      time: DateTime.parse(json['time']),
      totalAmount: json['total_amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'total_amount': totalAmount,
    };
  }

  /// 获取 'M-d' 格式的时间
  String getMDFormattedTime() {
    return DateFormat('M-d').format(time);
  }

  /// 获取 'HH:mm' 格式的时间
  String getHHmmFormattedTime() {
    return DateFormat('HH:mm').format(time);
  }
}

class Seat {
  String? seatNumber;

  /// 自定义状态，便于处理预售状态
  TicketStatus status;
  PassengerInfo? passengerInfo;

  Seat({required this.seatNumber, required this.status, this.passengerInfo});

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      seatNumber: json['seat_number'],
      status: json['sold_out'] ? TicketStatus.sold : TicketStatus.available,
      passengerInfo: json['passenger_info'] != null
          ? PassengerInfo.fromJson(json['passenger_info'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'seat_number': seatNumber,
        'sold_out': status == TicketStatus.sold,
        'passenger_info': passengerInfo?.toJson() ?? {},
      };

  void toggleReservation() {
    if (status == TicketStatus.available) {
      status = TicketStatus.reserved;
    } else if (status == TicketStatus.reserved) {
      status = TicketStatus.available;
    }
  }

  void purchase() {
    if (status == TicketStatus.reserved) {
      status = TicketStatus.sold;
    }
  }

  Seat copyWith({
    String? seatNumber,
    TicketStatus? status,
    PassengerInfo? passengerInfo,
  }) {
    return Seat(
      seatNumber: seatNumber ?? this.seatNumber,
      status: status ?? this.status,
      passengerInfo: passengerInfo ?? this.passengerInfo,
    );
  }
}

class SeatLevel {
  String? level;
  String? alias;
  double? price;
  List<Seat>? seats;

  SeatLevel({this.level, this.alias, this.price, this.seats});

  factory SeatLevel.fromJson(Map<String, dynamic> json) {
    var seatJson = json['seats'] as List;
    List<Seat> seatList = seatJson.map((i) => Seat.fromJson(i)).toList();

    return SeatLevel(
      level: json['level'],
      alias: json['alias'],
      price: json['price'],
      seats: seatList,
    );
  }

  SeatLevel copyWith({
    String? level,
    String? alias,
    double? price,
    List<Seat>? seats,
  }) {
    return SeatLevel(
      level: level ?? this.level,
      alias: alias ?? this.alias,
      price: price ?? this.price,
      seats: seats ?? this.seats,
    );
  }
}

class TrainTicket {
  TrainInfo trainInfo;
  TicketInfo ticketInfo;
  List<SeatLevel> seatLevels;

  TrainTicket(
      {required this.trainInfo,
      required this.ticketInfo,
      required this.seatLevels});

  factory TrainTicket.fromJson(Map<String, dynamic> json) {
    var trainInfo = TrainInfo.fromJson(json['train_info']);
    var ticketInfo = TicketInfo.fromJson(json['ticket_info']);

    var seatLevelJson = json['seat_levels'] as List;
    List<SeatLevel> seatLevelList =
        seatLevelJson.map((i) => SeatLevel.fromJson(i)).toList();

    return TrainTicket(
      trainInfo: trainInfo,
      ticketInfo: ticketInfo,
      seatLevels: seatLevelList,
    );
  }

  double get totalPrice => seatLevels.fold(0,
      (prev, level) => prev + (level.price ?? 0) * (level.seats?.length ?? 0));

  /// 同理
  int get totalCount =>
      seatLevels.fold(0, (prev, level) => prev + (level.seats?.length ?? 0));

  TrainTicket copyWith({
    TrainInfo? trainInfo,
    TicketInfo? ticketInfo,
    List<SeatLevel>? seatLevels,
  }) {
    return TrainTicket(
      trainInfo: trainInfo ?? this.trainInfo,
      ticketInfo: ticketInfo ?? this.ticketInfo,
      seatLevels: seatLevels ?? this.seatLevels,
    );
  }
}
