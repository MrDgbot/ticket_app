import 'package:flutter/material.dart';

class ExpandButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isExpanded;
  final int itemsPerLine;
  final double itemsPadding;

  const ExpandButton({
    Key? key,
    required this.onTap,
    this.isExpanded = false,
    required this.itemsPerLine,
    this.itemsPadding = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: SizedBox(
          width:
              (MediaQuery.of(context).size.width - itemsPadding) / itemsPerLine,
          height:
              (MediaQuery.of(context).size.width - itemsPadding) / itemsPerLine,
          child: Icon(isExpanded ? Icons.expand_more : Icons.expand_less),
        ),
      ),
    );
  }
}
