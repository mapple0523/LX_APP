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
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'INN0002P01.dart';

class INN0002M extends StatefulWidget {
  @override
  _INN0002M createState() => _INN0002M();
}

class _INN0002M extends State<INN0002M>  {
  DateTime _schInDt = DateTime.now();

  List<dynamic> _plantList = [];
  List<dynamic> _slocList = [];
  dynamic _plantValue  = null;
  dynamic _selLocVal = null;

  final TextEditingController _selInDtFrom = TextEditingController();
  final TextEditingController _selInDtTo   = TextEditingController();
  final TextEditingController _selInNoVal  = TextEditingController();

  FocusNode _fnThree;

  List<dynamic> _orderList = [];

  Future<void> _searchOrderPutInfo(bool autoFlag) async {
    FocusScope.of(context).unfocus();

    if(CommonUtil.isNull(_selInDtFrom.text) || CommonUtil.isNull(_selInDtTo.text)) {
      showInfoAlert_pda(context, "chkInDate");
      return;
    }

    Map<String, dynamic> param = {};
    param['PLANT_VALUE']  = _plantValue;
    param['S_LOC']        = _selLocVal;
    param['IN_DATE_FROM']      = CommonUtil.removeDash(_selInDtFrom.text);
    param['IN_DATE_TO']      = CommonUtil.removeDash(_selInDtTo.text);
    param['INVOICE_NO']   = _selInNoVal.text;

    List<dynamic> rtnList =
        await transaction(context, "inn/INN0002/getInOrderPutInfo.do", param);

    if(CommonUtil.isEmpty(rtnList))
      _orderList = [];
    else
      _orderList = rtnList;

    // _selInNoVal.selection = TextSelection(
    //   baseOffset: 0,
    //   extentOffset: _selInNoVal.text.length,
    // );

    setState(() {});

    if(_orderList.length == 1 && autoFlag) {
      _movePage(context, _orderList[0]);
    }
  }

  @override
  void initState() {
    _fnThree = FocusNode();
    _selInDtFrom.text = formatDate(_schInDt, [yyyy, '-', mm, '-', dd]);
    _selInDtTo.text = formatDate(_schInDt, [yyyy, '-', mm, '-', dd]);

    Future.delayed(Duration.zero, () async {
      await _plantSearch();
    });

    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleCMScan(String scannedValue) async {
    //
    if(scannedValue.startsWith("IV") || scannedValue.startsWith("PO")){
      scannedValue = scannedValue.substring(2);
    }
    _selInNoVal.text = scannedValue;

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
      _selLocVal = code;
    }

    setState(() {});
  }

  Future<void> _plantSearch() async {
    Map<String, dynamic> param = {"ALL_FLAG" : "Y"};
    _plantList = [];

    List<dynamic> rtnList =
    await transaction(context, "common/getCommonPlantList.do", param);
    if (CommonUtil.isEmpty(rtnList)) {
      _plantList = [];
      _plantValue = null; // 리스트가 비어있으면 null로 설정
    } else {
      _plantList = rtnList;
      // 첫 번째 항목을 기본값으로 설정
      if (_plantList.isNotEmpty) {
        _plantValue = _plantList[0]["CODE"];

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
      "PLANT": code,
    };

    List<dynamic> rtnList = await transaction(context, "common/getCommonSlocList.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _slocList = [];
      _selLocVal = null; // 리스트가 비어있으면 null로 설정
    } else {
      _slocList = rtnList;
      // 첫 번째 항목을 기본값으로 설정
      if (_slocList.isNotEmpty) {
        _selLocVal = _slocList[0]["CODE"];
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
            builder: (context) => INN0002P01(param: param)));

    if(!CommonUtil.isEmpty(result) && result == true) {
      //_selInNoVal.text = "";
      _searchOrderPutInfo(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();

    return Scaffold(
          resizeToAvoidBottomInset : false,
          appBar: pageAppBar(context, "stockPut"),
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
                      [['plant','sloc'],['itemCd','packId'], 'qty', 'bin','차량번호'],
                      [['PLANT','SLOC'],['SHPR_ITEM_NM','PACK_ID'], 'IN_QTY', 'IN_LOCATION_CD','VEHICLE_NO'],
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
              CommonText("plant", width: MediaQuery.of(context).size.width * 0.25),
              CommonDropdown("W", _plantValue, _plantList, comboCallback, width : MediaQuery.of(context).size.width * 0.25-12.5, viewType: "CN",),
              CommonText("sloc", width: MediaQuery.of(context).size.width * 0.25),
              CommonDropdown("Z", _selLocVal, _slocList, comboCallback, width : MediaQuery.of(context).size.width * 0.25-12.5, viewType: "CN",),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("inDt", height: 82,width: MediaQuery.of(context).size.width * 0.25,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CommonDatePicker(
                    selConroller: _selInDtFrom,
                    clearEnabled: false,
                    width: MediaQuery.of(context).size.width * 0.75,
                    onEditingComplete: ([result]) {
                      _searchOrderPutInfo(true);
                    },
                  ),
                  CommonDatePicker(
                    selConroller: _selInDtTo,
                    clearEnabled: false,
                    width: MediaQuery.of(context).size.width * 0.75,
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
              CommonText("거래명세서\r\n번호", width: MediaQuery.of(context).size.width * 0.25, maxLines:2),
              CommonScanTextField(_selInNoVal,
                focusNode: _fnThree,
                scanType: "CM",
                width: MediaQuery.of(context).size.width * 0.75 - 15,
                onTap: () {
                },
                onEditingComplete: (scannedValue) async {
                  // CM 타입 스캔에 대한 커스텀 처리
                  await _handleCMScan(scannedValue);
                },
              )

              // CommonScanTextField(
              //     _selInNoVal,
              //     focusNode : _fnThree
              //     , scanType: "IN"
              //     , onEditingComplete : (nodeObj) {
              //       _searchOrderPutInfo(true);
              //     }
              // )
            ],
          ),
        ],
      ),
    );
  }
}