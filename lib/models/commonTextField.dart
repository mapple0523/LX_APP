import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// ignore: must_be_immutable
class CommonTextField extends StatefulWidget {
  @override
  _CommonTextField createState() => _CommonTextField();

  final double width;
  final double height;
  final double bottom;
  final String labelText;
  final bool enabled;
  final bool autofocus;
  final TextAlign textAlign;
  final bool obscureText;
  final double paddingLeft;
  final double paddingRight;
  final double paddingTop;
  final double paddingBottom;
  final TextInputType keyboardType;
  final dynamic textObj;
  final bool keyboardEnable;
  final bool clearEnabled;
  final bool autoSelected;
  final int maxLines;

  bool readeOnly;
  bool iconClearFlag;
  FocusNode focusNode;
  TextEditingController textController;
  dynamic inputFormatters;
  Color bkColor;

  //event 선언부
  final dynamic refresh;
  final dynamic onEditingComplete ;
  final dynamic onSubmitted ;
  final dynamic onTap;
  final dynamic onChanged ;


  CommonTextField(this.textObj,
      {
        this.width
        , this.height
        , this.labelText
        , this.enabled = true
        , this.autofocus = false
        , this.bkColor
        , this.textAlign = TextAlign.center
        , this.obscureText = false
        , this.focusNode
        , this.paddingLeft = 0
        , this.paddingRight = 0
        , this.paddingTop = 2
        , this.paddingBottom = 0
        , this.iconClearFlag = false
        , this.keyboardType = TextInputType.text
        , this.textController
        , this.refresh
        , this.onEditingComplete
        , this.onSubmitted
        , this.onTap
        , this.onChanged
        , this.inputFormatters
        , this.keyboardEnable = true
        , this.clearEnabled = true
        , this.autoSelected = false
        , this.readeOnly = false
        , this.bottom = 10
        , this.maxLines = 1
      }
      );
}

class _DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    // 빈값 허용
    if (newValue.text.isEmpty) return newValue;

    // 소수점만 입력 시 허용 (ex: ".")
    if (newValue.text == '.') return newValue;

    // 소수점 두 자리까지 허용
    final regExp = RegExp(r'^\d+\.?\d{0,3}$');

    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}

class _CommonTextField extends State<CommonTextField> {

  @override
  void initState() {
    if(CommonUtil.isEmpty(widget.focusNode)) widget.focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    if(!CommonUtil.isEmpty( widget.textController))   widget.textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = CommonUtil.nullObjectDef(widget.width, MediaQuery.of(context).size.width * 0.72 - 15).toDouble();
    double height = CommonUtil.nullObjectDef(widget.height, MediaQuery.of(context).size.height * 0.06).toDouble();
    //text conroller 선언
    if(widget.textObj is TextEditingController) {
      widget.textController = widget.textObj;
    }
    else {
      widget.textController = TextEditingController();
      widget.textController.text = CommonUtil.getString(widget.textObj);
    }

    //키패드 설정.
    Map<String, dynamic> keyboardJson = widget.keyboardType.toJson();
    String keyboardName = keyboardJson['name'] ?? '';

    if(keyboardName == 'TextInputType.number') {
      if(keyboardJson['decimal'] == true) {
        widget.inputFormatters = <TextInputFormatter>[_DecimalTextInputFormatter()];
      } else {
        widget.inputFormatters = <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];
      }
    }

    //백그라운드 컬러 선언.
    widget.bkColor = widget.enabled ? CommonUtil.nullObjectDef(widget.bkColor, Colors.white)  : CommonUtil.nullObjectDef(widget.bkColor, Colors.grey[200]);

    if(!CommonUtil.isEmpty(widget.refresh))
      widget.refresh();

    if(widget.textController.text.length > 0 && widget.clearEnabled && widget.enabled) {
      widget.iconClearFlag = true;
    } else {
      widget.iconClearFlag = false;
    }

    if(widget.autoSelected) {
      CommonUtil.selectAll(widget.textController);
    }

    return Padding(
      padding: EdgeInsets.only(left: widget.paddingLeft, right: widget.paddingRight, bottom: widget.paddingBottom, top: widget.paddingTop),
      child: Container(
        width: width,
        height: widget.maxLines == 2 ? 50 : height,
        color: widget.bkColor,

        child: TextField(
          textInputAction: TextInputAction.done,
          controller: widget.textController,
          enabled: widget.enabled,
          //textAlign: widget.maxLines == 2 ? TextAlign.left : widget.textAlign,
          textAlign: TextAlign.left,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          obscureText: widget.obscureText,
          showCursor: true,
          maxLength: 30,
          maxLines: widget.maxLines,
          //scrollPadding: EdgeInsets.fromLTRB(0, 0, 0, 60),
          readOnly: widget.readeOnly,
          cursorColor: Color.fromRGBO(254, 169, 21, 1),
          decoration: InputDecoration(
            //contentPadding: widget.maxLines == null ? EdgeInsets.fromLTRB(8,0,0, widget.bottom) : EdgeInsets.only(bottom: widget.bottom),
            contentPadding:EdgeInsets.only(left: 5),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(254, 169, 21, 1), width: 2),
            ),
            border: OutlineInputBorder(),
            labelText: widget.labelText,
            suffixIcon : widget.iconClearFlag ? IconButton(padding: EdgeInsets.zero ,icon: Icon(Icons.clear), onPressed: (){widget.textController.clear();}) : null,
            counterText: '',
          ),
          onChanged: (value) {
            setState(() { });
            if(!CommonUtil.isEmpty(widget.onChanged))
              widget.onChanged(value);
          },
          onEditingComplete : () {
            if(!CommonUtil.isEmpty(widget.onEditingComplete))
              widget.onEditingComplete(widget.focusNode);
          },
          onSubmitted: (value) {
            if(!CommonUtil.isEmpty(widget.onSubmitted))
              widget.onSubmitted(value);
          },
          onTap: () {
            setState(() { });

            if(!CommonUtil.isEmpty(widget.onTap))
              widget.onTap();
          },

        ),
      ),
    );
  }
}