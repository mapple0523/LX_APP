import 'package:flutter/material.dart';


class CommonSmallText extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final Color bkColor;
  final Color textColor;
  final FontWeight fontWeight;
  final double paddingLeft;
  final double paddingRight;
  final double paddingTop;
  final double paddingBottom;

  CommonSmallText(this.text,
      {
        this.width = 90
        , this.height = 40
        , this.bkColor = Colors.blueGrey
        , this.textColor = Colors.black
        , this.fontWeight = FontWeight.bold
        , this.paddingLeft = 5
        , this.paddingRight = 5
        , this.paddingBottom = 0
        , this.paddingTop = 2
      }
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: this.paddingLeft, right:  this.paddingRight, top: this.paddingTop, bottom: this.paddingBottom),
      child: Container(
        color: Color.fromRGBO(217, 217, 217, 1),
        width: this.width,
        height: this.height,
        child: Align(
          alignment: Alignment.center,
          child: Text(this.text,
            textAlign: TextAlign.center,
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