import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ticket_app/common/app_styles.dart';
import 'package:ticket_app/model/passenger_info.dart';
import 'package:ticket_app/model/train_info.dart';
import 'package:ticket_app/topvars.dart';
import 'package:ticket_app/widgets/normal_button.dart';
import 'package:ticket_app/widgets/ticket_widgets/ticket_check_widget.dart';

class PassengerDialog extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> textEditingControllers;
  final Map<String, String> hintTexts;
  final Seat seat;
  final VoidCallback updateParentState;

  const PassengerDialog({
    super.key,
    required this.formKey,
    required this.textEditingControllers,
    required this.hintTexts,
    required this.seat,
    required this.updateParentState,
  });

  @override
  State<PassengerDialog> createState() => _PassengerDialogState();
}

class _PassengerDialogState extends State<PassengerDialog> {
  File? _imageFile;
  final picker = ImagePicker();
  bool _pickingImage = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加乘客'),
      content: SingleChildScrollView(
        child: Form(
          key: widget.formKey,
          child: ListBody(children: [
            ...widget.textEditingControllers.entries.map((entry) {
              if (entry.value is TextEditingController) {
                return TextFormField(
                  controller: entry.value as TextEditingController,
                  decoration:
                      InputDecoration(hintText: widget.hintTexts[entry.key]),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '该项为必填项';
                    }
                    return null;
                  },
                );
              } else {
                return entry.value;
              }
            }).toList(),
            sizedBoxH24,
            GestureDetector(
              onTap: () {
                getImage();
              },
              child: Container(
                width: 200,
                height: 200,
                color: AppStyles.themeBackground,
                child: _imageFile == null
                    ? const Center(child: Text('拍照'))
                    : Image.file(_imageFile!),
              ),
            ),
          ]),
        ),
      ),
      actions: <Widget>[
        NormalButton(
          text: Text(
            "取消",
            style: textStyle16.copyWith(color: const Color(0xFF7DAB91)),
          ),
          backgroundColor: const Color(0xFFF5F9F7),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        NormalButton(
          text: Text(
            "确定",
            style: textStyle16.copyWith(color: Colors.white),
          ),
          backgroundColor: AppStyles.themeColor,
          onPressed: () async {
            if (!widget.formKey.currentState!.validate()) {
              return;
            }

            // 在 async 调用之前保存需要的上下文相关的值
            var ticketCheckWidgetState =
                context.findAncestorStateOfType<TicketCheckWidgetState>();
            var phoneRegionCode =
                ticketCheckWidgetState?.selectedPhoneRegionCode ?? '';
            var idType =
                ticketCheckWidgetState?.selectedIDType ?? IDType.identityCard;

            // 创建新的 PassengerInfo 并赋值
            widget.seat.passengerInfo = PassengerInfo(
                firstName: widget.textEditingControllers['firstName']!.text,
                lastName: widget.textEditingControllers['lastName']!.text,
                phoneRegionCode: phoneRegionCode,
                phoneNumber: widget.textEditingControllers['phoneNumber']!.text,
                idType: idType,
                idNumber: widget.textEditingControllers['idNumber']!.text,
                base64Image: await imageToBase64());

            // 更新 UI
            widget.updateParentState();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<void> getImage() async {
    if (_pickingImage) {
      // 如果正在进行pickImage操作，直接返回
      return;
    }

    _pickingImage = true;
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera).catchError((error) {

    }).whenComplete(() {
      // 不论成功还是失败，最后都将_pickingImage设置为false
      _pickingImage = false;
    });

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      if (kDebugMode) {
        print('No image selected.');
      }
    }
  }

  Future<String> imageToBase64() async {
    if (_imageFile == null) {
      return '';
    }
    Uint8List? imageBytes = await _imageFile?.readAsBytes();
    String base64Image = base64Encode(imageBytes as List<int>);
    return base64Image;
  }
}
