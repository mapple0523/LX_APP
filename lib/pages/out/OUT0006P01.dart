import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class OUT0006P01 extends StatefulWidget {
  const OUT0006P01({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0006P01 createState() => _OUT0006P01();
}

class _OUT0006P01 extends State<OUT0006P01> {
  final TextEditingController _movingQty = TextEditingController();
  final TextEditingController _selLocVal = TextEditingController();
  final TextEditingController _scanValue = TextEditingController();
  final FocusNode _scanFocus = FocusNode();
  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();

  List<dynamic> _searchList = [];
  List<dynamic> _checkList = [];
  List<dynamic> _orderList = [{}];

  dynamic _custValue  = null;
  dynamic _toPlantValue  = null;
  dynamic _toSelLocVal = null;
  dynamic _checkOutVal = null;
  dynamic _packVal = null;
  dynamic _mtoStock = null;

  List<dynamic> _toPlantList = [];
  List<dynamic> _toSlocList = [];
  List<dynamic> _checkOutList = [{"CODE": null, "NAME": "없음"}];
  List<dynamic> _packList = [];
  List<dynamic> _mtoStockList = [];

  bool _preReceiptChecked = false;

  Future<void> _search() async {
    Map<String, dynamic> param = {};
    _searchList = [];

    param = {
      "SHPR_ITEM_CD": widget.param["SHPR_ITEM_CD"],
      "STOCK_SEQ": widget.param["STOCK_SEQ"],
      "LOCATION_CD": widget.param["LOCATION_CD"],
    };

    List<dynamic> rtnList =
    await transaction(context, "out/OUT0006/searchOutItemList.do", param);
    if (CommonUtil.isEmpty(rtnList)) {
      _searchList = [];
      _orderList = [{
        "PLANT": widget.param["PLANT"] ?? "",
        "SLOC": widget.param["SLOC"] ?? "",
        "ITEM_CD": widget.param["SHPR_ITEM_CD"] ?? "",
        "STOCK_QTY": widget.param["STOCK_QTY"] ?? "",
      }];
    }
    else {
      _searchList = rtnList;
      _orderList = rtnList;
      _packSearch();
    }

    print("_searchList + $rtnList");

    setState(() {
    });
  }

  Future<void> _insertPackId() async {
    print("_searchList + $_searchList");

    Map<String, dynamic> sourceData = CommonUtil.isEmpty(_searchList)
        ? widget.param
        : _searchList[0];

    double stockQty = double.tryParse(sourceData['STOCK_QTY']?.toString() ?? '0') ?? 0;
    double moveQty = double.tryParse(_movingQty.text) ?? 0;

    if (moveQty == 0) {
      showInfoAlert_pda(context, "0수량은 불출 할 수 없습니다.");
      return;
    }

    if (moveQty > stockQty) {
      showInfoAlert_pda(context, "이동수량이 재고수량을 초과할 수 없습니다");
      return;
    }

    if(CommonUtil.isNull(_movingQty.text)) {
      showInfoAlert_pda(context, "이동수량을 입력해주십시오");
      return;
    }

    if (_mtoStock != null) {
      double mtoStock = double.tryParse(_mtoStock.toString()) ?? 0;

      if (moveQty > mtoStock) {
        showInfoAlert_pda(context, "이동수량이 MTO재고수량을 초과할 수 없습니다");
        return;
      }
    }

    Map<String, dynamic> resultData = Map<String, dynamic>.from(sourceData);
    resultData['MOVE_QTY'] = _movingQty.text;
    resultData['CUST_CD'] = _custValue;
    resultData['TO_PLANT'] = _toPlantValue;
    resultData['TO_SLOC'] = _toSelLocVal;
    resultData['FROM_PLANT'] = resultData["PLANT"];
    resultData['FROM_SLOC'] = resultData["SLOC"];
    resultData['TO_LOCATION_CD'] = _selLocVal.text;
    resultData['TO_LIFNR'] = _checkOutVal;
    resultData['TO_KDAUF'] = _packVal;

    if (CommonUtil.isEmpty(_searchList)) {
      resultData['LOCATION_CD'] = 'RCVSTAGE';
    }

    print("반환할 데이터: $resultData");

    Navigator.pop(context, resultData);

    setState(() {});
  }

  Future<void> _cancelPackId() async {
    Map<String, dynamic> sourceData = CommonUtil.isEmpty(_searchList)
        ? widget.param
        : _searchList[0];

    double stockQty = double.tryParse(sourceData['STOCK_QTY']?.toString() ?? '0') ?? 0;
    double moveQty = double.tryParse(_movingQty.text) ?? 0;

    if (moveQty > stockQty) {
      showInfoAlert_pda(context, "이동수량이 재고수량을 초과할 수 없습니다");
      return;
    }

    if(CommonUtil.isNull(_movingQty.text)) {
      showInfoAlert_pda(context, "이동수량을 입력해주십시오");
      return;
    }

    Map<String, dynamic> resultData = Map<String, dynamic>.from(sourceData);
    resultData['MOVE_QTY'] = _movingQty.text;
    resultData['CUST_CD'] = _custValue;
    resultData['TO_PLANT'] = '';
    resultData['TO_SLOC'] = '';
    resultData['FROM_PLANT'] = resultData["PLANT"];
    resultData['FROM_SLOC'] = resultData["SLOC"];
    resultData['TO_LOCATION_CD'] = 'SCRAPSTAGE';
    resultData['TO_BWART'] = '551';

    if (CommonUtil.isEmpty(_searchList)) {
      resultData['LOCATION_CD'] = 'RCVSTAGE';
    }

    print("반환할 데이터: $resultData");

    Navigator.pop(context, resultData);

    setState(() {});
  }

  Future<void> _toPlantSearch() async {
    Map<String, dynamic> param = {};
    _toPlantList = [];

    List<dynamic> rtnList =
    await transaction(context, "out/OUT0006/searchPlant.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _toPlantList = [];
      _toPlantValue = null; // 리스트가 비어있으면 null로 설정
    } else {
      _toPlantList = rtnList;
      // 첫 번째 항목을 기본값으로 설정
      if (_toPlantList.isNotEmpty) {
        _toPlantValue = _toPlantList[0]["CODE"];

        _tosLocSearch(_toPlantValue);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _CheckOutListSearch() async {
    Map<String, dynamic> param = {};
    _checkOutList = [];

    List<dynamic> rtnList =
    await transaction(context, "out/OUT0006/searchCheckOutList.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _checkOutList = [{"CODE": null, "NAME": "없음"}];
      _checkOutVal = null; // 리스트가 비어있으면 null로 설정
    } else {
      _checkOutList = rtnList;
      // 첫 번째 항목을 기본값으로 설정
      if (_toPlantList.isNotEmpty) {
        _checkOutVal = _checkOutList[0]["CODE"];
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _tosLocSearch(String code) async {
    Map<String, dynamic> param = {};
    _toSlocList = [];

    param = {
      "PLANT": code,
    };

    List<dynamic> rtnList =
    await transaction(context, "out/OUT0004/searchSLoc.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _toSlocList = [];
      _toSelLocVal = null; // 리스트가 비어있으면 null로 설정
    } else {
      _toSlocList = rtnList;
      // 첫 번째 항목을 기본값으로 설정
      if (_toSlocList.isNotEmpty) {
        _toSelLocVal = _toSlocList[0]["CODE"];
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> comboCallback(String id, dynamic code, dynamic name) async {
    if(id == "WT") {  // toPlant 변경
      _toPlantValue = code;
      _tosLocSearch(code);
    } else if(id == "ZT") {  // toSloc 변경
      _toSelLocVal = code;
    } else if(id == "OT") {
      _checkOutVal = code;
    } else if(id == Constant.LOCATION_TYPE_W) {
      _custValue = code;
    } else if(id == "PT"){
      _packVal = code;
      _salesOrderCheck();
    }

    setState(() {});
  }

  Future<void> checkBoxItemCheck() async {
    // 조회후 완제품이면 체크가 안되도록, 원자재일경우에만 체크가 되도록
    Map<String, dynamic> param = {};
    _checkList = [];

    param = {
      'ITEM_CD': _orderList[0]['ITEM_CD'],
    };

    // 조회후 완제품이면 체크가 안되도록, 원자재일경우에만 체크가 되도록
    List<dynamic> rtnList =
    await transaction(context, "out/OUT0006/searchOutsourceCheck.do", param);

    _checkList = rtnList;

    if(rtnList[0]['CHECK_YN'] == 'Y') {

      _toPlantList = [];
      _toSlocList = [];
      setState(() {
        _toPlantList = [{"CODE": '', "NAME": "없음"}];
        _toPlantValue = '';

        _toSlocList = [{"CODE": '', "NAME": "없음"}];
        _toSelLocVal = '';
      });

      _CheckOutListSearch();
    } else {
      showInfoAlert_pda(context, "원자재만 선택이 가능합니다.");
      _toPlantSearch();
      _preReceiptChecked = false;
    }

    setState(() {});
  }

  Future<void> _handleCMScan(String scannedValue) async {
    print("CM 타입 스캔 처리 시작: $scannedValue");
    // BIN NO scan
    if (scannedValue.startsWith(Constant.BIN_BARCODE_DELIMIT)) {
      scannedValue = scannedValue.replaceAll(Constant.BIN_BARCODE_DELIMIT, "");
      _selLocVal.text = scannedValue;
    }
    else{
      showInfoAlert_pda(context, "${Constant.BIN_BARCODE_DELIMIT}로 시작되는 Bin번호를 스캔해 주세요.");
    }
  }

  Future<void> _packSearch() async {
    Map<String, dynamic> param = {};

    param = {
      "SHPR_ITEM_CD": widget.param["SHPR_ITEM_CD"],
      "LOT_NO": widget.param["LOT_NO"],
      "PLANT": _orderList[0]['PLANT'],
      "SLOC": _orderList[0]['SLOC'],
    };

    print("param + $param");

    List<dynamic> rtnList =
    await transaction(context, "out/OUT0010/searchPackList.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _packList = [];
      _packVal = null; // 리스트가 비어있으면 null로 설정
    } else {
      _packList = rtnList;
      // 첫 번째 항목을 기본값으로 설정
      if (_packList.isNotEmpty) {
        _packVal = _packList[0]["CODE"];

        _salesOrderCheck();
        //_tosLocSearch(_packVal);
      }
    }

    setState(() {
    });
  }

  Future<void> _salesOrderCheck() async {
    Map<String, dynamic> param = {};

    param = {
      "SHPR_ITEM_CD": widget.param["SHPR_ITEM_CD"],
      "LOT_NO": widget.param["LOT_NO"],
      "KDAUF": _packVal,
      "PLANT": _orderList[0]['PLANT'],
      "SLOC": _orderList[0]['SLOC'],
    };

    print("param + $param");
    
    // mto 재고조회
    List<dynamic> rtnList =
    await transaction(context, "out/OUT0010/searchMtoStockList.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _mtoStockList = [];
      _mtoStock = null; // 리스트가 비어있으면 null로 설정
    } else {
      _mtoStockList = rtnList;
      // 첫 번째 항목을 기본값으로 설정
      if (_mtoStockList.isNotEmpty) {
        _mtoStock = _mtoStockList[0]["STOCK_QTY"];
      }
    }

    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();

    _selLocVal.text = 'RCVSTAGE';

    Future.delayed(Duration.zero, () {
      if(!CommonUtil.isEmpty(widget.param))
        _search();
        _toPlantSearch();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: pageAppBar(context, "stockInfoDetail"),
        body: FooterLayout(
            footer: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 두 개의 버튼을 나란히 배치
                  Row(
                    children: [
                      CommonActionBtn(
                        "폐기",
                        width: screenWidth * 0.5 - 10,
                        onPressed: () async {
                          _cancelPackId();
                        },
                      ),
                      CommonActionBtn(
                        "btnRelease",
                        width: screenWidth * 0.5 - 10,
                        onPressed: () async {
                          _insertPackId();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            child: SingleChildScrollView(
                child: GestureDetector(
                  onTap: () {
                    CommonUtil.hideKeyboard();
                    _scanFocus.requestFocus();
                  },
                  child: _itemPutContents(_orderList), // ✅ Container와 Column 감싸기 제거
                )
            )
        )
    );
  }


  Widget _itemPutContents(List<dynamic> list) {

    String itemDesc = list[0]['ITEM_DESC'] ?? '';
    String trimmedItemDesc = '';
    if(!CommonUtil.isNull(itemDesc)){
      trimmedItemDesc = itemDesc.length > 20 ? itemDesc.substring(0, 20) + '...' : itemDesc;
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
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
          Row(
            children: <Widget>[
              CommonText("storageNm"),
              CommonTextField(list[0]['LOCATION_CD'] ?? '', enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("inDt"),
              CommonTextField(list[0]['INPUT_DATE'] ?? '', enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("itemNm"),
              CommonTextField(list[0]['ITEM_CD'] ?? '', enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("lotNo"),
              CommonTextField(list[0]['LOT_NO'] ?? '', enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("bin"),
              CommonTextField(list[0]['LOCATION_CD'] ?? '', enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("qty"),
              CommonTextField(list[0]['STOCK_QTY'] ?? '', enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("unit"),
              CommonTextField(list[0]['ITEM_UNIT'] ?? '', enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("fromPlant", width: MediaQuery.of(context).size.width * 0.2),
              //CommonDropdown("WF", _fromPlantValue, _fromPlantList, comboCallback, width : MediaQuery.of(context).size.width * 0.3-12.5, enabled: false,),
              CommonTextField(list[0]['PLANT'] ?? '', width : MediaQuery.of(context).size.width * 0.3-12.5, enabled: false),
              CommonText("fromSloc", width: MediaQuery.of(context).size.width * 0.2),
              //CommonDropdown("ZF", _fromSelLocVal, _fromSlocList, comboCallback, width : MediaQuery.of(context).size.width * 0.3-12.5, enabled: false),
              CommonTextField(list[0]['SLOC'] ?? '', width : MediaQuery.of(context).size.width * 0.3-12.5, enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("toPlant", width: MediaQuery.of(context).size.width * 0.2),
              CommonDropdown("WT", _toPlantValue, _toPlantList, comboCallback, width : MediaQuery.of(context).size.width * 0.3-12.5, viewType: "CN",),
              CommonText("toSloc", width: MediaQuery.of(context).size.width * 0.2),
              CommonDropdown("ZT", _toSelLocVal, _toSlocList, comboCallback, width : MediaQuery.of(context).size.width * 0.3-12.5, viewType: "CN",),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("bin"),
              CommonLocation(
                selLocVal: _selLocVal,
                focusNode: fnTwo,
                onEditingComplete: (result) {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("moveQty"),
              CommonTextField(
                _movingQty,
                enabled: true,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("판매오더"),
              CommonDropdown("PT", _packVal, _packList, comboCallback),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("외주임가공 여부"),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                height: 24,
                child: Checkbox(
                  value: _preReceiptChecked,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  onChanged: (bool value) {
                    setState(() {
                      _preReceiptChecked = value;
                    });
                    if (value) {
                      // 체크시 원자재 여부 확인
                      checkBoxItemCheck();
                    } else {
                      // 체크 해제시 toPlant 다시 조회
                      _toPlantSearch();

                      _checkOutList = [{"CODE": null, "NAME": "없음"}];
                      _checkOutVal = null;
                    }
                  },
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("외주임가공"),
              CommonDropdown("OT", _checkOutVal, _checkOutList, comboCallback),
            ],
          ),
        ],
    );
  }
}