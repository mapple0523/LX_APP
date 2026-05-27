
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/restfulReq.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';


class MDM0001M extends StatefulWidget {
  const MDM0001M({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _MDM0001M createState() => _MDM0001M();
}

class _MDM0001M extends State<MDM0001M>  {
  final TextEditingController _selBarcodeVal  = TextEditingController();
  FocusNode fnOne;
  List<dynamic> _itemList = [{}];

  dynamic _selCboShpr;
  dynamic _selCboItem;
  dynamic _selCboItemShpr;

  List<dynamic> _selCboShprList       = [];    //화주
  List<dynamic> _selCboItemList       = [];    //품목군
  List<dynamic> _selCboItemShprList   = [];    //품목

  dynamic pShpr;
  dynamic pItem;
  dynamic pShprItem;

  bool noBtnFalg = false;

  Future<void> _searchItemBarcodeInfo() async {
    Map<String, dynamic> param = {};
    param['SHPR_CD']        = _selCboShpr;
    param['UP_ITEM_CD']     = _selCboItem;
    param['SHPR_ITEM_CD']   = _selCboItemShpr;

    List<dynamic> rtnList = await transaction(context, "mdm/MDM0001/getItemBarcodeInfo.do", param);

    if(CommonUtil.isEmpty(rtnList))
      _itemList = [{}];
    else
      _itemList = rtnList;

    setState(() { fnOne.requestFocus();});
  }

  @override
  void initState() {
    fnOne = FocusNode();
    _selBarcodeVal.text = CommonUtil.isEmpty(widget.param) ? null : widget.param['ITEM_BARCODE'];
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      if(!CommonUtil.isEmpty(widget.param)) {
        if(widget.param.containsKey('SHPR_CD')) {
          pShpr = widget.param['SHPR_CD'];
        }
      }
      //화주 콤보박스
      shprInfo(context, null).then((data) {
        _selCboShprList = data;
        comboCallback("SHPR", pShpr, null);
      });

    }
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  _saveItemBarcode() {
    if(CommonUtil.isNull(_selCboShpr)) {
      showInfoAlert(context, "화주를 선택하세요.");
      return;
    }
    if(CommonUtil.isNull(_selCboItem)) {
      showInfoAlert(context, "품목군을 선택하세요.");
      return;
    }

    if(CommonUtil.isNull(_selCboItemShpr)) {
      showInfoAlert(context, "품목을 선택하세요.");
      return;
    }

    if(CommonUtil.isNull(_selBarcodeVal.text)) {
      showInfoAlert(context, "품목 바코드를 스캔하세요.");
      return;
    }

    confirmDialog(context, "바코드 등록", "등록 하시겠습니까?").then((value) async {
      if(value) {
        dynamic saveData = ConvertUtil.copyObject(_itemList[0]);
        saveData['ITEM_BARCODE'] = _selBarcodeVal.text;

        await transaction(context, "mdm/MDM0001/saveItemBarcodeInfo.do", saveData, (status, data) {
          if(status == Constant.resSuccessCode) {
            if(!CommonUtil.isEmpty(widget.param)) {
              Navigator.pop(context, {'SHPR_CD' : _selCboShpr, 'SHPR_ITEM_CD' : _selCboItemShpr, 'ITEM_BARCODE' : _selBarcodeVal.text});
            } else {
              _selBarcodeVal.text = "";
              showInfoAlert(context, "등록 되었습니다.");
            }
          }
        });
      }
    });
  }

  Future<void> comboCallback(String id, dynamic code, dynamic name) async {
    if(id == "SHPR") {
      _selCboShpr     = code;
      _selCboItemList = await shprItemGroupInfo(context, {'SHPR_CD' : code});
      comboCallback("UP_ITEM", null, null);
    }
    else if(id == "UP_ITEM") {
      _selCboItem         = code;
      _selCboItemShprList = await shprItemComboList(context, {'SHPR_CD' : _selCboShpr, 'UP_ITEM_CD' : _selCboItem});
      comboCallback("SHPR_ITEM", null, null);
    }
    else if(id == "SHPR_ITEM") {
      _selCboItemShpr = code;
      _searchItemBarcodeInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset : true,
        appBar: pageAppBar(context, "바코드 등록", false),
        body: FooterLayout(
            footer: CommonActionBtn("등록"
                , onPressed: () {
                  _saveItemBarcode();
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
                          _shprItemBarcdeField(),
                        ],
                      ),
                    )
                )
            )
        )
    );
  }

  Widget _shprItemBarcdeField() {
    return Expanded (
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("화주"),
              CommonDropdown("SHPR", _selCboShpr, _selCboShprList, comboCallback, width: 225,),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("품목군"),
              CommonDropdown("UP_ITEM", _selCboItem, _selCboItemList, comboCallback, width: 225),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("품목"),
              CommonDropdown("SHPR_ITEM", _selCboItemShpr, _selCboItemShprList, comboCallback, width: 225),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("품목코드"),
              CommonTextField(_itemList[0]['SHPR_ITEM_CD'], enabled: false,),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("유형"),
              CommonTextField(_itemList[0]['ITEM_ATTR_NM'], enabled: false,),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("규격"),
              CommonTextField(_itemList[0]['ITEM_STD'], enabled: false,),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("단위"),
              CommonTextField(_itemList[0]['ITEM_UNIT'], enabled: false,),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("품목바코드"),
              CommonScanTextField(_selBarcodeVal
                , focusNode: fnOne
                , scanType: "CM"
                , onEditingComplete: ([fousNode]) {
                  //_saveItemBarcode();
                }
                ,
              ),
            ],
          ),
        ],
      ),
    );
  }
}