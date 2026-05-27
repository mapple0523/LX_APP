import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CommonDropdown extends StatelessWidget {
  final String id;
  final dynamic selVal;
  List<dynamic> dataList;
  final double width;
  final double height;
  final bool enabled;
  final double paddingLeft;
  final double paddingRight;
  final double paddingTop;
  final double paddingBottom;
  final String viewType; // C : CODE, N(default): NAME, CN : CODE+NAME

  //이벤트 선언
  final dynamic fnCallback;

  final Color decoColor;
  final textColor;
  final dropdownColor;

  CommonDropdown(this.id, this.selVal, this.dataList, this.fnCallback,
      {
        this.width
        , this.height
        , this.enabled = true
        , this.paddingTop = 2
        , this.paddingBottom = 0
        , this.paddingRight = 0
        , this.paddingLeft = 0
        , this.decoColor = Colors.white
        , this.textColor = Colors.black
        , this.dropdownColor = Colors.black54
        , this.viewType = "N"
      }
  );

  @override
  Widget build(BuildContext context) {
    double vHeight = CommonUtil.nullObjectDef(this.height, MediaQuery.of(context).size.height * 0.06).toDouble();
    double vWidth = CommonUtil.nullObjectDef(this.width, MediaQuery.of(context).size.width * 0.72 - 15).toDouble();
    return Container(
        height: vHeight,
        width: vWidth,
        padding: EdgeInsets.only(left: this.paddingLeft, right: this.paddingRight, bottom: this.paddingBottom, top: this.paddingTop),
        //padding: EdgeInsets.only(right: 50),
        decoration: BoxDecoration(
            color: this.decoColor,
            //borderRadius: BorderRadius.all( Radius.circular(5)),
            border: Border.all(color: Colors.black12)
          /* border : Border(
              bottom: BorderSide(color: Colors.black)
          )*/
        ),
        child:  DropdownButtonHideUnderline(
          child: IgnorePointer(
            ignoring: !this.enabled,
            child: DropdownButton(
              dropdownColor:  this.dropdownColor,
              value: this.selVal,
              icon: Icon(Icons.arrow_drop_down, color: Colors.black),
              //isDense: true,
              isExpanded: true,
              menuMaxHeight: 400,
              itemHeight: 75,
              style: TextStyle(fontSize: 15, color: Colors.white),
              selectedItemBuilder: (BuildContext context) {
                return this.dataList.map((e) {
                  return Center( child: Text((viewType == "N")?e["NAME"]:e["CODE"],  style: TextStyle(fontSize: 15, color: this.textColor)));
                }).toList();
              },
              items: this.dataList.map((e) {
                return DropdownMenuItem<dynamic>(
                    value: e["CODE"],
                    child: Center(
                        child: Text(_getViewValue(e["CODE"],e["NAME"]), overflow: TextOverflow.visible, textAlign: TextAlign.left,)
                    )
                );
              }).toList(),
              onChanged: (value) {
                Map chkMap = CommonUtil.findMapFromList(this.dataList, "CODE", value);
                dynamic code = "";
                dynamic name = "";
                if(!CommonUtil.isEmpty(chkMap)) {
                  code = chkMap["CODE"];
                  name = chkMap["NAME"];
                }

                if(!CommonUtil.isEmpty(this.fnCallback))
                    this.fnCallback(id, code, name);
              },
            ),
          ),
        )
    );
  }

  String _getViewValue(code, name){
    if(viewType == "N"){ return name.toString(); }
    else if(viewType == "C"){return code.toString();}
    else if(viewType == "CN"){return "[${code.toString()}] ${name.toString()}";}
    else{return name.toString();}
  }

}