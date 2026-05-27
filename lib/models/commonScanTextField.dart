import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonScanTextField extends StatefulWidget {

  @override
  _CommonScanTextField createState() => _CommonScanTextField();

  final double width;
  final double height;
  final String labelText;
  final bool enabled;
  final bool keyboardEnabled;
  final bool autofocus;
  final TextAlign textAlign;
  final bool obscureText;
  final double paddingLeft;
  final double paddingRight;
  final double paddingTop;
  final double paddingBottom;
  final TextInputType keyboardType;
  final TextEditingController textController;
  final String scanType;
  final bool selectAllFlag;

  bool iconClearFlag;
  FocusNode focusNode;
  dynamic inputFormatters;
  Color bkColor;

  //event 선언부
  final dynamic refresh;
  final dynamic onEditingComplete ;
  final dynamic onSubmitted ;
  final dynamic onTap;
  final dynamic onChanged ;

  bool selectScanReadOnly;

  CommonScanTextField(this.textController,
      {
        this.width
        , this.height
        , this.labelText
        , this.enabled = true
        , this.keyboardEnabled = true
        , this.autofocus = false
        , this.bkColor
        , this.textAlign = TextAlign.left
        , this.obscureText = false
        , this.focusNode
        , this.paddingLeft = 0
        , this.paddingRight = 0
        , this.paddingTop = 2
        , this.paddingBottom = 0
        , this.iconClearFlag = false
        , this.keyboardType = TextInputType.text
        , this.refresh
        , this.onEditingComplete
        , this.onSubmitted
        , this.onTap
        , this.onChanged
        , this.inputFormatters
        , this.scanType = 'E'
        , this.selectScanReadOnly = true
        , this.selectAllFlag = true
      }
      );
}

class _CommonScanTextField extends State<CommonScanTextField>  {
  bool scanReadOnly = true;
  bool keyboardBtn = false; // true로 변경 (onFocus -> 자동으로 키보드 올라옴)

  @override
  void initState() {
    if(CommonUtil.isEmpty(widget.focusNode)) widget.focusNode = FocusNode();

    widget.focusNode.addListener(() {
      barcodeScanCallback(widget.scanType);

      if(!widget.selectScanReadOnly)
        keyboardBtn = true;

      if(keyboardBtn) {
        scanReadOnly = false;
      } else {
        scanReadOnly = true;
      }

      keyboardBtn = false;

      if(mounted){
        setState(() {});
      }
    });

    super.initState();
  }

  void barcodeScanCallback(String scanType) {
    print("barcodeScanCallback 호출됨 - scanType: $scanType");

    ZebraDataWedgeListener.rtnFnMap[scanType] = (result) {
      print("스캔 결과 받음 - scanType: $scanType, result: $result");

      if(scanType == "CM") {

        if(!CommonUtil.isEmpty(widget.onEditingComplete))
          widget.onEditingComplete(result);
      } else {

        widget.textController.text = "";
        widget.textController.text = result;
        if(!CommonUtil.isEmpty(widget.onEditingComplete))
          widget.onEditingComplete(widget.textController.text);
      }

      };
    }



  @override
  void dispose() {
    if(!CommonUtil.isEmpty( widget.textController))   widget.textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    barcodeScanCallback(widget.scanType);
    double sWidth = CommonUtil.nullObjectDef(widget.width, MediaQuery.of(context).size.width * 0.72 - 15).toDouble();
    double sHeight = CommonUtil.nullObjectDef(widget.height, MediaQuery.of(context).size.height * 0.06).toDouble();

    //키패드 설정.
    if(widget.keyboardType.toJson()['name'] == 'TextInputType.number') {
      widget.inputFormatters = <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];
    }

    //백그라운드 컬러 선언.
    widget.bkColor = widget.enabled ? CommonUtil.nullObjectDef(widget.bkColor, Colors.white)  : CommonUtil.nullObjectDef(widget.bkColor, Colors.black12);

    if(widget.textController.text.length > 0 && widget.focusNode.hasFocus) {
      widget.iconClearFlag = true;
    } else {
      widget.iconClearFlag = false;
    }

    if(keyboardBtn) {
      scanReadOnly = false;
    }

    return Padding(
      padding: EdgeInsets.only(left: widget.paddingLeft, right: widget.paddingRight, bottom: widget.paddingBottom, top: widget.paddingTop),
      child: Container(
          width: sWidth,
          height: sHeight,
          //color: widget.bkColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: widget.keyboardEnabled ? sWidth - 35 : sWidth,
                child: TextField(
                    textInputAction : TextInputAction.done
                    , controller: widget.textController
                    , enabled: widget.enabled
                    , textAlign: widget.textAlign
                    , autofocus: widget.autofocus
                    , autocorrect: false
                    , focusNode: widget.focusNode
                    , keyboardType: widget.keyboardType
                    , inputFormatters: widget.inputFormatters
                    , obscureText: widget.obscureText
                    , showCursor: true
                    , cursorColor: Color.fromRGBO(254, 169, 21, 1)
                    //, scrollPadding: EdgeInsets.fromLTRB(0, 0, 0, 60)
                    , readOnly: this.scanReadOnly
                    , decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 10, left: 5),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromRGBO(254, 169, 21, 1), width: 2),
                    ),
                    border: OutlineInputBorder(),
                    labelText: widget.labelText,
                    suffixIcon : widget.iconClearFlag ? IconButton(padding: EdgeInsets.zero ,icon: Icon(Icons.clear), onPressed: (){widget.textController.clear();widget.textController.text='';}) : null
                )
                    , onChanged: (value) {
                  if(!CommonUtil.isEmpty(widget.onChanged))
                    widget.onChanged(value);
                }
                    , onEditingComplete : () {
                  setState(() {
                    this.scanReadOnly = true;
                    if(!widget.selectScanReadOnly) {
                      this.keyboardBtn = true;
                    }else{
                    }

                  });

                  if(!CommonUtil.isEmpty(widget.onEditingComplete))
                    widget.onEditingComplete(widget.textController.text);
                }
                    , onSubmitted: (value) {
                  this.scanReadOnly = true;
                  if(!CommonUtil.isEmpty(widget.onSubmitted))
                    widget.onSubmitted(value);

                  if(!widget.selectScanReadOnly) {
                    this.keyboardBtn = true;
                  }else{
                  }
                }
                    , onTap: () {
                  setState(() {
                    if(widget.selectAllFlag){
                      CommonUtil.selectAll(widget.textController);
                    }
                    if(!widget.selectScanReadOnly) {
                      this.keyboardBtn = true;
                    }else{
                    }
                    //CommonUtil.selectAll(widget.textController);
                    /*if(widget.selectScanReadOnly){
                          this.scanReadOnly = false;
                        }
                        else{
                          this.scanReadOnly = true;
                        }*/
                  });

                  if(!CommonUtil.isEmpty(widget.onTap))
                    widget.onTap();
                }
                ),
              ),
              if(widget.keyboardEnabled)
                Align(
                    alignment: Alignment.center,
                    child: IconButton( padding:EdgeInsets.only(left: 5), constraints: BoxConstraints(), icon: Icon(Icons.keyboard)
                        , onPressed: (){
                          setState(() {
                            this.scanReadOnly = false;
                            this.keyboardBtn = true;
                          });

                          widget.focusNode.requestFocus();
                          // SystemChannels.textInput.invokeMethod('TextInput.show');
                        }
                    )
                )
            ],
          )
      ),
    );
  }
}