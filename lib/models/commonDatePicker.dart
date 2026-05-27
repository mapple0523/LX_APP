
import 'package:date_format/date_format.dart';
import 'package:dtwms_app/pages/common/commWidget.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'commonTextField.dart';

class CommonDatePicker extends StatefulWidget {

  @override
  _CommonDatePicker createState() => _CommonDatePicker();

  TextEditingController selConroller;
  final bool clearEnabled;
  final dynamic onEditingComplete;
  double width;

  CommonDatePicker(
      {
         this.selConroller
         , this.clearEnabled = true
         , this.onEditingComplete
         , this.width
      }
  );
}

class _CommonDatePicker extends State<CommonDatePicker>  {
  DateTime _dateTime = DateTime.now();
  FocusNode fnOne = FocusNode();
  
  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  delayKeyboardHide() {
    Future.delayed(
        const Duration(milliseconds: 10),
        () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        }
    );
  }

  _callDatePicker() {
    Future<DateTime> selectedDate = commonDatePicker(context, _dateTime);
    selectedDate.then((dateTime) {
      setState(() {
        if(!CommonUtil.isEmpty(dateTime)) {
          widget.selConroller.text = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
          if(!CommonUtil.isEmpty(widget.onEditingComplete)) {
            widget.onEditingComplete(widget.selConroller.text);
          }
        }
      });
    });

    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
  
  @override
  Widget build(BuildContext context) {
    //delayKeyboardHide();
    if(!CommonUtil.isNull(widget.selConroller.text)) {
      _dateTime = CommonUtil.getDateFormStr(widget.selConroller.text);
    }
    
    return Container(
        child: Row(
          children: [
            CommonTextField(widget.selConroller
              , width : CommonUtil.isEmpty(widget.width)?MediaQuery.of(context).size.width * 0.72 - 50 : widget.width - 50
              , clearEnabled: widget.clearEnabled
              , enabled: widget.clearEnabled
              , bkColor: Colors.white
              , readeOnly: true
              , onTap: () {
                //delayKeyboardHide();
                if(widget.clearEnabled) {
                  CommonUtil.selectAll(widget.selConroller);
                } else {
                  _callDatePicker();
                }
              },
            ),
            IconButton(padding:EdgeInsets.only(left: 5), constraints: BoxConstraints(), icon: Icon(Icons.calendar_today)
                , onPressed: (){
                  _callDatePicker();
                }
            )
          ],
        ),
    );
  }
}