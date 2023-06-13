import 'package:flutter/material.dart';
import 'package:ticket_app/model/passenger_info.dart';
import 'package:ticket_app/model/train_info.dart';
import 'package:ticket_app/topvars.dart';
import 'package:ticket_app/widgets/ticket_widgets/passenger_dialog.dart';

class TicketCheckWidget extends StatefulWidget {
  final SeatLevel seatLevel;

  const TicketCheckWidget({Key? key, required this.seatLevel})
      : super(key: key);

  @override
  State<TicketCheckWidget> createState() => TicketCheckWidgetState();
}

class TicketCheckWidgetState extends State<TicketCheckWidget> {
  final formKey = GlobalKey<FormState>();

  IDType selectedIDType = IDType.identityCard; // 假设默认为身份证

  String selectedPhoneRegionCode = '+86'; // 你需要设置合适的默认值
  Map<String, dynamic> textEditingControllers = {};

  @override
  void initState() {
    super.initState();
    textEditingControllers = {
      'firstName': TextEditingController(),
      'lastName': TextEditingController(),
      'phoneRegionCode': DropdownButtonFormField<String>(
        value: selectedPhoneRegionCode,
        items: <String>['+86', '+1', '+44', '+61'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          // 在用户选择新的项时更新 selectedIDType
          setState(() {
            selectedPhoneRegionCode = value!;
          });
        },
        decoration: const InputDecoration(hintText: "选择电话区号"),
      ),
      'phoneNumber': TextEditingController(),
      'idType': DropdownButtonFormField<IDType>(
        value: selectedIDType.toString().split('.').last == 'IdentityCard'
            ? IDType.identityCard
            : IDType.passport,
        items: IDType.values.map((IDType value) {
          return DropdownMenuItem<IDType>(
            value: value,
            child: Text(value.toString().split('.').last == 'identityCard'
                ? '身份证'
                : '护照'),
          );
        }).toList(),
        onChanged: (value) {
          // 在用户选择新的项时更新 selectedIDType
          setState(() {
            selectedIDType = value!;
          });
        },
        decoration: const InputDecoration(hintText: "选择证件类型"),
      ),
      'idNumber': TextEditingController(),
    };
  }

  Map<String, String> hintTexts = {
    'firstName': '请输入乘客姓',
    'lastName': '请输入乘客名',
    'phoneRegionCode': '请选择手机区号',
    'phoneNumber': '请输入乘客电话',
    'idNumber': '请输入乘客ID',
  };

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.seatLevel.seats?.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.seatLevel.seats![index].seatNumber ?? ''),
              sizedBoxH4,
              Text(
                widget.seatLevel.seats![index].passengerInfo?.name ?? '请添加乘客',
              ),
              sizedBoxH8,
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.add_call),
            onPressed: () {
              _showDialog(context, index);
            },
          ),
        );
      },
    );
  }

  void _showDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PassengerDialog(
          formKey: formKey,
          textEditingControllers: textEditingControllers,
          hintTexts: hintTexts,
          seat: widget.seatLevel.seats![index],
          updateParentState: () {
            setState(() {});
          },
        );
      },
    );
  }
}
