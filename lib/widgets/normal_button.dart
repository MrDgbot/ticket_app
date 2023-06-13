import 'package:flutter/material.dart';
import 'package:ticket_app/topvars.dart';

class NormalButton extends StatelessWidget {
  final Text text;
  final Color backgroundColor;
  final VoidCallback? onPressed;

  const NormalButton(
      {super.key,
      required this.text,
      required this.backgroundColor,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      padding: edgeH16V12,
      color: backgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF42AD77), width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: text,
    );
  }
}
