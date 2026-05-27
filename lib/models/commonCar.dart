import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commCarInfo.dart';
import 'package:dtwms_app/pages/common/commMatlInfo.dart';
import 'package:dtwms_app/pages/common/commWidget.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'commonScanTextField.dart';

class CommonCar extends StatefulWidget {
  final FocusNode focusNode;
  final TextEditingController selCarVal;
  final dynamic param;
  final dynamic onTap;
  dynamic onEditingComplete;

  CommonCar({
    this.focusNode,
    this.selCarVal,
    this.onEditingComplete,
    this.param = const {},
    this.onTap,
  });

  @override
  _CommonCar createState() => _CommonCar();
}

class _CommonCar extends State<CommonCar> {

  @override
  void initState() {
    ZebraDataWedgeListener.initFunc();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 초기화 후 실행할 코드가 있다면 여기에
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _callMaterialPopup() {
    if (widget.focusNode != null && widget.focusNode.hasFocus) {
      widget.focusNode.unfocus();
    }

    Future.delayed(Duration(milliseconds: 100), () {
      dynamic currentParam = widget.param;
      if (widget.param is Function) {
        currentParam = widget.param();
      }

      Future<dynamic> result = _movePageSelection(context, currentParam);
      result.then((data) {
        if (!CommonUtil.isEmpty(data) && data is List) {
          if (data.isNotEmpty && data[0]['VEHICLE_NO'] != null) {
            setState(() {
              widget.selCarVal.text = data[0]['VEHICLE_NO'].toString();

              if (!CommonUtil.isEmpty(widget.onEditingComplete)) {
                widget.onEditingComplete(data[0]);
              }
            });
          }
        }
      });
    });
  }

  // Material 선택 페이지로 이동
  Future<dynamic> _movePageSelection(BuildContext context, [dynamic param]) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => CarInfoPage(param: param)
        )
    );

    if (!CommonUtil.isEmpty(result) && result is List) {
      return result;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Container(
      child: Row(
        children: [
          // CommonScanTextField(
          //     widget.selCarVal,
          //     focusNode: widget.focusNode,
          //     iconClearFlag: true,
          //     keyboardEnabled: false,
          //     selectScanReadOnly: false,
          //     width: MediaQuery.of(context).size.width * 0.7 - 45,
          //     height: MediaQuery.of(context).size.height * 0.06,
          //     scanType: "WM",
          //     onEditingComplete: (result) {
          //       if (!CommonUtil.isEmpty(widget.onEditingComplete)) {
          //         widget.onEditingComplete(widget.selCarVal.text);
          //       }
          //     },
          //     onTap: () {
          //       if (!CommonUtil.isEmpty(widget.onTap)) widget.onTap();
          //     }
          // ),
          CommonTextField(
              widget.selCarVal,
              width: MediaQuery.of(context).size.width * 0.7 - 45,
              height: MediaQuery.of(context).size.height * 0.06,
              onEditingComplete: (result) {
                if (!CommonUtil.isEmpty(widget.onEditingComplete)) {
                  widget.onEditingComplete(widget.selCarVal.text);
                }
              },
              onTap: () {
                if (!CommonUtil.isEmpty(widget.onTap)) widget.onTap();
              }
          ),
          IconButton(
              padding: EdgeInsets.only(left: 5),
              constraints: BoxConstraints(),
              icon: Icon(Icons.search),
              onPressed: () {
                _callMaterialPopup();
              }
          )
        ],
      ),
    );
  }
}