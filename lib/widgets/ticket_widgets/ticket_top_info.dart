import 'package:flutter/material.dart';
import 'package:ticket_app/model/train_info.dart';
import 'package:ticket_app/widgets/ticket_widgets/ticket_card.dart';

class TicketTopInfo extends StatelessWidget {
  final SeatLevel? seatLevels;
  final TicketWidgetType type;

  const TicketTopInfo({
    Key? key,
    this.seatLevels,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.normal, color: Colors.green),
            children: [
              TextSpan(
                text: '${seatLevels?.level}/',
              ),
              TextSpan(
                text: '${seatLevels?.alias} x',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Colors.green),
              ),
              TextSpan(
                text: '${seatLevels?.seats?.length ?? 0}',
              ),
            ],
          ),
        ),
        const Spacer(),
        if (type != TicketWidgetType.check)
          Text(
            "BTN ${seatLevels?.price ?? 0}",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.normal,
                  color: Colors.red,
                ),
          )
      ],
    );
  }
}
