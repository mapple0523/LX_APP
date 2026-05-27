import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';


class STK0006MP05 extends StatefulWidget {

  const STK0006MP05({Key key, this.param}) : super(key: key);
  final dynamic param;
  @override
  _STK0006MP05 createState() => _STK0006MP05();
}

class _STK0006MP05 extends State<STK0006MP05> {
  final TextEditingController _selPackQty       = TextEditingController();

  FocusNode fnOne;
  FocusNode fnTwo;

  save() async{

    if(CommonUtil.isNull(_selPackQty.text)){
      showInfoAlert(context, ("패킹수량을 입력하세요."));
    }
    else {
      if (int.parse(_selPackQty.text) > widget.param["BOX_AVAIL_QTY"]) {
        showInfoAlert(context, '패킹가능수량을 초과할 수 없습니다.');
        return;
      }
      else {
        Navigator.pop(context, {
          'UNIQUE_KEY': widget.param["UNIQUE_KEY"],
          'PALLET_QTY': _selPackQty.text,
        });
        showInfoAlert(context, '패킹수량 변경 완료.');
      }
    }
  }

  @override
  void initState() {
    fnOne = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var color = 0xff453658;
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset : true,
        appBar: pageAppBar(context, "Pallet패킹", false),
        body: FooterLayout(
            footer: CommonActionBtn("확  인",
                onPressed : () {
                  save();
                }
            ),
            child: SingleChildScrollView(
                child: GestureDetector(
                    onTap: (){
                      CommonUtil.hideKeyboard();
                    },
                    child: Container(
                      height : CommonUtil.pageMaxHeight(context),
                      child: Column(
                        children: <Widget> [
                          Expanded(
                              child: Column(
                                  children : <Widget>[
                                    Row(children: <Widget>[_searchField(),]),
                                    Row(children: <Widget>[_stockUpdate(),]),
                                  ]
                              )
                          ),
                        ],
                      ),
                    )
                )
            )
        )
    );
  }

  Widget _searchField() {
    return Expanded (
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("PLANT", width:78),
              CommonTextField(widget.param['PLANT'], width:90, enabled : false
              ),
              CommonText("S.Loc",width: 78,
              ),
              CommonTextField(widget.param['SLOC'], width: 90, enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("오더생성일자"),
              CommonTextField(widget.param['ORDER_C_DATE'],
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("출고예정일자"),
              CommonTextField(widget.param['OUT_CONF_DATE'],
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("Material"),
              CommonTextField(widget.param['PLT_NM'],
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("Desc."),
              CommonTextField(widget.param['ITEM_DESC'],
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("단위", width:78),
              CommonTextField(widget.param['ITEM_UNIT'],
                  width:90,
                  enabled : false
              ),
              CommonText("등급",width: 78,
              ),
              CommonTextField(widget.param['GRADE'], width: 90, enabled: false),
              /*CommonText("규격",width: 78,
              ),
              CommonTextField(widget.param['ITEM_STD'], width: 90, enabled: false),*/
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("배송처"),
              CommonTextField(widget.param['ADDR_NM'],
                  enabled : false
              ),
            ],
          ),
         /* Row(
            children: <Widget>[
              CommonText("출고수량"),
              CommonTextField(widget.param['PICK_QTY'],
                  enabled : false
              ),
            ],
          ),*/
          Row(
            children: <Widget>[
              CommonText("패킹가능수량"),
              CommonTextField(widget.param['BOX_AVAIL_QTY'],
                  enabled : false
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stockUpdate() {
    return Expanded (
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("패킹수량"),
              CommonTextField(_selPackQty,
                  autofocus : false,
                  focusNode : fnOne,
                  keyboardType : TextInputType.number,
                  onEditingComplete : (nodeObj) {
                    CommonUtil.hideKeyboard();
                  }
              ),
            ],
          ),
        ],
      ),
    );
  }
}
