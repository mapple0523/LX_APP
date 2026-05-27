import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonCustomer.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonMaterial.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/pages/common/commMatlInfo.dart';
import 'package:dtwms_app/pages/common/commOutNo.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class INN0003M extends StatefulWidget {
  INN0003M({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _INN0003M createState() => _INN0003M();
}

class _INN0003M extends State<INN0003M> {
  final TextEditingController _selLocVal = TextEditingController();
  final TextEditingController _selLotVal = TextEditingController();
  final TextEditingController _selPackVal = TextEditingController();
  final TextEditingController _selPutQtyVal = TextEditingController();

  final TextEditingController _plantVal = TextEditingController();
  final TextEditingController _sLocVal = TextEditingController();

  final TextEditingController _barcodeNo = TextEditingController();
  final TextEditingController _custName = TextEditingController();

  final TextEditingController _scanValue = TextEditingController();


  final FocusNode _fnOne = FocusNode();
  final FocusNode _fnTwo = FocusNode();
  final FocusNode _scanFocus = FocusNode();

  final TextEditingController _selPickDtFrom = TextEditingController();

  List<dynamic> _searchList = [];
  List<dynamic> _orderList = [{}];

  dynamic _plantValue  = null;
  dynamic _slocVal = null;
  List<dynamic> _plantList = [];
  List<dynamic> _slocList = [];

  bool _preReceiptChecked = false;

  String _custValue  = "";

  @override
  void dispose() {
    super.dispose();
  }

  DateTime _schPickDt = DateTime.now();

  void initStatus() {
    super.initState();

    _selPickDtFrom.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);

    _selLocVal.text = "RCVSTAGE";

    Future.delayed(Duration.zero, () async {
      await _plantSearch();
    });

  }

  Future<void> _search() async {
    // mounted 체크로 위젯이 아직 존재하는지 확인
    if (!mounted) return;

    Map<String, dynamic> param = {};

    param = {
      "ITEM_CD": _barcodeNo.text,
    };

    List<dynamic> rtnList = await transaction(context, "/inn/INN0003/selectMatlInfo.do", param);

    // mounted 다시 체크 (비동기 작업 후)
    if (!mounted) return;

    if (CommonUtil.isEmpty(rtnList)) {
      _searchList = [];
    } else {
      _searchList = rtnList;
      // 검색 결과가 있으면 _orderList도 업데이트 (화면에 반영하기 위해)
      if (_searchList.isNotEmpty) {
        _orderList = _searchList;

        _selLocVal.text =_searchList[0]['LOCATION_CD'];
      }
    }

    setState(() {});
  }

  Future<void> comboCallback(String id, dynamic code, dynamic name) async {
    print("comboCallback ${code} / ${name}");
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

    setState(() {});
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


  _saveInOrderItemPutInfo() async {

    // 자재명이 없을때
    if (CommonUtil.isNull(_barcodeNo.text)) {
      showInfoAlert_pda(context, "chkItemCd");
      _fnOne.requestFocus();
      return;
    }

    // 입고일자가 없을때
    if (CommonUtil.isNull(_selPickDtFrom.text)) {
      showInfoAlert_pda(context, "chkInDate");
      _fnOne.requestFocus();
      return;
    }

    // 입고위치가 없을때
    if (CommonUtil.isNull(_selLocVal.text)) {
      showInfoAlert_pda(context, "chkPutLoca");
      _fnOne.requestFocus();
      return;
    }

    // 입고수량이 없을때
    if (CommonUtil.isNull(_selPutQtyVal.text)) {
      showInfoAlert_pda(context, "chkPutQty");
      return;
    }

    // 입고수량이 0일때
    if (_selPutQtyVal.text == "0") {
      showInfoAlert_pda(context, "chkValidQty");
      return;
    }

    if(CommonUtil.isNull(_custName.text)){
      _custValue = "90020";
    }

    dynamic saveData;
    try {
      saveData = ConvertUtil.copyObject(widget.param);
    } catch (e) {
      print("ConvertUtil.copyObject 에러: $e");
      saveData = null;
    }

    if (saveData == null) {
      saveData = <String, dynamic>{};
      if (widget.param != null) {
        // saveData['IN_NO'] = widget.param['IN_NO'];
        //         // saveData['SHPR_ITEM_CD'] = widget.param['SHPR_ITEM_CD'];
      }
    }

    saveData['LOCATION_CD'] = _selLocVal.text;
    saveData['MATERIAL'] = _barcodeNo.text;
    saveData['SHPR_ITEM_CD'] = _barcodeNo.text;
    saveData['IN_QTY'] = _selPutQtyVal.text;
    saveData['STOCK_QTY'] = _selPutQtyVal.text;
    saveData['PACK_ID'] = _selPackVal.text;
    saveData['LOT_NO'] = _selLotVal.text;
    saveData['IN_DT'] = _selPickDtFrom.text;
    saveData['PLANT'] = _plantValue;
    saveData['SLOC'] = _slocVal;
    saveData['GRADE'] = _searchList.isNotEmpty ? _searchList[0]['ZZGRADE'] : null;
    saveData['CUST_CD'] = _custValue;
    saveData['ITEM_UNIT'] = _searchList.isNotEmpty ? _searchList[0]['ITEM_UNIT'] : null;
    saveData['SHPR_ITEM_DESC'] = _searchList.isNotEmpty ? _searchList[0]['ITEM_DESC'] : null;
    saveData['LOC_CHECK'] = _searchList.isNotEmpty ? _searchList[0]['LOC_CHECK'] : null;

    saveData['LABEL_PRINT_HEADER'] = {
      "MATL_CD": _barcodeNo.text,
      "LINE_CD": '',
      "TABLE": 'TBL_STOCK_INFO',
      "COLUMN": 'LP_BCD',
      "LABEL_TYPE": '10'
    };

    Map<String, dynamic> paramCopy = Map<String, dynamic>.from(saveData);
    saveData['LABEL_PRINT_DATA'] = [paramCopy];


    saveData['LABEL_YN'] = _preReceiptChecked ? 'Y' : 'N';


    List<Map<String, dynamic>> dataList = [saveData];

    print("saveData + $saveData");

    await transaction(context, "inn/INN0003/insertStockInfo.do", dataList,(status, data) {
      print(status);
      print(data);
      if (status == Constant.resSuccessCode) {
        showInfoAlert_pda(context, "alertPut");
        _orderList=[{}];

        _barcodeNo.text = "";
        _selPutQtyVal.text = "";
        _selPackVal.text = "";
        _selLotVal.text = "";
        _custValue = "90020";
        _custName.text = "";
        _selPickDtFrom.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);
        _selLocVal.text = "RCVSTAGE";

        _plantSearch();

        setState(() {

        });

      }
    });
  }

  Future<void> _handleCMScan(String scannedValue) async {
    print("CM 타입 스캔 처리 시작: $scannedValue");
    // BIN NO scan
    if (scannedValue.startsWith(Constant.BIN_BARCODE_DELIMIT)) {
      //  기존값이 있으면 변경 불가
      if ( _searchList.isNotEmpty && _searchList[0]['LOC_CHECK'] == 'Y') return;
      scannedValue = scannedValue.replaceAll(Constant.BIN_BARCODE_DELIMIT, "");
      _selLocVal.text = scannedValue;
    }
    else{
      _barcodeNo.text = scannedValue;
      _search();
    }
  }

  @override
  void initState() {
    super.initState();

    initStatus();
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: pageAppBar(context, "freeStocking"),
        body: FooterLayout(
            footer: CommonActionBtn(
              "freeStocking",
              onPressed: () {
                CommonUtil.hideKeyboard();
                _scanFocus.requestFocus();
                _saveInOrderItemPutInfo();
              },
            ),
            child: SingleChildScrollView(
                child: GestureDetector(
                    onTap: () {
                      CommonUtil.hideKeyboard();
                      _scanFocus.requestFocus();
                    },
                    child: Container(
                      height: CommonUtil.pageMaxHeight(context,-200),
                      child: Column(
                        children: <Widget>[
                          _itemPutContents(_orderList) // _searchList가 아닌 _orderList 사용
                        ],
                      ),
                    )
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

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("itemNm"),
              CommonMaterial(
                selMaterialVal: _barcodeNo,
                focusNode: _fnOne,
                param: {
                  'ITEM_NM' : _barcodeNo.text
                },
                onEditingComplete: ([result, itemData]) {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();

                  if (!mounted) return;
                  _search();
                },
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("itemCd"),
              CommonTextField(list[0]['ITEM_CD'] ?? '', enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("desc"),
              CommonTextField(trimmedItemDesc, enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("unit"),
              CommonTextField(list[0]['ITEM_UNIT'] ?? '',enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("grade"),
              CommonTextField(list[0]['ZZGRADE'] ?? '', enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("inDt"),
              CommonDatePicker(
                selConroller: _selPickDtFrom,
                clearEnabled: false,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("plant"),
              CommonDropdown("W", _plantValue, _plantList, comboCallback, viewType: "CN",),
            ],
          ),
          Row(
              children: <Widget>[
                CommonText("sloc"),
                CommonDropdown("Z", _slocVal, _slocList, comboCallback, viewType: "CN",),
              ]
          ),
          Row(
            children: <Widget>[
              CommonText("packId"),
              CommonTextField(
                _selPackVal,
                onEditingComplete: (result) {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("lotNo"),
              CommonTextField(
                _selLotVal,
                onEditingComplete: (result) {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Offstage(
                offstage: true,
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
              CommonText("putZone"),
              AbsorbPointer(
                absorbing: _searchList.isNotEmpty && _searchList[0]['LOC_CHECK'] == 'Y', // Y면 터치 차단
                child: Opacity(
                  opacity: (_searchList.isNotEmpty && _searchList[0]['LOC_CHECK'] == 'Y') ? 0.5 : 1.0,
                  child: CommonLocation(
                    selLocVal: _selLocVal,
                    focusNode: _fnTwo,
                    onEditingComplete: (result) {
                      CommonUtil.hideKeyboard();
                      _scanFocus.requestFocus();
                    },
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("inQty"),
              CommonTextField(
                _selPutQtyVal,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onEditingComplete: (result) {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("공급사"),
              CommonCustomer(
                selCustVal: _custName,
                onEditingComplete: (result) {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();

                  if(!CommonUtil.isEmpty(result) && result is Map) {
                    _custValue = result['CUST_CD'];
                  }else{
                    if(CommonUtil.isNull(_custName.text)){
                      _custValue = "90020";
                    }
                  }

                  print(_custValue);
                },
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("라밸발행여부"),
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
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}