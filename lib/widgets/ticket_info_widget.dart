import 'package:flutter/material.dart';
import 'package:ticket_app/model/train_info.dart';
import 'package:ticket_app/topvars.dart';

/// 车票信息组件
/// 车次、金额统计、座位统计等
class TicketInfoWidget extends StatefulWidget {
  /// 车票原始信息
  final TrainTicket? trainTicket;

  /// 选择数据
  final List<SeatLevel> selectedSeats;

  const TicketInfoWidget({
    Key? key,
    required this.trainTicket,
    required this.selectedSeats,
  }) : super(key: key);

  @override
  State<TicketInfoWidget> createState() => TicketInfoWidgetState();
}

class TicketInfoWidgetState extends State<TicketInfoWidget> {
  /// 使用 `fold` 方法计算所有已选择座位的总价。`fold` 方法接收两个参数：一个初始值和一个函数。
  /// 这个函数将对 `selectedSeats` 列表中的每个元素（即 `level`）执行。
  /// 它会计算 `level.price * level.seats.length` 的值（如果 `price` 或 `seats.length` 为空，则使用 `0`），
  /// 然后将这个值加到上一次的结果上，从而得到总价。
  double get totalPrice => widget.selectedSeats.fold(0,
      (prev, level) => prev + (level.price ?? 0) * (level.seats?.length ?? 0));

  /// 同理
  int get totalCount => widget.selectedSeats
      .fold(0, (prev, level) => prev + (level.seats?.length ?? 0));

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: edge10,
      color: const Color(0xFF4F9967),
      child: Row(
        children: [
          _buildTrainInfo(),
          const VerticalDivider(
            color: Colors.white,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          _buildTicketInfo(),
        ],
      ),
    );
  }

  Widget _buildTrainInfo() {
    return Expanded(
      child: Container(
        margin: edge10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.trainTicket!.trainInfo.trainNumber} (车牌 ${widget.trainTicket!.trainInfo.licensePlate})',
              style: textStyle16.copyWith(color: Colors.white),
            ),
            spacer,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '车票',
                  style: textStyle16.copyWith(color: Colors.white),
                ),
                spacer,
                Text(
                  'x$totalCount',
                  style: textStyle16.copyWith(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfo() {
    return Expanded(
      child: Container(
        margin: edge10,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  // 在json处理的时候已经格式化
                  widget.trainTicket!.ticketInfo.getMDFormattedTime(),
                  style: textStyle16.copyWith(color: Colors.white),
                ),
                spacer,
                Text(
                  // 在json处理的时候已经格式化
                  widget.trainTicket!.ticketInfo.getHHmmFormattedTime(),
                  style: textStyle16.copyWith(color: Colors.white),
                ),
              ],
            ),
            spacer,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '总金额',
                  style: textStyle16.copyWith(color: Colors.white),
                ),
                spacer,
                Text(
                  '$totalPrice',
                  style: textStyle16.copyWith(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
