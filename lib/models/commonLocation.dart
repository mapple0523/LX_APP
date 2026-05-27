
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commWidget.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'commonScanTextField.dart';

class CommonLocation extends StatefulWidget {

  @override
  _CommonLocation createState() => _CommonLocation();

  final FocusNode focusNode;
  final TextEditingController selLocVal;
  final dynamic param;

  final dynamic onTap;
  double width;
  dynamic onEditingComplete;

  CommonLocation(
      {
        this.focusNode
        , this.selLocVal
        , this.onEditingComplete
        , this.param = const {}
        , this.onTap
        , this.width
      }
  );
}

class _CommonLocation extends State<CommonLocation>  {

  @override
  void initState() {
    //ZebraDataWedgeListener.initFunc();

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _callLocationPopup() {
    Future<dynamic> result = navigateLocationSelection(context, widget.param);
    result.then((data)  {
      if(!CommonUtil.isEmpty(data)) {
        setState(() {
          widget.selLocVal.text = data["LOCATION_CD"];

          if(!CommonUtil.isEmpty(widget.onEditingComplete)) {
            widget.onEditingComplete(widget.selLocVal.text);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //ZebraDataWedgeListener.initFunc();
    return Container(
        child: Row(
          children: [
            // new CommonScanTextField(widget.selLocVal,
            //     focusNode : widget.focusNode
            //     , iconClearFlag: true
            //     , keyboardEnabled : false
            //     , selectScanReadOnly : false
            //     , width : MediaQuery.of(context).size.width * 0.72 - 50
            //     , height: MediaQuery.of(context).size.height * 0.06
            //     , scanType: "WL"
            //     , onEditingComplete: ([result]) {
            //       if(!CommonUtil.isEmpty(widget.onEditingComplete)) {
            //         widget.onEditingComplete(widget.selLocVal.text);
            //       }
            //     }
            //     , onTap: () {
            //       if (!CommonUtil.isEmpty(widget.onTap)) widget.onTap();
            //     }),
            CommonTextField(
                widget.selLocVal,
                width: CommonUtil.isEmpty(widget.width)?MediaQuery.of(context).size.width * 0.72 - 50:widget.width-50,
                height: MediaQuery.of(context).size.height * 0.06,
                onEditingComplete: (result) {
                  if (!CommonUtil.isEmpty(widget.onEditingComplete)) {
                    widget.onEditingComplete(widget.selLocVal.text);
                  }
                },
                onTap: () {
                  if (!CommonUtil.isEmpty(widget.onTap)) widget.onTap();
                }
            ),
            IconButton(padding:EdgeInsets.only(left: 5), constraints: BoxConstraints(), icon: Icon(Icons.search)
                , onPressed: () {
                    _callLocationPopup();
                  }
            )
          ],
        ),
    );
  }
}