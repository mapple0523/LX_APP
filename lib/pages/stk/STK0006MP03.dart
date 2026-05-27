import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/CommonLocation.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'STK0006MP05.dart';

class STK0006MP03 extends StatefulWidget {
  @override
  _STK0006MP03 createState() => _STK0006MP03();
}

class _STK0006MP03 extends State<STK0006MP03>  {

  List<dynamic> _seletedRecords           = [];
  final TextEditingController _selLocVal  = TextEditingController();
  final TextEditingController _selPackId  = TextEditingController();
  final TextEditingController _selItemBarcode  = TextEditingController();

  List<dynamic> _searchList = [];
  List<dynamic> _findKey = [];

  FocusNode fnOne;
  FocusNode fnTwo;
  FocusNode fnThree;

  Future<void> _search() async {
    if(CommonUtil.isNull(_selLocVal.text)) {
      showInfoAlert(context, "로케이션을 선택하세요.");
      return;
    }
    if(CommonUtil.isNull(_selPackId.text)) {
      showInfoAlert(context, "페킹ID를 입력하세요.");
      return;
    }

    Map<String, dynamic> param = {
      "LOCATION_CD"  : _selLocVal.text,
      "PACK_ID"      : _selPackId.text
    };

    List<dynamic> rtnList = await transaction(context, "stk0006/unPackList.do", param);

    if(CommonUtil.isEmpty(rtnList))
      _searchList = [];
    else
      _searchList = rtnList;

    _selItemBarcode.selection = TextSelection(baseOffset: 0,extentOffset: _selItemBarcode.text.length,);

    setState(() {
      _seletedRecords = [];
    });
  }

