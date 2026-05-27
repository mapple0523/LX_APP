import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonMaterial.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/inn/INN0001P01.dart';
import 'package:dtwms_app/pages/inn/INN0001P04.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'INN0001P01.dart';

class INN0001M extends StatefulWidget {
  @override
  _INN0001M createState() => _INN0001M();
}

class _INN0001M extends State<INN0001M> {
  DateTime _schInDt = DateTime.now();

  TextEditingController _materialNm = TextEditingController();
  TextEditingController _materialCd = TextEditingController();

  //TextEditingController _plantValue = TextEditingController();
  TextEditingController _scanValue = TextEditingController();
  TextEditingController _sLoc = TextEditingController();
  TextEditingController _selInDtFrom = TextEditingController();
  TextEditingController _selInDtTo = TextEditingController();
  TextEditingController _selInfo = TextEditingController();
  TextEditingController _carNo = TextEditingController();

  final FocusNode _fnOne = FocusNode();
  final FocusNode _fnTwo = FocusNode();
  final FocusNode _fnThree = FocusNode();
  final FocusNode _fnFour = FocusNode();

  List<dynamic> _orderList = [];
  List<dynamic> _plantList = [];
  List<dynamic> _slocList = [];
  dynamic _plantValue  = null;
  dynamic _selLocVal = null;

  bool isPopup = false;

  Future<void> _searchOrderInfo(bool flag) async {
    if(CommonUtil.isNull(_selInDtFrom.text) || CommonUtil.isNull(_selInDtTo.text)) {
      showInfoAlert_pda(context, "chkInDate");
      return;
    }

    Map<String, dynamic> param = {};
    param['PLANT_VALUE']  = _plantValue;
    param['S_LOC']        = _selLocVal;
    param['IN_PLAN_DATE_FROM'] = CommonUtil.removeDash(_selInDtFrom.text);
    param['IN_PLAN_DATE_TO'] = CommonUtil.removeDash(_selInDtTo.text);
    param['INVOICE_NO']   = _selInfo.text;
    param['VEHICLE_NO']   = _carNo.text;
    param['SHPR_ITEM_NM'] = _materialNm.text;

    List<dynamic> rtnList =
    await transaction(context, "inn/INN0001/getInOrderItemInfo.do", param);

    if (CommonUtil.isEmpty(rtnList))
      _orderList = [];
    else
      _orderList = rtnList;

    setState(() {
      // 리스트 하나면 바로 detail 페이지로
      if (_orderList.length == 1 && flag) {
        FocusScope.of(context).unfocus();
        savePage(_orderList[0]);
      }
    });



  }

  @override
  void initState() {
    super.initState();

    _selInDtFrom.text = formatDate(_schInDt, [yyyy, '-', mm, '-', dd]);
    _selInDtTo.text = formatDate(_schInDt, [yyyy, '-', mm, '-', dd]);

    Future.delayed(Duration.zero, () async {
      await _plantSearch();
    });
  }

  @override
  void dispose() {
    print("dispose");
    super.dispose();
  }

  Future<dynamic> savePage([dynamic param]) async {
    isPopup = true;
    print("param + $param");
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => INN0001P04(param: param)));

    isPopup = false;
    if (!CommonUtil.isEmpty(result) && result == true) {
      //_selInfo.text = "";
      _searchOrderInfo(false);
    }
  }

  Future<void> _handleCMScan(String scannedValue) async {
    print("CM 타입 스캔 처리 시작: $scannedValue");

    if(!isPopup){
      if(scannedValue.startsWith("IV") || scannedValue.startsWith("PO")){
        scannedValue = scannedValue.substring(2);
        _selInfo.text = scannedValue;
        _searchOrderInfo(true);
      }
      else{
        _materialCd.text = scannedValue;
        _materialNm.text = scannedValue;
      }

    }else{
      print("Popup 오픈됨");
    }
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

    List<dynamic> rtnList = await transaction(context, "common/getCommonPlantList.do", param);
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
      "ALL_FLAG" : "Y",
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

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "in"),
        body: Container(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                CommonUtil.hideKeyboard();
              },
              child: Column(
                children: <Widget>[
                  _searchField(),
                  Row(
                    children: <Widget>[
                      CommonActionBtn(
                          "btnSearch",
                          height: 50,
                          fontSize: 20,
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _searchOrderInfo(true);
                          }
                      )
                    ],
                  ),
                  Expanded(
                    child: CustomGrid(
                        [['plant','sloc'],['itemCd','packId'], 'qty', ['inType','차량정보']],
                        [['PLANT','SLOC'],['SHPR_ITEM_NM','PACK_ID'], 'IN_CONF_QTY', ['IN_TYPE_NM','VEHICLE_NO']],
                        _orderList,
                        onTap: ([rowData]) {
                          savePage(rowData);
                        },
                        onRefresh: () {
                          _searchOrderInfo(true);
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
    return Container(
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
              CommonText("입고\r\n예정일자", height: 95,width: MediaQuery.of(context).size.width * 0.25),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CommonDatePicker(
                    selConroller: _selInDtFrom,
                    clearEnabled: false,
                    width: MediaQuery.of(context).size.width * 0.75,
                    onEditingComplete: ([result]) {
                      _searchOrderInfo(true);
                    },
                  ),
                  CommonDatePicker(
                    selConroller: _selInDtTo,
                    clearEnabled: false,
                    width: MediaQuery.of(context).size.width * 0.75,
                    onEditingComplete: ([result]) {
                      _searchOrderInfo(true);
                    },
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("itemCd", width: MediaQuery.of(context).size.width * 0.25),
              CommonMaterial(
                selMaterialVal: _materialNm,
                focusNode: _fnFour,
                width: MediaQuery.of(context).size.width * 0.75,
                param: () => {
                  'ITEM_NM' : _materialNm.text
                },
                onEditingComplete: (result, [selectedData]) {
                  print(selectedData);

                  _materialCd.text = selectedData['ITEM_CD']?.toString() ?? '';

                  FocusScope.of(context).unfocus();
                  CommonUtil.hideKeyboard();

                  _searchOrderInfo(true);
                },
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("거래명세서\r\n번호", width: MediaQuery.of(context).size.width * 0.25 , maxLines:2),
              CommonTextField(
                  _selInfo,
                  width: MediaQuery.of(context).size.width * 0.75 - 15,
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                    CommonUtil.hideKeyboard();
                  },
                  onSubmitted : (){
                    print("onSubmitted");
                  }

              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("차량번호", width: MediaQuery.of(context).size.width * 0.25 , maxLines:2),
              CommonTextField(
                  _carNo,
                  width: MediaQuery.of(context).size.width * 0.75 - 15,
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                    CommonUtil.hideKeyboard();
                  },
                  onSubmitted : (){
                    print("onSubmitted");
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
                      focusNode: _fnThree,
                      scanType: "CM",
                      autofocus: true,
                      onEditingComplete: (scannedValue) {
                        _handleCMScan(scannedValue);
                      }
                  )
              )

            ],
          ),
        ],
      ),
    );
  }
}
