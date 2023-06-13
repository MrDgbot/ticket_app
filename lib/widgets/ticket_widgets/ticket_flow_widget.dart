import 'package:flutter/material.dart';
import 'package:ticket_app/model/train_info.dart';
import 'package:ticket_app/topvars.dart';

class TicketFlowWidget extends StatelessWidget {
  final Seat seat;
  final VoidCallback onTap;
  final int itemsPerLine;
  final double itemsPadding;

  const TicketFlowWidget({
    Key? key,
    required this.seat,
    required this.onTap,
    this.itemsPerLine = 6,
    this.itemsPadding = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (seat.status) {
      case TicketStatus.sold:
        color = Colors.grey;
        break;
      case TicketStatus.available:
        color = Colors.green;
        break;
      case TicketStatus.reserved:
        color = Colors.yellow;
        break;
      default:
        color = Colors.grey;
    }

    // 判断是否可点击【可点击的状态有：available、reserved】
    bool clickable = seat.status == TicketStatus.available ||
        seat.status == TicketStatus.reserved;

    return Padding(
      padding: EdgeInsets.all(itemsPadding),
      child: GestureDetector(
        onTap: clickable ? onTap : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: EdgeInsets.all(itemsPadding),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),

              height: (MediaQuery.of(context).size.width - 200) / itemsPerLine,
              // Subtract the padding and spacing
              child: Center(
                child: Text(
                  seat.seatNumber ?? '',
                  style: textStyle14.copyWith(color: Colors.white),
                ),
              ),
            ),
            if (seat.status == TicketStatus.reserved)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
