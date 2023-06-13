import 'package:flutter/material.dart';
import 'package:ticket_app/common/extensions.dart';
import 'package:ticket_app/model/ticket_item.dart';
import 'package:ticket_app/model/train_info.dart';
import 'package:ticket_app/topvars.dart';
import 'package:ticket_app/widgets/ticket_widgets/expand_button.dart';
import 'package:ticket_app/widgets/ticket_widgets/ticket_check_widget.dart';

import 'ticket_count_widget.dart';
import 'ticket_flow_widget.dart';
import 'ticket_top_info.dart';

/// 支持的车票显示类型
enum TicketWidgetType {
  flow, // 流式布局
  count, // 计数器
  check // 检查页面
}

class TicketCard extends StatefulWidget {
  final BuildContext context;

  /// 车票类型
  final TicketWidgetType type;

  /// 流式布局点击事件
  final Function(TicketItem)? onTicketFlowTap;

  /// 计数器点击事件
  final Function()? onTicketCountTap;

  /// 车票列表
  /// 【可空】根据type不同
  final SeatLevel? seatLevels;

  /// selectCount
  final ValueNotifier<int>? selectCount;

  const TicketCard({
    super.key,
    required this.context,
    required this.type,
    this.onTicketFlowTap,
    this.onTicketCountTap,
    this.selectCount,
    this.seatLevels,
  });

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  bool isExpanded = false;
  static const int itemsPerLine = 6;
  static const int linesWhenCollapsed = 2;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: edge8,
      child: Container(
        margin: edge10,
        child: Column(
          children: [
            TicketTopInfo(
              seatLevels: widget.seatLevels,
              type: widget.type,
            ),
            const Divider(),
            _buildTicketBottom(),
          ],
        ),
      ),
    );
  }

  /// 构建车票底部
  /// 清除和确认按钮
  Widget _buildTicketBottom() {
    switch (widget.type) {
      case TicketWidgetType.flow:
        return buildTicketList();
      case TicketWidgetType.count:
        return buildTicketCount();
      case TicketWidgetType.check:
        return buildTicketCheck();
    }
  }

  /// 构建添加乘客布局
  Widget buildTicketCheck() {
    return TicketCheckWidget(seatLevel: widget.seatLevels!);
  }

  /// 构建车票计数器
  /// VIP模式
  Widget buildTicketCount() {
    return TicketCountWidget(
      countNotifier: widget.selectCount!,
      seatLevel: widget.seatLevels!,
      onCountChange: () {
        widget.onTicketCountTap?.call();
      },
    );
  }

  /// 构建车票流式布局
  /// 选座模式
  Widget buildTicketList() {
    // 检查座位等级和座位，如果不存在就返回一个空的 SizedBox
    if (widget.seatLevels == null || widget.seatLevels!.seats.isNullOrEmpty) {
      return sizedBox;
    }

    List<Widget> allItems = buildAllItems();
    int maxItemsWhenCollapsed = itemsPerLine * linesWhenCollapsed;

    Widget expandButton(bool isExpanded) {
      return buildExpandButton(isExpanded);
    }

    List<Widget> visibleItems;

    // 当所有的项目数量大于折叠状态下的最大数量时
    if (allItems.length > maxItemsWhenCollapsed) {
      visibleItems = getVisibleItems(allItems, maxItemsWhenCollapsed);
      visibleItems.add(expandButton(!isExpanded));
    } else {
      visibleItems = allItems;
    }

    // 返回 Flow 布局
    return buildFlowLayout(visibleItems);
  }

  List<Widget> buildAllItems() {
    // 遍历 seats ，为每个 seat 创建一个 TicketFlowWidget
    return widget.seatLevels!.seats!.map<Widget>((seat) {
      return TicketFlowWidget(
          seat: seat,
          onTap: () {
            // 回传ID便于票务页面进行选择数据
            TicketItem ticketItem = TicketItem(
              name: seat.seatNumber ?? '',
              price: widget.seatLevels!.price!,
              seat: seat,
              seatLevel: widget.seatLevels!.level!,
            );
            widget.onTicketFlowTap?.call(ticketItem);
          });
    }).toList();
  }

  Widget buildExpandButton(bool isExpanded) {
    // 根据是否扩展创建不同的扩展按钮
    return ExpandButton(
      onTap: () {
        setState(() {
          this.isExpanded = isExpanded;
        });
      },
      isExpanded: isExpanded,
      itemsPerLine: itemsPerLine,
    );
  }

  List<Widget> getVisibleItems(
      List<Widget> allItems, int maxItemsWhenCollapsed) {
    // 获取当前应该显示的项目
    if (isExpanded) {
      return allItems;
    } else {
      return allItems.sublist(0, maxItemsWhenCollapsed - 1);
    }
  }

  Widget buildFlowLayout(List<Widget> visibleItems) {
    // 创建 Flow 布局
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Flow(
          delegate: TicketFlowDelegate(
            isExpanded: isExpanded,
            itemExtent: constraints.maxWidth / itemsPerLine,
            childCount: visibleItems.length,
          ),
          children: visibleItems,
        );
      },
    );
  }
}

class TicketFlowDelegate extends FlowDelegate {
  final bool isExpanded;
  final double itemExtent;
  final int childCount;

  TicketFlowDelegate(
      {required this.isExpanded,
      required this.itemExtent,
      required this.childCount});

  @override
  void paintChildren(FlowPaintingContext context) {
    double x = 0;
    double y = 0;

    for (int i = 0; i < context.childCount; i++) {
      final double childWidth = context.getChildSize(i)!.width;

      if (x + childWidth > context.size.width) {
        x = 0;
        y += itemExtent;
      }

      context.paintChild(i, transform: Matrix4.translationValues(x, y, 0));
      if (i == context.childCount - 1) {
        x += childWidth;
      } else {
        x += itemExtent;
      }
    }
  }

  @override
  Size getSize(BoxConstraints constraints) {
    // 计算行数
    final int lineCount = (childCount / _TicketCardState.itemsPerLine).ceil();
    final double height = itemExtent * lineCount;

    return Size(constraints.maxWidth, height);
  }

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(width: itemExtent, height: itemExtent);
  }

  @override
  bool shouldRepaint(TicketFlowDelegate oldDelegate) {
    return oldDelegate.isExpanded != isExpanded;
  }
}
