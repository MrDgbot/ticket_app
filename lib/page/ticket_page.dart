import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ticket_app/common/app_styles.dart';
import 'package:ticket_app/model/ticket_item.dart';
import 'package:ticket_app/model/train_info.dart';
import 'package:ticket_app/page/checkout_page.dart';
import 'package:ticket_app/topvars.dart';
import 'package:ticket_app/widgets/custom_app_bar.dart';
import 'package:ticket_app/widgets/normal_button.dart';
import 'package:ticket_app/widgets/status_widgets.dart';
import 'package:ticket_app/widgets/ticket_info_widget.dart';
import 'package:ticket_app/widgets/ticket_widgets/ticket_card.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({Key? key}) : super(key: key);

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  /// 车票原始数据
  TrainTicket? trainTicket;

  /// 选择的座位
  late List<SeatLevel> selectedSeats;

  /// 下层计数器（VIP座位数量）
  /// 用于记录用户已经选择的座位数，方便被外部重置。
  final seatCount = ValueNotifier<int>(0);

  /// 网络数据存储
  Future<TrainTicket>? _ticketFuture;

  @override
  void initState() {
    super.initState();
    selectedSeats = [];
    _ticketFuture = generateTickets();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TrainTicket>(
      future: _ticketFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const StatusWidget(status: StatusType.loading);
        } else if (snapshot.hasError) {
          return StatusWidget(
            status: StatusType.error,
            errorMessage: snapshot.error.toString(),
          );
        } else {
          trainTicket = snapshot.data;
          return Scaffold(
            backgroundColor: AppStyles.themeBackground,
            appBar: CustomAppBar(
              titleText: trainTicket?.trainInfo.title ?? '网络走丢了',
              actionText:
                  trainTicket?.ticketInfo.getHHmmFormattedTime() ?? '00:00',
              onPressed: () {
                /// 提示禁止点击（防止首页点击爆路由栈）
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('当前首页，禁止点击'),
                    duration: Duration(milliseconds: 500),
                  ),
                );
              },
            ),
            body: Column(
              children: [
                TicketInfoWidget(
                  trainTicket: trainTicket,
                  selectedSeats: selectedSeats,
                ),
                _buildTicketStatusTips(),
                _buildTicketSelect(),
              ],
            ),
          );
        }
      },
    );
  }

  /// 计算总预定金额
  double calculateTotalPrice(List<SeatLevel> selectedSeats) {
    double totalPrice = 0.0;
    for (SeatLevel level in selectedSeats) {
      int seatCount = level.seats?.length ?? 0;
      double seatPrice = level.price ?? 0.0;
      totalPrice += seatCount * seatPrice;
    }
    return totalPrice;
  }

  /// 计算总票数
  int calculateTotalCount(List<SeatLevel> selectedSeats) {
    int totalCount = 0;
    for (SeatLevel level in selectedSeats) {
      int seatCount = level.seats?.length ?? 0;
      totalCount += seatCount;
    }
    return totalCount;
  }

  /// 车票状态说明
  Widget _buildTicketStatusTips() {
    // 生成一个说明方块
    Widget buildItemInfo(String title, Color color) {
      return Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          sizedBoxW4,
          Text(title),
        ],
      );
    }

    return Container(
      margin: edge10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildItemInfo('已售', Colors.grey),
          buildItemInfo('可售', Colors.green),
          buildItemInfo('预定', Colors.yellow),
        ],
      ),
    );
  }

  /// 选票
  Widget _buildTicketSelect() {
    // 流式布局（多排列）点击事件
    // 提取当前等级信息，添加到 selectedSeats 列表中
    void onTicketFlowTap(TicketItem ticketItem) {
      setState(() {
        // 查找是否有相同等级的 SeatLevel
        SeatLevel? level;
        try {
          level =
              selectedSeats.firstWhere((l) => l.level == ticketItem.seatLevel);
        } catch (e) {
          level = null;
        }

        // 如果 SeatLevel 不存在，则创建新的 SeatLevel 并添加到 selectedSeats 列表
        if (level == null) {
          level = SeatLevel(
              level: ticketItem.seatLevel,
              alias: "",
              price: ticketItem.price,
              seats: []);
          selectedSeats.add(level);
        }

        // 如果 seat 的状态是可用并且 seat 不在 seats 列表中，则添加 seat 到 seats 列表
        if (ticketItem.seat.status == TicketStatus.available &&
            !level.seats!.contains(ticketItem.seat)) {
          level.seats?.add(ticketItem.seat);
        } else {
          level.seats?.remove(ticketItem.seat);
        }
        // 在状态更新后，手动更改座位状态
        ticketItem.seat.toggleReservation();
      });
    }

    /// 计数器点击事件
    /// 提取vip等级的座位
    /// 拷贝到seatLevels选择列表中
    void onTicketCountTap() {
      setState(() {
        // 提取 vip 等级的座位
        SeatLevel? vipLevel;

        try {
          vipLevel = trainTicket!.seatLevels
              .firstWhere((l) => l.level == 'vip' && l.seats!.isNotEmpty);
        } catch (e) {
          vipLevel = null;
        }

        if (vipLevel != null) {
          // 如果 vip 等级存在，则将 vip 等级的座位添加到 selectedSeats 列表中
          int index = selectedSeats.indexWhere((l) => l.level == 'vip');
          if (index != -1) {
            selectedSeats[index] = vipLevel;
          } else {
            selectedSeats.add(vipLevel);
          }
        }
      });
    }

    return Expanded(
      child: ListView.builder(
        itemCount: trainTicket!.seatLevels.length + 1,
        itemBuilder: (context, index) {
          if (index == trainTicket!.seatLevels.length) {
            return _buildBottomWidget();
          }
          return TicketCard(
            context: context,
            seatLevels: index <= 2 ? trainTicket!.seatLevels[index] : null,
            onTicketFlowTap: index < 2 ? onTicketFlowTap : null,
            onTicketCountTap: index == 2 ? onTicketCountTap : null,
            selectCount: seatCount,
            type: index < 2 ? TicketWidgetType.flow : TicketWidgetType.count,
          );
        },
      ),
    );
  }

  Future<TrainTicket> generateTickets() async {
    try {
      String jsonString = await rootBundle.loadString('assets/test.json');
      Map<String, dynamic> jsonData = jsonDecode(jsonString);

      /// 等待500毫秒，伪造网络等待
      await Future.delayed(const Duration(milliseconds: 500));
      return TrainTicket.fromJson(jsonData);
    } catch (e) {
      throw Exception("Failed to load tickets");
    }
  }

  /// 底部功能按钮
  Widget _buildBottomWidget() {
    return Container(
      margin: edgeH24V36WithStatusBar,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: NormalButton(
              onPressed: () {
                onClearButtonTap();
              },
              text: Text(
                "清除",
                style: textStyle16.copyWith(color: const Color(0xFF7DAB91)),
              ),
              backgroundColor: const Color(0xFFF5F9F7),
            ),
          ),
          sizedBoxW16,
          Expanded(
            child: NormalButton(
              onPressed: () {
                onConfirmButtonTap();
              },
              text: Text(
                "确定",
                style: textStyle16.copyWith(color: Colors.white),
              ),
              backgroundColor: AppStyles.themeColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 清除按钮点击事件
  void onClearButtonTap() {
    setState(() {
      // 清理选择的座位
      selectedSeats.clear();
      // 清理选择的座位数量
      seatCount.value = 0;
      for (var level in trainTicket!.seatLevels) {
        if (level.level == 'vip') {
          level.seats?.clear();
          continue;
        }
        level.seats?.forEach((seat) {
          if (seat.status == TicketStatus.reserved) {
            seat.toggleReservation();
          }
        });
      }
    });
  }

  /// 确定按钮点击事件
  /// 检测是否选择，没选择弹窗提示
  void onConfirmButtonTap() {
    /// 计算是否选择座位
    int total = selectedSeats.fold(
        0, (prev, element) => prev + (element.seats?.length ?? 0));

    if (total == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("请选择座位"),
          duration: Duration(milliseconds: 100),
        ),
      );
      return;
    }

    /// 自定义trainTicket传递给下一个页面

    final postTrainTicket = trainTicket?.copyWith(seatLevels: selectedSeats);
    postTrainTicket?.seatLevels.removeWhere(
        (element) => element.seats == null || element.seats!.isEmpty);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketConfirmPage(
          trainTicket: postTrainTicket,
        ),
      ),
    );
  }
}
