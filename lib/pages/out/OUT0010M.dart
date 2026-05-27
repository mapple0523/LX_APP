import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/popup.dart';
import 'package:dtwms_app/pages/out/OUT0010P01.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'OUT0002P03.dart';

class OUT0010M extends StatefulWidget {
  const OUT0010M({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0010M createState() => _OUT0010M();
}

class _OUT0010M extends State<OUT0010M> {
  final TextEditingController _materialNm = TextEditingController();
  final TextEditingController _bizNm = TextEditingController();
  final TextEditingController _selPackId = TextEditingController();

  FocusNode _fnOne = FocusNode();

  dynamic _plantValue  = null;
  dynamic _slocVal = null;

  List<dynamic> _carList = [];
  //배송처에 속한 출고번호 List
  List<dynamic> _plantList = [];
  List<dynamic> _slocList = [];

  @override
  void initState() {

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

  Future<void> _handleCMScan(String scannedValue) async {
    print("CM 타입 스캔 처리 시작: $scannedValue");
    scannedValue = CommonUtil.parseLotNo(scannedValue);
    _selPackId.text = scannedValue;
    _searchStockList();
    setState(() {

    });

    print("CM 타입 스캔 처리 완료");
  }

  Future<void> _searchStockList() async {
    FocusScope.of(context).unfocus();
    _carList = [];
    
    Map<String, dynamic> param = {};
    param['WERKS'] = _plantValue;
    param['LGORT'] = _slocVal;
    param['PACK_ID'] = _selPackId.text;

    List<dynamic> rtnList = await transaction(context, "out/OUT0010/searchStockInfoList.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _carList = [];
    }
    else {
      // rtnList가 1건 이상일 경우
      if(rtnList.length > 1){
        final result = await showSmallPopup(context, rtnList, ["PACK_ID","ZZGRADE"]);

        // 선택을 하지 않을 경우 종료
        if(result == null){
          return;
        }

        rtnList.clear();
        rtnList.add(result);
      }
      _carList = rtnList;
    }
    setState(() {});
  }

  Future<dynamic> callNavi(BuildContext context, [dynamic param]) async {

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0010P01(param: param)));

    if (result == true) {
      await _searchStockList();
    }

  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "RC 이전전기"),
        body: Container(
            child: GestureDetector(
          onTap: () {
            CommonUtil.hideKeyboard();
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
                child: CustomGrid(['bin', ['itemCd','packId'], 'qty'],
                  ['LOCATION_CD', ['ITEM_NM','PACK_ID'], 'STOCK_QTY'],
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
              CommonText("plant", width: MediaQuery.of(context).size.width * 0.25),
              CommonDropdown("W", _plantValue, _plantList, comboCallback, width : MediaQuery.of(context).size.width * 0.25-12.5, viewType: "CN",),
              CommonText("sloc", width: MediaQuery.of(context).size.width * 0.25),
              CommonDropdown("Z", _slocVal, _slocList, comboCallback, width : MediaQuery.of(context).size.width * 0.25-12.5, viewType: "CN",),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("packId", width: MediaQuery.of(context).size.width * 0.25),
              CommonScanTextField(_selPackId,
                focusNode: _fnOne,
                scanType: "CM",
                width: MediaQuery.of(context).size.width * 0.75 - 15,
                onTap: () {
                },
                onEditingComplete: (scannedValue) async {
                  // CM 타입 스캔에 대한 커스텀 처리
                  await _handleCMScan(scannedValue);
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
