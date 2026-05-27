import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/inn/INN0007P01.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';

class INN0007M extends StatefulWidget {
  @override
  _INN0007M createState() => _INN0007M();
}

class _INN0007M extends State<INN0007M>  {
  DateTime _schInDt = DateTime.now();

  dynamic _plantValue  = null;
  dynamic _slocVal = null;

  final TextEditingController _selInDtFrom = TextEditingController();
  final TextEditingController _selInDtTo   = TextEditingController();
  final TextEditingController _selPoNoVal  = TextEditingController();

  final FocusNode _scanFocus = FocusNode();
  final TextEditingController _scanValue = TextEditingController();

  List<dynamic> _orderList = [];
  List<dynamic> _plantList = [];
  List<dynamic> _slocList = [];

  Future<void> _searchOrderPutInfo(bool autoFlag) async {

    if(CommonUtil.isNull(_selInDtFrom.text) || CommonUtil.isNull(_selInDtTo.text)) {
      showInfoAlert_pda(context, "chkInDate");
      return;
    }

    Map<String, dynamic> param = {};
    param['PLANT']       = _plantValue;
    param['SLOC']        = _slocVal;
    param['FROM_IN_DT']  = CommonUtil.removeDash(_selInDtFrom.text);
    param['TO_IN_DT']    = CommonUtil.removeDash(_selInDtTo.text);
    param['PO_NO']       = _selPoNoVal.text;

    List<dynamic> rtnList =
    await transaction(context, "inn/INN0007/searchPoInfoList.do", param);

    if(CommonUtil.isEmpty(rtnList))
      _orderList = [];
    else
      _orderList = rtnList;

    _scanFocus.requestFocus();
    setState(() {});

    if(_orderList.length == 1 && autoFlag) {
      _movePage(context, _orderList[0]);
    }
  }

  @override
  void initState() {
    _selInDtFrom.text = formatDate(_schInDt, [yyyy, '-', mm, '-', dd]);
    _selInDtTo.text = formatDate(_schInDt, [yyyy, '-', mm, '-', dd]);

    Future.delayed(Duration.zero, () async {
      if (mounted) {
        await _plantSearch();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleCMScan(String scannedValue) async {
    if(scannedValue.startsWith("IV") || scannedValue.startsWith("PO")){
      scannedValue = scannedValue.substring(2);
    }

    _selPoNoVal.text = scannedValue;

    setState(() {
      _searchOrderPutInfo(true);
    });

  }

  Future<void> comboCallback(String id, dynamic code, dynamic name) async {
    if(id == Constant.LOCATION_TYPE_W) {
      _plantValue = code;

      await _sLocSearch(code);
    }
    else if(id == Constant.LOCATION_TYPE_Z) {
      _slocVal = code;
    }

    setState(() {});
  }

  Future<void> _plantSearch() async {
    Map<String, dynamic> param = {};
    _plantList = [];

    List<dynamic> rtnList = await transaction(context, "common/getCommonPlantList.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _plantList = [];
      _plantValue = null; // 리스트가 비어있으면 null로 설정
    } else {
      _plantList = rtnList;
      if (_plantList.isNotEmpty) {
         dynamic _plant300 = CommonUtil.findMapFromList(_plantList, "CODE", "3000");
         if(!CommonUtil.isEmpty(_plant300)){
           _plantValue = "3000";
         } else{
           _plantValue = _plantList[0]["CODE"];
         }

        _sLocSearch(_plantValue);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _sLocSearch(String code) async {
    Map<String, dynamic> param = {};
    _slocList = [];

    param = {
      "ALL_FLAG" : "Y",
      "PLANT": code,
    };

    List<dynamic> rtnList = await transaction(context, "common/getCommonSlocList.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _slocList = [];
      _slocVal = null; // 리스트가 비어있으면 null로 설정
    } else {
      _slocList = rtnList;
      // 첫 번째 항목을 기본값으로 설정
      if (_slocList.isNotEmpty) {
        _slocVal = _slocList[0]["CODE"];
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<dynamic> _movePage(BuildContext context, [dynamic param]) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => INN0007P01(param: param)));
    print("popup result : ${result}");
    if(!CommonUtil.isEmpty(result) && result == true) {
      _searchOrderPutInfo(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();

    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: pageAppBar(context, "PO입고"),
        body: Container(
            child: GestureDetector(
              onTap: (){
                CommonUtil.hideKeyboard();
              },
              child: Column(
                children: <Widget> [
                  _searchField(),
                  Row(
                    children: <Widget>[
                      CommonActionBtn("btnSearch"
                          , height: 50
                          , fontSize: 20
                          , onPressed: () {
                            _searchOrderPutInfo(true);
                          }
                      )
                    ],
                  ),
                  Expanded(
                    child: CustomGrid(
                        [['plant','sloc'], ['생성일자','PO번호'], '공급처명'],
                        [['PLANT','SLOC'], ['REG_DT','PO_NO'], 'CUST_NM'],
                        _orderList,
                        onTap : ([rowData]) {
                          _movePage(context, rowData);
                        },
                        onRefresh : () {
                          _searchOrderPutInfo(true);
                        }
                    ),
                  ),
                ],
              ),
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
                CommonText("plant", width: MediaQuery.of(context).size.width * 0.2),
                CommonDropdown("W", _plantValue, _plantList, comboCallback, width : MediaQuery.of(context).size.width * 0.3-12.5, viewType: "CN",),
                CommonText("sloc", width: MediaQuery.of(context).size.width * 0.2),
                CommonDropdown("Z", _slocVal, _slocList, comboCallback, width : MediaQuery.of(context).size.width * 0.3-12.5, viewType: "CN",),
              ],
            ),
            Row(
              children: <Widget>[
                CommonText("생성일자", height: 82, width: MediaQuery.of(context).size.width * 0.2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CommonDatePicker(
                      selConroller: _selInDtFrom,
                      clearEnabled: false,
                      width: MediaQuery.of(context).size.width * 0.8,
                      onEditingComplete: ([result]) {
                        _searchOrderPutInfo(true);
                        },
                    ),
                    CommonDatePicker(
                      selConroller: _selInDtTo,
                      clearEnabled: false,
                      width: MediaQuery.of(context).size.width * 0.8,
                      onEditingComplete: ([result]) {
                        _searchOrderPutInfo(true);
                        },
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: <Widget>[
                CommonText("PO번호", width: MediaQuery.of(context).size.width * 0.2),
                CommonTextField(
                  _selPoNoVal,
                  width: MediaQuery.of(context).size.width * 0.8-15,
                  onEditingComplete: (scannedValue) {
                    CommonUtil.hideKeyboard();
                    _scanFocus.requestFocus();
                  },
                  onSubmitted : (value){
                    _handleCMScan(value);
                  }
                )
              ],
            ),
            Row(
              children: <Widget>[
                Offstage(
                  offstage: true, // false로 바꾸면 다시 보임
                  child: CommonScanTextField(
                    _scanValue,
                    focusNode: _scanFocus,
                    autofocus: true,
                    scanType: "CM",
                    onEditingComplete: (scannedValue) async {
                      await _handleCMScan(scannedValue);
                    },
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }
}