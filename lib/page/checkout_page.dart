import 'package:flutter/material.dart';
import 'package:ticket_app/common/app_styles.dart';
import 'package:ticket_app/model/passenger_info.dart';
import 'package:ticket_app/model/train_info.dart';
import 'package:ticket_app/topvars.dart';
import 'package:ticket_app/widgets/custom_app_bar.dart';
import 'package:ticket_app/widgets/normal_button.dart';
import 'package:ticket_app/widgets/ticket_info_widget.dart';
import 'package:ticket_app/widgets/ticket_widgets/ticket_card.dart';

class TicketConfirmPage extends StatefulWidget {
  final TrainTicket? trainTicket;

  const TicketConfirmPage({Key? key, this.trainTicket}) : super(key: key);

  @override
  State<TicketConfirmPage> createState() => _TicketConfirmPageState();
}

class _TicketConfirmPageState extends State<TicketConfirmPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: widget.trainTicket?.trainInfo.title ?? '网络走丢了',
        actionText:
            widget.trainTicket?.ticketInfo.getHHmmFormattedTime() ?? '00:00',
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: ListView.builder(
        itemCount: (widget.trainTicket?.seatLevels.length ?? 0) + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return TicketInfoWidget(
              trainTicket: widget.trainTicket,
              selectedSeats: widget.trainTicket?.seatLevels ?? [],
            );
          }
          final seatLevel = widget.trainTicket!.seatLevels[index - 1];
          return TicketCard(
            context: context,
            seatLevels: seatLevel,
            type: TicketWidgetType.check,
          );
        },
      ),
      bottomNavigationBar: _buildBottomWidget(),
    );
  }

  Widget _buildBottomWidget() {
    return Padding(
      padding: edgeH24V36WithStatusBar,
      child: NormalButton(
        text: Text(
          "确定",
          style: textStyle16.copyWith(color: Colors.white),
        ),
        onPressed: _onPayPressed,
        backgroundColor: AppStyles.themeColor,
      ),
    );
  }

  /// 缴费确认事件
  void _onPayPressed() {
    // 检查是否有未填写的联系人
    bool hasUnfilledContact = widget.trainTicket!.seatLevels.any((element) {
      return element.seats?.any((seat) {
            PassengerInfo? passenger = seat.passengerInfo;
            return passenger == null ||
                passenger.firstName.isEmpty ||
                passenger.lastName.isEmpty ||
                passenger.idNumber.isEmpty ||
                passenger.phoneNumber.isEmpty;
          }) ??
          false;
    });

    if (hasUnfilledContact) {
      // 弹窗提示需要填写所有联系人信息
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("信息不完整"),
            content: const Text("请确保所有乘客信息已填写完整"),
            actions: [
              NormalButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                backgroundColor: AppStyles.themeColor,
                text: Text(
                  "确定",
                  style: textStyle16.copyWith(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // 如果所有联系人都填写了，弹窗缴费成功，跳转到首页
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("缴费成功"),
            content: const Text("您已成功购买车票，祝您旅途愉快！"),
            actions: [
              NormalButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil("/", (route) => false);
                },
                backgroundColor: AppStyles.themeColor,
                text: Text(
                  "确定",
                  style: textStyle16.copyWith(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
