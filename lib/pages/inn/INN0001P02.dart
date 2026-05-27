import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';


class INN0001P02 extends StatefulWidget {
  const INN0001P02({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _NN0001P02 createState() => _NN0001P02();
}

class _NN0001P02 extends State<INN0001P02>  {
  DateTime _prodDt                          = DateTime.now();
  DateTime _expireDt                        = DateTime.now();
  final TextEditingController _selInQty     = TextEditingController();
  final TextEditingController _selProdDt    = TextEditingController();
  final TextEditingController _selExpireDt  = TextEditingController();
  String btnName                            = "저 장";

  final FocusNode _fnOne                = FocusNode();

  @override
  void initState() {
    widget.param['ORG_IN_QTY'] = widget.param['IN_QTY'];

    int defInQty = (CommonUtil.nullObjectDef(widget.param['IN_CONF_QTY'], 0) -  CommonUtil.nullObjectDef(widget.param['IN_QTY'], 0));

    _selInQty.text            = (defInQty < 0 ? "0" : defInQty.toString());
    _selProdDt.text           = CommonUtil.getString(widget.param['PROD_DATE']);
    _selExpireDt.text         = CommonUtil.getString(widget.param['EXPIRE_DATE']);

    _selInQty.selection = TextSelection(baseOffset: 0,extentOffset: _selInQty.text.length,);
    btnName = widget.param['UPDATE_TYPE'] == "I" ? "저 장" : "수 정";


    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }


  Future<void> updateItemInfo() async {
    if(CommonUtil.isNull(_selInQty.text) || _selInQty.text == "0") {
      showInfoAlert(context, "입고수량을 입력하세요.");
      return;
    }

    if(!CommonUtil.isNull(_selProdDt.text) && !CommonUtil.isNull(_selExpireDt.text)) {
      if(CommonUtil.getBetweenDt(_selProdDt.text, _selExpireDt.text) < 0) {
        showInfoAlert(context, "유효기간이 제조일자보다 작을수 없습니다.");
        return;
      }
    }

    if(CommonUtil.isNull(_selProdDt.text) && !CommonUtil.isNull(_selExpireDt.text)) {
      _selProdDt.text = CommonUtil.getAddDayStr(_selExpireDt.text,  -1 * widget.param['VALID_DAY']);
    }

    if(!CommonUtil.isNull(_selProdDt.text) && CommonUtil.isNull(_selExpireDt.text)) {
      _selExpireDt.text = CommonUtil.getAddDayStr(_selProdDt.text,  widget.param['VALID_DAY']);
    }

    widget.param['IN_QTY']      =  _selInQty.text;
    widget.param['PROD_DATE']   =  CommonUtil.removeDash(_selProdDt.text);
    widget.param['EXPIRE_DATE'] =  CommonUtil.removeDash(_selExpireDt.text);

    await transaction(context, "inn/INN0001/saveInOrderItemInfo.do", widget.param, (status, data) {
        if(status == Constant.resSuccessCode) {
          Navigator.pop(context, true);
          showInfoAlert(context, "저장 되었습니다.");
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
          resizeToAvoidBottomInset : true,
          appBar: pageAppBar(context, "입고품목 정보상세"),
          body:FooterLayout(
              footer: CommonActionBtn(btnName,
                  onPressed : () {
                    updateItemInfo();
                  }
              ),
              child: SingleChildScrollView(
                  child: GestureDetector(
                      onTap: (){
                        CommonUtil.hideKeyboard();
                      },
                      child: Container(
                        height: CommonUtil.pageMaxHeight(context),
                        child: Column(
                          children: <Widget> [
                            _itemInfoContents()
                          ],
                        ),
                      )
                  )
          )
      )
    );
  }

  Widget _itemInfoContents() {
    return Expanded (
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("품목군"),
              CommonTextField(widget.param['ITEM_NM'],
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("품목"),
              CommonTextField(widget.param['SHPR_ITEM_NM'],
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("품목코드"),
              CommonTextField(widget.param['SHPR_ITEM_CD'],
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("품목바코드"),
              CommonTextField(widget.param['ITEM_BARCODE'],
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("규격/단위"),
              CommonTextField(widget.param['ITEM_STD'],
                  enabled : false
                  , width : (MediaQuery.of(context).size.width - 135) / 2
              ),
              CommonTextField(widget.param['ITEM_UNIT'],
                  enabled : false
                  , width : (MediaQuery.of(context).size.width - 135) / 2
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("유통기간"),
              CommonTextField(widget.param['VALID_DAY'].toString() + "일",
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("예정수량"),
              CommonTextField(widget.param['IN_CONF_QTY'],
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("입고(잔여)수량"),
              CommonTextField(_selInQty,
                  focusNode : _fnOne
                  , keyboardType : TextInputType.number
                  ,onEditingComplete: (result){
                  CommonUtil.hideKeyboard();
                },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("제조일자"),
              CommonDatePicker(selConroller: _selProdDt, )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("유통기한"),
              CommonDatePicker(selConroller: _selExpireDt, )
            ],
          ),
        ],
      ),
    );
  }

}