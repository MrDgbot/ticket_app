import 'package:flutter/material.dart';
import 'package:ticket_app/model/train_info.dart';
import 'package:ticket_app/topvars.dart';

class TicketCountWidget extends StatefulWidget {
  final ValueNotifier<int> countNotifier;
  final SeatLevel seatLevel;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final Function()? onCountChange;
  final Function(SeatLevel, int)? onSeatChange;

  const TicketCountWidget({
    Key? key,
    required this.countNotifier,
    required this.seatLevel,
    this.onIncrement,
    this.onDecrement,
    this.onCountChange,
    this.onSeatChange,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TicketCountWidgetState();
}

class _TicketCountWidgetState extends State<TicketCountWidget> {
  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: widget.countNotifier,
            builder: (BuildContext context, int count, Widget? child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildButton(Icons.remove, () {
                    setState(() {
                      if (count > 0) {
                        widget.onCountChange?.call();
                        widget.seatLevel.seats?.removeLast();
                        widget.countNotifier.value--;
                      }
                    });
                    widget.onDecrement?.call();
                  }),
                  // 文字
                  Container(
                    margin: edgeH8,
                    child: Text(
                      '$count',
                      style: textStyle16.copyWith(color: Colors.orange),
                    ),
                  ),
                  _buildButton(Icons.add, () {
                    setState(() {
                      widget.seatLevel.seats?.add(Seat(
                          seatNumber: '${count + 1}',
                          status: TicketStatus.reserved));
                      widget.countNotifier.value++;
                      widget.onCountChange?.call();
                    });
                    widget.onIncrement?.call();
                  }),
                ],
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  /// 创建一个按钮控件
  ///
  /// [icon] 用于在按钮中显示的图标
  /// [onTap] 当按钮被点击时调用的回调函数
  Widget _buildButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: edgeH16V8,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}
