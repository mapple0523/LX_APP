import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonKeyboardAction.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/textMaker.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class STK0003MP02 extends StatefulWidget {

  const STK0003MP02({Key key, this.param}) : super(key: key);
  final dynamic param;
  @override
  _STK0003MP02 createState() => _STK0003MP02();
}

class _STK0003MP02 extends State<STK0003MP02> {

  final TextEditingController _selStkQty       = TextEditingController();  // 재고조정 수량
  final TextEditingController _selExpReason    = TextEditingController();  // 재고조정 사유

  //detail search list
  List<dynamic> _dtlSearch = [{}];
  //포커스 노드
  FocusNode fnOne;
  FocusNode fnTwo;

  Future<List<dynamic>> _dtlsearch(BuildContext context, Map<String, dynamic> param) async {

    Map<String, dynamic> paramMap = {
      "STOCK_CHECK_ID" : widget.param["STOCK_CHECK_ID"],
      "SHPR_ITEM_CD" : widget.param["SHPR_ITEM_CD"],
      "LOCATION_CD"  : widget.param["LOCATION_CD"],
      "STOCK_SEQ"    : widget.param["STOCK_SEQ"]
    };

    List<dynamic> rtnList =
    await transaction(context, "/stk0003/dtlsearch.do", paramMap);

    if(CommonUtil.isEmpty(_dtlSearch))
      _dtlSearch = [];
    else
      _dtlSearch = rtnList;

    if(_dtlSearch[0]['CHECK_QTY'] == 0)
      _selStkQty.text = "";
    else {
      _selStkQty.text =
          CommonUtil.nullStrDef(_dtlSearch[0]['CHECK_QTY'].toString());
      _selStkQty.selection =
          TextSelection(baseOffset: 0, extentOffset: _selStkQty.text.length,);
    }

    _selExpReason.text = CommonUtil.nullStrDef(_dtlSearch[0]['MEMO'].toString());

    return rtnList;
  }

  _SaveQty() async {
    Map<String, dynamic> paramMap = {
      "STOCK_CHECK_ID" : widget.param["STOCK_CHECK_ID"],
      "SHPR_CD" : widget.param["SHPR_CD"],
      "SHPR_ITEM_CD" : widget.param["SHPR_ITEM_CD"],
      "LOCATION_CD"  : widget.param["LOCATION_CD"],
      "STOCK_SEQ"    : widget.param["STOCK_SEQ"],
      "CHECK_QTY"    : _selStkQty.text,
      "STOCK_QTY"    : widget.param["STOCK_QTY"],
      "BIZ_CD"       : widget.param["BIZ_CD"],
      "RMK"          : _selExpReason.text

    };

   if(CommonUtil.isNull(_selStkQty.text))
    {
      showInfoAlert(context,'재고조정 수량을 입력하세요');
    }
   else {
      await transaction(context, "/stk0003/saveList.do", paramMap,(status, data) {
        if(status == Constant.resSuccessCode) {
          Navigator.pop(context,true);
          showInfoAlert(context,'재고저장 완료.');
        }
      });
    }
    setState(() {});
  }

  _UpdateQty() async {
    Map<String, dynamic> paramMap = {
      "STOCK_CHECK_ID" : widget.param["STOCK_CHECK_ID"],
      "SHPR_CD" : widget.param["SHPR_CD"],
      "SHPR_ITEM_CD" : widget.param["SHPR_ITEM_CD"],
      "LOCATION_CD"  : widget.param["LOCATION_CD"],
      "STOCK_SEQ"    : widget.param["STOCK_SEQ"],
      "CHECK_QTY"    : _selStkQty.text,
      "STOCK_QTY"    : widget.param["STOCK_QTY"],
      "BIZ_CD"       : widget.param["BIZ_CD"],
      "RMK"          : _selExpReason.text
    };
    if(CommonUtil.isNull(_selStkQty.text))
    {
      showInfoAlert(context,'재고조정 수량을 입력하세요');
    }
    else {
      await transaction(context, "/stk0003/updateList.do", paramMap,(status, data) {
        if(status == Constant.resSuccessCode) {
          Navigator.pop(context,true);
          showInfoAlert(context,'재고반영 완료.');
        }
      });
    }

    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();

    fnOne = FocusNode();
    fnTwo = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _dtlsearch(context,widget.param).then((data) =>  setState(() {
          _dtlSearch = data;
          if(CommonUtil.isEmpty(_dtlSearch))
            _dtlSearch = [];
          else
            _dtlSearch = data;
        }))
    );
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
        appBar: pageAppBar(context, "재고상세 및 재고조정", true),
        body:FooterLayout(
            footer: SizedBox(
              height: 140,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  CommonActionBtn("재고저장",
                      onPressed : _SaveQty
                  ),
                  CommonActionBtn("재고반영",
                      onPressed : _UpdateQty
                  ),
                ],
              ),
            ),
          child: SingleChildScrollView(
          child: GestureDetector(
          onTap: (){
          CommonUtil.hideKeyboard();
          },
          child: Container(
            height : CommonUtil.pageMaxHeight(context,100),
            child: Column(
            children: <Widget> [
              Expanded(
                child: Column(
                  children: [
                    Row(children: <Widget>[_searchField(_dtlSearch),]),
                    Row(children: <Widget>[_stockUpdate(),]),
                  ],
                ),
              ),
            ],
            ),
          )
        )
        )
    )
    );
  }

  Widget _searchField(List<dynamic> list) {
    return Expanded (
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("화주"),
              CommonTextField(list[0]['SHPR_NM'],
                  enabled : false,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("품목"),
              CommonTextField(list[0]['SHPR_ITEM_NM'],
                  enabled : false,
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("재고수량"),
              CommonTextField(CommonUtil.nullStrDef(list[0]['STOCK_QTY'].toString()),
                  enabled : false,
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("조정수량"),
              CommonTextField(CommonUtil.nullStrDef(list[0]['CHECK_QTY'].toString()),
                  enabled : false,
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("차이수량"),
              CommonTextField(CommonUtil.nullStrDef(list[0]['DIF_QTY'].toString()),
                  enabled : false,
              )
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
              CommonText("재고조정 수량"),
              CommonTextField(_selStkQty,
                    focusNode : fnOne,
                    keyboardType : TextInputType.number,
                    onEditingComplete : (nodeObj) {
                      CommonUtil.hideKeyboard();
                    },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("재고조사 사유"),
              CommonTextField(_selExpReason,
                    autofocus : false,
                    focusNode : fnTwo,
                    onEditingComplete : (nodeObj) {
                      CommonUtil.hideKeyboard();
                      //update controller 추가해야함.
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