import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonMaterial.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/commOutNo.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/out/OUT0005MP02.dart';
import 'package:dtwms_app/pages/out/OUT0005MP03.dart';
import 'package:dtwms_app/pages/out/OUT0006P01.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:dtwms_app/pages/out/OUT0002P03.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'OUT0002P03.dart';

class OUT0006M extends StatefulWidget {
  const OUT0006M({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0006M createState() => _OUT0006M();
}

class _OUT0006M extends State<OUT0006M> {
  final TextEditingController _materialNm = TextEditingController();
  final TextEditingController _materialCd = TextEditingController();
  final TextEditingController _selLocVal = TextEditingController();
  final TextEditingController _scanValue = TextEditingController();
  final FocusNode _scanFocus = FocusNode();
  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();
  final FocusNode fnThree = FocusNode();

  dynamic _plantValue  = null;
  dynamic _slocVal = null;

  List<dynamic> _carList = [];
  //배송처에 속한 출고번호 List
  List<dynamic> _searchCustOutList = [];
  List<dynamic> _plantList = [];
  List<dynamic> _slocList = [];

  DateTime _schPickDt = DateTime.now();

  final TextEditingController _selPickDtFrom = TextEditingController();

  @override
  void initState() {

    _selPickDtFrom.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);

    Future.delayed(Duration.zero, () async {
      if (mounted) {
        await _plantSearch();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    FocusScope.of(context).unfocus();

    super.dispose();
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

    List<dynamic> rtnList =
    await transaction(context, "common/getCommonSlocList.do", param);

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

  Future<void> _searchStockList() async {
    _carList = [];
    
    Map<String, dynamic> param = {};
    param['ITEM_NM'] = _materialNm.text;
    param['ITEM_CD'] = _materialCd.text;
    param['MATNR'] = _materialCd.text;
    param['LOCATION_CD'] = _selLocVal.text;
    param['FROM_PLANT'] = _plantValue;
    param['FROM_SLOC'] = _slocVal;
    param['WERKS'] = _plantValue;
    param['LGORT'] = _slocVal;


    List<dynamic> rtnList =
        await transaction(context, "out/OUT0006/searchStockInfoList.do", param);

    if (CommonUtil.isEmpty(rtnList))
      _carList = [];
    else
      _carList = rtnList;

    setState(() {});
  }

  Future<dynamic> callNavi(BuildContext context, [dynamic param]) async {

    param['custList'] = _searchCustOutList;

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0006P01(param: param)));

    // 전화면으로 넘기기
    if (result != null) {
      Navigator.pop(context, result);
    }
  }

  Future<void> _handleCMScan(String scannedValue) async {
    print("CM 타입 스캔 처리 시작: $scannedValue");
    // BIN NO scan
    if (scannedValue.startsWith(Constant.BIN_BARCODE_DELIMIT)) {
      scannedValue = scannedValue.replaceAll(Constant.BIN_BARCODE_DELIMIT, "");
      _selLocVal.text = scannedValue;
    }
    else{
      _materialCd.text = scannedValue;
      _materialNm.text = scannedValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "moveInst"),
        body: Container(
            child: GestureDetector(
          onTap: () {
            CommonUtil.hideKeyboard();
            _scanFocus.requestFocus();
          },
          child: Column(
            children: <Widget>[
              _searchField(),
              CommonActionBtn(
                "btnSearch",
                height: 50,
                fontSize: 20,
                onPressed: () {
                  _searchStockList();
                },
              ),
              Expanded(
                child: CustomGrid(['bin', ['itemCd','lotNo'], 'qty'],
                  ['LOCATION_CD', ['ITEM_NM','LOT_NO'], 'STOCK_QTY'],
                  _carList,
                  onTap: ([rowData]) {
                    callNavi(context, rowData).then((data) {});
                  },
                ),
              ),
            ],
          ),
        )));
  }

  Widget _searchField() {
    return Container(
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
              CommonText("itemCd", width: MediaQuery.of(context).size.width * 0.2,),
              CommonMaterial(
                selMaterialVal: _materialNm,
                focusNode: fnTwo,
                width: MediaQuery.of(context).size.width * 0.8,
                param: () => {
                  'ITEM_NM' : _materialNm.text
                },
                onEditingComplete: (result, [selectedData]) {
                  _materialCd.text = selectedData['ITEM_CD']?.toString() ?? '';

                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("bin", width: MediaQuery.of(context).size.width * 0.2,),
              CommonLocation(selLocVal: _selLocVal
                  , focusNode: fnOne
                  , width: MediaQuery.of(context).size.width * 0.8
                  , onEditingComplete: ([result]) {
                    CommonUtil.hideKeyboard();
                    _scanFocus.requestFocus();
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
          // Row(
          //   children: <Widget>[
          //     CommonText("itemNm"),
          //     CommonTextField(_materialCd,
          //         onEditingComplete: ([result]) {
          //         _searchField();
          //     })
          //   ],
          // ),
        ],
      ),
    );
  }
}
