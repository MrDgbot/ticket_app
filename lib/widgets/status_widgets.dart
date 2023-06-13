import 'package:flutter/material.dart';

enum StatusType { loading, error }

class StatusWidget extends StatelessWidget {
  final StatusType status;
  final String errorMessage;

  const StatusWidget({
    Key? key,
    required this.status,
    this.errorMessage = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case StatusType.loading:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case StatusType.error:
        return Scaffold(
          body: Center(
            child: Text('加载数据出错！$errorMessage'),
          ),
        );
      default:
        return const SizedBox();
    }
  }
}