  Future<dynamic> _movePageSelection(BuildContext context, [dynamic param]) async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => STK0006MP05(param: param)));

    return result;
  }

  Future<void> _FindKey([dynamic param]) async{

    List<dynamic> rtnList = await transaction(context, "stk0006/unPackCheck.do", param);

    if(CommonUtil.isEmpty(rtnList))
      _findKey = [];
    else
      _findKey = rtnList;

    setState(() {

    });
  }

  _callBarcodeScanInfo() async{

    Map<String, dynamic> paramMap = {
      "ITEM_BARCODE" : _selItemBarcode.text,
      "LOCATION_CD"  : _selLocVal.text,
      "PACK_ID"      : _selPackId.text
    };
    List<dynamic> resultData = await transaction(context, "stk0006/unPackCheck.do", paramMap);

    if(CommonUtil.isEmpty(resultData)) {
      showInfoAlert(context, "유효하지 않은(는) 품목 바코드입니다.");
      return;
    }
    else if(resultData.length == 1){
      _searchList.map((e) {
        if(e['UNIQUE_KEY'] == resultData[0]['UNIQUE_KEY']) {
          if(!CommonUtil.isEmpty(CommonUtil.findValFromList(_searchList, 'UNIQUE_KEY', e['UNIQUE_KEY'], 'UNIQUE_KEY'))){
            if(CommonUtil.isNull(CommonUtil.findValFromList(_seletedRecords, 'UNIQUE_KEY', e['UNIQUE_KEY'], 'UNIQUE_KEY'))) {
              _seletedRecords.add(e);
            }
            else{
              _seletedRecords.remove(e);
            }
          }
          else
            return;
        }
      }).toList();
    }
    else {
      _movePageSelection(context, paramMap).then((data) {
        Map<String, dynamic> paramMap2 = {
          "ITEM_BARCODE" : _selItemBarcode.text,
          "LOCATION_CD"  : _selLocVal.text,
          "PACK_ID"      : _selPackId.text,
          "STOCK_SEQ"    : data['PACK_SEQ']
        };
        _FindKey(paramMap2).then((data){
          _searchList.map((e) {
            if(e['UNIQUE_KEY'] == _findKey[0]['UNIQUE_KEY']) {
              if(!CommonUtil.isEmpty(CommonUtil.findValFromList(_searchList, 'UNIQUE_KEY', e['UNIQUE_KEY'], 'UNIQUE_KEY'))){
                if(CommonUtil.isNull(CommonUtil.findValFromList(_seletedRecords, 'UNIQUE_KEY', e['UNIQUE_KEY'], 'UNIQUE_KEY'))) {
                  _seletedRecords.add(e);
                }
                else{
                  _seletedRecords.remove(e);
                }
              }
              else
                return;
            }
          }).toList();
        });
      });
    }
    setState(() {});
  }
  _onTapUpdate(dynamic rowData) async {
    if(CommonUtil.isNull(CommonUtil.findValFromList(_seletedRecords, 'UNIQUE_KEY', rowData['UNIQUE_KEY'], 'UNIQUE_KEY'))) {
      _seletedRecords.add(rowData);
    }
    else{
      _seletedRecords.remove(rowData);
    }
      setState(() { });
  }

  Future<void> _UnPackId() async {
    List<dynamic> paramList = [];

    if (_seletedRecords is List && _seletedRecords.length > 0) {
      for (var i = 0; i < _seletedRecords.length; i++) {
        dynamic e = _seletedRecords[i];
        e['STOCK_QTY'] = 0;
        e['adtType'] = 'UP';
        e['addRmk'] = '';
      }
      await transaction(context, "stk0006/unpack.do", _seletedRecords,(status, data) {
        if(status == Constant.resSuccessCode) {
          showInfoAlert(context,'패킹해제 완료.');
          _seletedRecords = [];
          _searchList = [];
        }
      });
    }
    else{
      showInfoAlert(context, '품목 스캔 후 해제하세요');
    }
    setState(() {});
  }

  @override
  void initState() {

    fnOne = FocusNode();
    fnTwo = FocusNode();
    fnThree = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        FocusScope.of(context).requestFocus(fnOne)
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: pageAppBar(context, "패킹해제"),
        body: Container(
            child: GestureDetector(
            onTap: (){
            CommonUtil.hideKeyboard();
            },
            child: Column(
                children: <Widget> [
                  _searchField(),
                  CommonActionBtn("조회",
                    height: 50,
                    fontSize: 20
                    , onPressed: () {
                    _search();
                    },
                  ),
                  Expanded(
                    child: CustomGrid([['화주', '품목'], ['품목코드', '품목바코드'],['재고수량','패킹수량'],'홀딩수량','유통기한'],
                      [['SHPR_NM', 'SHPR_ITEM_NM'],['SHPR_ITEM_CD', 'ITEM_BARCODE'],['ORG_STOCK_QTY','PACK_QTY'],'HOLD_QTY','EXPIRE_DATE_FM'], _searchList,
                      seletedRecords: _seletedRecords,
                      onTap : ([rowData]) {
                        _onTapUpdate(rowData);
                      },
                    ),
                  ),
                  CommonActionBtn("패킹해제",
                    onPressed: _UnPackId,
                  ),
                ]
            )
        )
        )
    );
  }

  Widget _searchField() {
    return Container (
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("로케이션"),
              CommonLocation(selLocVal: _selLocVal, focusNode: fnOne
                  , onEditingComplete: ([result]) {
                    fnOne.unfocus();
                    FocusScope.of(context).requestFocus(fnTwo);
                  }
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("PACK ID"),
              CommonScanTextField(_selPackId,
                refresh : () {setState(() {});},
                focusNode : fnTwo,
                scanType: "PA",
                onEditingComplete : (nodeObj) {
                  fnTwo.unfocus();
                  FocusScope.of(context).requestFocus(fnThree);
                  _search();
                },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("품목 바코드"),
              CommonScanTextField(_selItemBarcode,
                refresh : () {setState(() {});},
                focusNode : fnThree,
                scanType: "PD",
                onEditingComplete : (nodeObj) {
                  _callBarcodeScanInfo();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}