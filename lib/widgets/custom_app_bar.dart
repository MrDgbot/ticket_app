import 'package:flutter/material.dart';
import 'package:ticket_app/topvars.dart';

class CustomAppBar extends AppBar {
  CustomAppBar(
      {Key? key,
      required String titleText,
      required String actionText,
      Function()? onPressed})
      : super(
          key: key,
          title: Center(child: Text(titleText)),
          backgroundColor: const Color(0xFF5EAB78),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onPressed, // 当onPressed为null时，IconButton将会被禁用
          ),
          actions: [
            Container(
              alignment: Alignment.center,
              margin: edge10,
              child:
                  Text(actionText, style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
}
