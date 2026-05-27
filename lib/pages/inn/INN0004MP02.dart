import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/commOutNo.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/common/popup.dart';
import 'package:dtwms_app/pages/sys/function.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class INN0004MP02 extends StatefulWidget {
  const INN0004MP02({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _INN0004MP02 createState() => _INN0004MP02();
}

class _INN0004MP02 extends State<INN0004MP02> {
  final FocusNode _scanFocus = FocusNode();
  final FocusNode fnFive = FocusNode();

  final TextEditingController _scanValue = TextEditingController();
  final TextEditingController _plantValue = TextEditingController();
  final TextEditingController _gradeValue = TextEditingController();
  final TextEditingController _lotValue = TextEditingController();
  final TextEditingController _selLocVal = TextEditingController();
  final TextEditingController _selBinVal = TextEditingController();

  String _lastScannedValue = "";

  DateTime _schPickDt = DateTime.now();
  final TextEditingController _selPickDtFrom = TextEditingController();

  dynamic popUpYn = "N";

  bool _isProcessing = false;

  List<dynamic> _searchList = [];
  List<dynamic> _seletedRecords = [];
  List<dynamic> _searchCustOutList = [];
  int _focusIndex = 0;

  void _selectItem(Map<String, dynamic> item) {
    bool isCurrentlySelected = _seletedRecords.any((selectedItem) => selectedItem['PACK_ID'] == item['PACK_ID']);

    if (isCurrentlySelected) {
      _seletedRecords.clear();

      if (item['PROD_OUT_STATUS'] == 'RS') {
        item["ROW_COLOR"] = Colors.blue;
      } else {
        item["ROW_COLOR"] = Colors.transparent;
      }

      _gradeValue.text = '';
      _selLocVal.text = '';

      print("선택 해제됨: ${item['PACK_ID']}");
    } else {
      for (var selectedItem in _seletedRecords) {
        var originalItem = _searchList.firstWhere(
              (searchItem) => searchItem['PACK_ID'] == selectedItem['PACK_ID'],
          orElse: () => null,
        );
        if (originalItem != null) {
          if (originalItem['PROD_OUT_STATUS'] == 'RS') {
            originalItem["ROW_COLOR"] = Colors.blue;
          } else {
            originalItem["ROW_COLOR"] = Colors.transparent;
          }
        }
      }

      _seletedRecords.clear();
      _seletedRecords.add(Map<String, dynamic>.from(item));

      item["ROW_COLOR"] = Colors.orange;

      _gradeValue.text = item['ZZGRADE'] ?? '';
      _selLocVal.text = (item['PROD_QTY'] ?? '').toString();
      _lotValue.text = item['PACK_ID'] ?? '';

      print("선택됨: ${item['PACK_ID']}");
    }

    print("현재 선택된 항목 수: ${_seletedRecords.length}");
    _focusIndex = item["INDEX"];
    setState(() {});
  }

  Future<void> _search() async {
    Map<String, dynamic> param = {};
    _searchList = [];
    // _seletedRecords = []; // 이 줄을 제거 - 선택된 항목 유지

    if (CommonUtil.isNull(_lotValue.text)) {
      setState(() {
        _searchList = [];
      });
      return;
    }
    param = {
      "LOT_NO": _lotValue.text
    };

    // 먼저 현재작업번호와 같은지 확인
    List<dynamic> woNoList = await transaction(context, "/inn/INN0004/selectWoNoList.do", param);

    if(woNoList.length > 1){
      final result = await showSmallPopup(context, woNoList, ["PACK_ID","BATCH","MATERIAL"]);
      // 선택을 하지 않을 경우 종료
      if(result == null){
        return;
      }

      woNoList.clear();
      woNoList.add(result);
    }

    print("wonoList + $woNoList");

    param['MATERIAL'] = woNoList[0]['MATERIAL'];

    List<dynamic> rtnList = await transaction(context, "/inn/INN0004/selectProdOutList.do", param);
    if (CommonUtil.isEmpty(rtnList))
      _searchList = [];
    else {
      for (int i =0; i < rtnList.length; i++) {
        if (rtnList[i]['PROD_OUT_STATUS'] == 'RS') {
          rtnList[i]["ROW_COLOR"] = Colors.blue;
        } else {
          rtnList[i]["ROW_COLOR"] = Colors.transparent;
        }
        // grid data 인덱스 추가
        rtnList[i]["INDEX"] = i;
      }

      _searchList = rtnList;
      _lastScannedValue = _lotValue.text;
      _updateValuesFromSearchList();

      var matchingItem = _searchList.firstWhere(
            (item) => item['PACK_ID'] == _lotValue.text,
        orElse: () => null,
      );

      if (matchingItem != null) {
        //_focusIndex = matchingItem["INDEX"];
        _selectItem(matchingItem);
        return;
      }
    }

    setState(() {});
  }

  Future<void> _handleSecondAction() async {

    String woNo = _seletedRecords.first['WO_NO'] ?? '';

    String shprItemcd = _seletedRecords.first['MATERIAL'] ?? '';

    String packSeq = _seletedRecords.first['PACK_SEQ'].toString() ?? '';

    List<dynamic> updateList = [
      {
        "LOT_NO": _lotValue.text,
        "PACK_ID": _lotValue.text,
        "LOCATION_CD": _selBinVal.text,
        "WO_NO" : woNo,
        "MATERIAL" : shprItemcd,
        "PACK_SEQ" : packSeq,
      }
    ];

    bool isSuccess = false;
    await transaction(context, "/inn/INN0004/updateProdOut.do", updateList, (status, data) async {
      if (status == Constant.resSuccessCode) isSuccess = true;
    });

    if (isSuccess) {
      _gradeValue.clear();
      _selLocVal.clear();
      await _search();
      _lotValue.clear();
    }
  }

  Future<void> _handleSecondActionDelete() async {

    String woNo = _seletedRecords.first['WO_NO'] ?? '';

    String shprItemcd = _seletedRecords.first['MATERIAL'] ?? '';

    String packSeq = _seletedRecords.first['PACK_SEQ'].toString() ?? '';

    List<dynamic> updateList = [
      {
        "LOT_NO": _lotValue.text,
        "PACK_ID": _lotValue.text,
        "LOCATION_CD": _selBinVal.text,
        "BATCH" : _seletedRecords.first['BATCH'].toString() ?? '',
        "PROD_DATE" : _seletedRecords.first['PROD_DATE'].toString() ?? '',
        "WO_NO" : woNo,
        "MATERIAL" : shprItemcd,
        "PACK_SEQ" : packSeq,
      }
    ];

    bool isSuccess = false;

    await transaction(context, "/inn/INN0004/deleteProdOut.do", updateList, (status, data) async {
      if (status == Constant.resSuccessCode) isSuccess = true;
    });

    if (isSuccess) {
      _gradeValue.clear();
      _selLocVal.clear();
      await _search();
      _lotValue.clear();
    }
  }

  Future<void> _updateValuesFromSearchList() async {
    if (_searchList.isEmpty || _lastScannedValue == null || _lastScannedValue.isEmpty) {
      return;
    }

    // _searchList에서 _lotValue와 일치하는 항목들 찾기
    List<dynamic> matchingItems = _searchList.where(
          (item) => item['PACK_ID'] == _lastScannedValue,
    ).toList();

    if (matchingItems.isEmpty) return;
    final matchingItem = matchingItems.first;

    _gradeValue.text = matchingItem['ZZGRADE'] ?? '';
    _selLocVal.text = (matchingItem['PROD_QTY'] ?? '').toString();
    _plantValue.text = (matchingItem['RATE'] ?? '').toString();
    _selBinVal.text = "PROCSTAGE";
    //_gradeValue.text = '';
    //_selLocVal.text = '';
    //_lotValue.text = '';

    print("두 번째 스캔: $matchingItem");
    setState(() {});
  }

  Future<int> _searchOutCnt() async {

    Map<String, dynamic> param = {
      "PACK_ID": _lotValue.text
    };
    dynamic outCnt = await transaction(context, "INN0004/searchOutCnt.do", param);

    return outCnt;
  }

  Future<dynamic> _movePageSelection(BuildContext context, [dynamic param]) async {
    _searchList = [];
    _searchCustOutList = [];
    dynamic result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OutNoPage(param: param)));
    if(!CommonUtil.isEmpty(result) && result is List) {
      return result;
    }
  }

  Future<void> _handleCMScan(String scannedValue) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      scannedValue = CommonUtil.parseLotNo(scannedValue);

      if (scannedValue.startsWith(Constant.BIN_BARCODE_DELIMIT)) {
        _selBinVal.text = scannedValue.replaceAll(Constant.BIN_BARCODE_DELIMIT, "");
        return;
      }

      _lotValue.text = scannedValue;

      var matchingItem = _searchList.firstWhere(
            (item) => item['PACK_ID'] == scannedValue,
        orElse: () => null,
      );

      if (scannedValue == _lastScannedValue) {
        if (matchingItem != null) {
          bool isCurrentlySelected = _seletedRecords.any((s) => s['PACK_ID'] == matchingItem['PACK_ID']);
          if (!isCurrentlySelected) {
            _seletedRecords.clear();
            _seletedRecords.add(Map<String, dynamic>.from(matchingItem));
            matchingItem["ROW_COLOR"] = matchingItem['PROD_OUT_STATUS'] == 'RS' ? Colors.blue : Colors.orange;
            _gradeValue.text = matchingItem['ZZGRADE'] ?? '';
            _selLocVal.text = (matchingItem['PROD_QTY'] ?? '').toString();
            _lotValue.text = matchingItem['PACK_ID'] ?? '';
            setState(() {});
          }
        }

        if (matchingItem != null && matchingItem['PROD_OUT_STATUS'] == 'RS') {

          final confirmed = await confirmDialog(context, "실적취소", "실적등록이 완료된 포장입니다. 실적등록을 취소하시겠습니까?");

          if (confirmed) await _handleSecondActionDelete();
        } else {
          await _handleSecondAction();
        }
      } else {
        Map<String, dynamic> param = {"LOT_NO": _lotValue.text};

        if (_seletedRecords.isEmpty) {
          await _search();
        } else {
          var selectedWoNo = _seletedRecords[0]["BATCH"];
          List<dynamic> woNoList = await transaction(
              context, "/inn/INN0004/selectWoNoList.do", param);

          if (woNoList.length > 1) {
            final result = await showSmallPopup(
                context, woNoList, ["PACK_ID", "BATCH", "WO_NO"]);
            if (result == null) return;
            woNoList
              ..clear()
              ..add(result);
          }

          var validWoNoList = woNoList
              .where((item) => item != null && item["BATCH"] != null)
              .toList();
          var searchWoNo = validWoNoList[0]["BATCH"];

          if (selectedWoNo != searchWoNo) {
            final confirmed = await confirmDialog(context, "생산실적목록", "스캔한 포장번호는 다른 작업지시정보입니다. 해당 작업지시의 생산실적 목록을 조회하시겠습니까?");
            if (confirmed) await _search();
          } else {
            await _search();
          }
        }

        var newMatchingItem = _searchList.firstWhere(
              (item) => item['PACK_ID'] == scannedValue,
          orElse: () => null,
        );

        if (newMatchingItem != null) {
          if (newMatchingItem['PROD_OUT_STATUS'] == 'RS') {
            final confirmed = await confirmDialog(context, "실적취소", "실적등록이 완료된 포장입니다. 실적등록을 취소하시겠습니까?");
            if (confirmed) await _handleSecondActionDelete();
          } else {
            await _handleSecondAction();
          }
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      _selBinVal.text = await App_Function.GetLocation(context,"P");
      //ZebraDataWedgeListener.initFunc();

      //if(!CommonUtil.isEmpty(widget.param))
       // _search();
    });
    setState(() {

    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  bool _cancelDisable() {
    if (_seletedRecords.isEmpty) {
      return true;
    }

    return _seletedRecords.first['PROD_OUT_STATUS'] != 'RS';
  }

  bool _registrationDisable() {
    if (_seletedRecords.isEmpty) {
      return true;
    }

    return _seletedRecords.first['PROD_OUT_STATUS'] == 'RS';
  }

  // build 메서드에서 CustomGrid 부분 수정
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "productionRegister",false),
        body: FooterLayout(
          footer: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 두 개의 버튼을 나란히 배치
                Row(
                  children: [
                    CommonActionBtn(
                      "performanceCancel",
                      width: screenWidth * 0.4 - 10,
                      onPressed: _handleSecondActionDelete,
                      disabledBtn: _cancelDisable(),
                    ),
                    CommonActionBtn(
                      "performanceRegistration",
                      width: screenWidth * 0.6 - 10,
                      disabledBtn: _registrationDisable(),
                      onPressed: () async {
                        if (_seletedRecords.isEmpty) {
                          return;
                        }

                        List<dynamic> cleanedData = ConvertUtil.removeColumn(_seletedRecords, ["ROW_COLOR"]);

                        for (var item in cleanedData) {
                          item["LOT_NO"] = item["PACK_ID"];
                          item["LOCATION_CD"] = _selBinVal.text;
                        }

                        await transaction(context, "/inn/INN0004/updateProdOut.do", cleanedData, (status, data) {
                          if(status == Constant.resSuccessCode) {
                            _seletedRecords.clear();
                            _search();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          child: GestureDetector(
              onTap: () {
                CommonUtil.hideKeyboard();
              },
              child: Column(
                  children: <Widget>[
                    _searchField(),
                    Expanded(
                      child: CustomGrid([['lotNo','자재코드'], 'weight',['MEHQ','AO30'],'status','productionDate'],
                        [['PACK_ID','MATERIAL'], 'PROD_QTY',['MEHQ','AO30'],'PROD_OUT_STATUS_NM', 'PROD_DT_NM'],
                        _searchList,
                        focusIndex:_focusIndex,
                        onTap: (e) {
                          _selectItem(e);
                        },
                      ),
                    ),
                  ]
              )
          ),
        ));
  }

  Widget _searchField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Offstage(
                offstage: true, // false로 바꾸면 다시 보임!
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
              CommonText("lotNo"),
              CommonTextField(_lotValue,
                onEditingComplete: (result)  {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("grade"),
              CommonTextField(_gradeValue,
                enabled: false ,
                onEditingComplete: (nodeObj) {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("planProduction"),
              CommonTextField(_plantValue,
                enabled: false ,
                width: MediaQuery.of(context).size.width * 0.22 - 12.5,
                onEditingComplete: (nodeObj) {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
              ),
              CommonText("netWt"),
              CommonTextField(_selLocVal,
                  enabled: false ,
                  width: MediaQuery.of(context).size.width * 0.22 - 12.5,
                  onEditingComplete: (nodeObj) {
                    CommonUtil.hideKeyboard();
                    _scanFocus.requestFocus();
                  }),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("bin"),
              CommonLocation(
                  focusNode: fnFive,
                  selLocVal: _selBinVal,
                  param: {'LOCATION_KIND': 'P'},
                  onEditingComplete: (result) {
                    CommonUtil.hideKeyboard();
                    _scanFocus.requestFocus();
                  })
            ],
          ),
        ],
      ),
    );
  }
}