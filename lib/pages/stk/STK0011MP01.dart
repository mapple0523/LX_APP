
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonGroup.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/restfulReq.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

import '../common/message.dart';

class STK0011MP01 extends StatefulWidget {
  const STK0011MP01({Key key, this.param}) : super(key: key);
  final dynamic param;
  @override
  _STK0011MP01 createState() => _STK0011MP01();
}

class _STK0011MP01 extends State<STK0011MP01> {
  final TextEditingController _selCheckQty = TextEditingController();
  final FocusNode _fnOne = FocusNode();

  @override
  void initState() {
    super.initState();

    int checkQty = CommonUtil.nullObjectDef(widget.param['STOCK_QTY'], 0);

    _selCheckQty.text = CommonUtil.getString(checkQty);

    _selCheckQty.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _selCheckQty.text.length,
    );

    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  _updateCheckQty() async {
    if(CommonUtil.isNull(_selCheckQty.text)) {
      showInfoAlert_pda(context, "chkCheckQty");
      return;
    }

    Map<String, dynamic> paramMap = {
      "CHECK_DATE": widget.param['CHECK_DATE'],
      "LOCATION_CD": widget.param['LOCATION_CD'],
      "SHPR_ITEM_CD": widget.param['SHPR_ITEM_CD'],
      "STOCK_SEQ": widget.param['STOCK_SEQ'],
      "CHECK_QTY": int.parse(_selCheckQty.text)
    };

    await transaction(context, "STK0011/updateCheckQty.do", paramMap,(status, data)
    {
      if (status == Constant.resSuccessCode) {
        Navigator.pop(context, true);
        showInfoAlert_pda(context, "alertCheckCompleted");
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var color = 0xff453658;
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: pageAppBar(context, "stockCheck", true),
        body: FooterLayout(
          footer: CommonActionBtn(
            "btnCheck",
            onPressed: () {
              _updateCheckQty();
            },
          ),
          child: SingleChildScrollView(
              child: GestureDetector(
                onTap: (){
                  CommonUtil.hideKeyboard();
                },
                child: Container(
                  height : CommonUtil.pageMaxHeight(context,-300),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                          child: Column(
                              children: <Widget>[_searchDetailField()]
                          )
                      ),
                    ],
                  ),
                ),
              )
          ),
        )
    );
  }

  Widget _searchDetailField() {
    String itemDesc = widget.param['ITEM_DESC'];
    String trimmedItemDesc = itemDesc.length > 20 ? itemDesc.substring(0, 20) + '...' : itemDesc;

    return Expanded (
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("plant", width:78),
              CommonTextField(widget.param['PLANT'], width:90, enabled : false
              ),
              CommonText("sloc",width: 78,
              ),
              CommonTextField(widget.param['SLOC'], width: 90, enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("inDt"),
              CommonTextField(widget.param['CHECK_DATE_TM'],
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("materialCd"),
              CommonTextField(widget.param['SHPR_ITEM_CD'],
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("lotNo"),
              CommonTextField(widget.param['LOT_NO'],
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("packId"),
              CommonTextField(widget.param['PACK_ID'], enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("desc"),
              CommonTextField(trimmedItemDesc,
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("unit", width:78),
              CommonTextField(widget.param['ITEM_UNIT'],
                  width:90,
                  enabled : false
              ),
              CommonText("grade",width: 78,
              ),
              CommonTextField(widget.param['GRADE'], width: 90, enabled: false),
              /*CommonText("규격",width: 78,
              ),
              CommonTextField(widget.param['ITEM_STD'], width: 90, enabled: false),*/
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("bin"),
              CommonTextField(widget.param['LOCATION_CD'], enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("stockQty"),
              CommonTextField(widget.param['STOCK_QTY'], enabled : false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("checkQty"),
              CommonTextField(_selCheckQty,
                focusNode : _fnOne,
                keyboardType: TextInputType.number,
                onEditingComplete: (nodeObj) {
                CommonUtil.hideKeyboard();
                },
              ),
            ],
          ),

        ],
      ),
    );
  }

}

//common.selectComCodeInfo