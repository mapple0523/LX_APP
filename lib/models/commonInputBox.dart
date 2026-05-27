
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commWidget.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'commonScanTextField.dart';

class CommonInputBox extends StatefulWidget {

  @override
  _CommonInputBox createState() => _CommonInputBox();

  final FocusNode focusNode;
  final TextEditingController textValue;
  final dynamic param;

  dynamic onEditingComplete;

  CommonInputBox(
      {
        this.focusNode
        , this.textValue
        , this.onEditingComplete
        , this.param = const {}
      }
      );
}

class _CommonInputBox extends State<CommonInputBox>  {

  @override
  void initState() {
    ZebraDataWedgeListener.initFunc();

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

    });
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Container(
      child: Row(
        children: [
          new CommonScanTextField(widget.textValue
            , focusNode : widget.focusNode
            , keyboardEnabled : false
            , width : 85
            , height: 40
            , onEditingComplete: ([result]) {
              if(!CommonUtil.isEmpty(widget.onEditingComplete)) {
                widget.onEditingComplete(widget.textValue.text);
              }
            },
          ),
        ],
      ),
    );
  }
}