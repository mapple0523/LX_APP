import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:date_format/date_format.dart';
import 'package:dtwms_app/pages/stk/STK0011MP01.dart';
import 'package:flutter/material.dart';

import 'STK0011MP01.dart';

class STK0011M extends StatefulWidget {

  @override
  _STK0011M createState() => _STK0011M();
}

class _STK0011M extends State<STK0011M>  {

  DateTime _schInDt = DateTime.now();
  final TextEditingController _selInDt    = TextEditingController();
  final TextEditingController _binValue = TextEditingController();

  final FocusNode _scanFocus = FocusNode();
  final TextEditingController _scanValue = TextEditingController();

  List<dynamic> _plantList = [];
  List<dynamic> _slocList = [];
  dynamic _plantValue  = null;
  dynamic _selLocVal = null;

  List<dynamic> _searchHeaderList = [['itemCd','packId'],'qty','lotNo'];
  List<dynamic> _searchHeaderList2 =  [['SHPR_ITEM_NM','PACK_ID'],'STOCK_QTY','LOT_NO'];
  List<dynamic> _searchList = [];


  _search() async {

    Map<String, dynamic> paramMap = {
      "PLANT_VALUE": _plantValue,
      "S_LOC": _selLocVal,
      "LOCATION_CD": _binValue.text,
    };

    _searchList = await transaction(context, "/STK0011/search.do", paramMap);
    _scanFocus.requestFocus();

    setState(() {
    });
  }

  Future<dynamic> callNavi(BuildContext context, [dynamic param]) async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => STK0011MP01(param: param)));

    if(result != null && result){
      _search();
    }
  }

  @override
  void initState() {
    super.initState();

    _selInDt.text = formatDate(_schInDt, [yyyy, '-', mm, '-', dd]);

    WidgetsBinding.instance.addPostFrameCallback((_) async =>
      await _plantSearch()
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleCMScan(String scannedValue) async {
    print("CM 타입 스캔 처리 시작: $scannedValue");

    // BIN NO scan
    if (scannedValue.startsWith(Constant.BIN_BARCODE_DELIMIT)) {
      scannedValue = scannedValue.replaceAll(Constant.BIN_BARCODE_DELIMIT, "");
      _binValue.text = scannedValue;
    }
    else{
      showInfoAlert_pda(context, "${Constant.BIN_BARCODE_DELIMIT}로 시작되는 Bin번호를 스캔해 주세요.");
    }

    setState(() {
      _search();
    });

    print("CM 타입 스캔 처리 완료");
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
      "ALL_FLAG" : "N",
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
    var color = 0xff453658;
    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: pageAppBar(context, "stockCheck"),
        body: Container(
          child: GestureDetector(
          onTap: (){
          CommonUtil.hideKeyboard();
          _scanFocus.requestFocus();
          },
          child: Column(
            children: <Widget> [
              _searchField(),
              CommonActionBtn(
                "btnSearch",
                height: 50,
                fontSize: 20,
                onPressed: () {
                  _search();
              },
              ),
              Expanded(child: CustomGrid(_searchHeaderList,_searchHeaderList2, _searchList,
                  onRefresh: () {
                    _search();
                  },
                  onTap :  ([rowData]){
                    callNavi(context, rowData).then((data)  {
                  });
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
              CommonText("plant", width: MediaQuery.of(context).size.width * 0.25,),
              CommonDropdown("W", _plantValue, _plantList, comboCallback, width : MediaQuery.of(context).size.width * 0.25-12.5, viewType: "CN",),
              CommonText("sloc", width: MediaQuery.of(context).size.width * 0.25,),
              CommonDropdown("Z", _selLocVal, _slocList, comboCallback, width : MediaQuery.of(context).size.width * 0.25-12.5, viewType: "CN",),
            ],
          ),

          Row(
            children: <Widget>[
              CommonText("bin", width: MediaQuery.of(context).size.width * 0.25,),
              CommonLocation(
                selLocVal: _binValue,
                width: MediaQuery.of(context).size.width * 0.75,
                onEditingComplete: (scannedValue) async {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
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
