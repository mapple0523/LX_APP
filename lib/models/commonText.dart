import 'package:dtwms_app/pages/sys/Language_constants.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';


class CommonText extends StatelessWidget {
  final String text;
  double width;
  double height;
  final Color bkColor;
  final Color textColor;
  final FontWeight fontWeight;
  final double paddingLeft;
  final double paddingRight;
  final double paddingTop;
  final double paddingBottom;
  final int maxLines;

  CommonText(this.text,
      {
        this.width
        , this.height
        , this.bkColor = Colors.blueGrey
        , this.textColor = Colors.black
        , this.fontWeight = FontWeight.bold
        , this.paddingLeft = 5
        , this.paddingRight = 5
        , this.paddingBottom = 0
        , this.paddingTop = 2
        , this.maxLines = 1
      }
      );
  @override
  Widget build(BuildContext context) {
    this.width = CommonUtil.nullObjectDef(this.width, MediaQuery.of(context).size.width * 0.28).toDouble();
    this.height = CommonUtil.nullObjectDef(this.height, MediaQuery.of(context).size.height * 0.06).toDouble();
    return Padding(
      padding: EdgeInsets.only(left: this.paddingLeft, right:  this.paddingRight, top: this.paddingTop, bottom: this.paddingBottom),
      child: Container(
        color: Color.fromRGBO(217, 217, 217, 1),
        width: this.width,
        height: this.maxLines == 2 ? 50 : this.height,
        padding: EdgeInsets.only(left: 5),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(getTranslated(context,this.text),
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: 15,
                color: textColor,
                fontWeight: this.fontWeight
            ),
          ),
        ),
      ),
    );
  }

}