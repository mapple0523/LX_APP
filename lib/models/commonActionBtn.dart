import 'package:dtwms_app/pages/sys/Language_constants.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CommonActionBtn extends StatelessWidget {
  final String text;
  final double height;
  final double width;
  double fontSize;
  final dynamic onPressed;
  double borderRadius;
  double padding;
  bool disabledBtn;

  CommonActionBtn(this.text,
      {
        this.height
        , this.width
        , this.fontSize = 20
        , this.onPressed
        , this.borderRadius = 10
        , this.padding = 5
        , this.disabledBtn = false
      }
      );

  @override
  Widget build(BuildContext context) {
    double sWidth = CommonUtil.nullObjectDef(this.width, MediaQuery.of(context).size.width - 10).toDouble();
    double sHeight = CommonUtil.nullObjectDef(this.height, 50).toDouble();

    return Container(
        child: Padding(
          padding: EdgeInsets.all(this.padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(
                height: sHeight,
                width: sWidth,
                child: ElevatedButton(
                  child: Text(getTranslated(context, this.text)),
                  style : ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder( // 모서리 둥글게
                      borderRadius: BorderRadius.circular(this.borderRadius),
                    ),
                    textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: this.fontSize),
                    primary: disabledBtn ? Colors.transparent : Color.fromRGBO(254, 169, 21, 1),
                  ),
                  //style: TextStyle(fontWeight: FontWeight.bold, fontSize: this.fontSize),
                  onPressed: () {
                    if(!CommonUtil.isEmpty(this.onPressed))
                      this.onPressed();
                  },
                ),
              )
            ],
          ),
        )
    );
  }

}