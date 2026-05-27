import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class INN0006M extends StatefulWidget {
  @override
  _INN0006M createState() => _INN0006M();
}

class _INN0006M extends State<INN0006M> {
  final FocusNode _scanFocus = FocusNode();
  final FocusNode fnOne = FocusNode();

  final TextEditingController _scanValue = TextEditingController();
  final TextEditingController _lotValue = TextEditingController();
  final TextEditingController _selLocVal = TextEditingController();
  final TextEditingController _drumQty = TextEditingController();
  final TextEditingController _selMehqValue = TextEditingController();
  final TextEditingController _selAo30Value = TextEditingController();
  final TextEditingController _rmkValue = TextEditingController();

  List<dynamic> _gradeList = [];
  List<dynamic> _sLocList = [];
  List<dynamic> _plantList = [];
  List<dynamic> _netWtList = [];
  List<dynamic> _lotNoList = [];

  dynamic _selGradeValue;
  dynamic _selNetValue;
  dynamic _selSLocValue;
  dynamic _selPlantValue;

  dynamic _errorMsg;

  bool _isNetWtDisabled = false;

  Future<void> _searchOrderInfo() async {

    Map<String, dynamic> param = {};
    param['LOT_NO']        = _lotValue.text;

    // List<dynamic> rtnList =  await transaction(context, "inn/INN0006/searchProdList.do", param);
    //
    // if (CommonUtil.isEmpty(rtnList))
    //   _orderList = [];
    // else
    //   _orderList = rtnList;

    _scanFocus.requestFocus();

    setState(() {});
  }

  Future<void> _searchLotList() async {

    Map<String, dynamic> param = {};
    param['LOT_NO']       = _lotValue.text;
    param['DRUM_QTY']     = _drumQty.text;
    param['STOCK_QTY']    = _selNetValue;
    param['LOCATION_CD']  = _selLocVal.text;
    param['ITEM_CD']      = _selGradeValue;
    param['PLANT']        = _selPlantValue;
    param['SLOC']         = _selSLocValue;
    param['MEHQ']         = _selMehqValue.text;
    param['AO30']         = _selAo30Value.text;
    param['REMARK']       = _rmkValue.text;

    List<dynamic> rtnList =  await transaction(context, "inn/INN0006/searchLotList.do", param);

    if (CommonUtil.isEmpty(rtnList))
      _lotNoList = [];
    else {
      _lotNoList = rtnList;

      _selMehqValue.text = rtnList[0]['MEHQ'];
      _selAo30Value.text = rtnList[0]['AO30'];
      _rmkValue.text = rtnList[0]['REMARK'];
      _selNetValue = rtnList[0]['ITEM_WT'];

      _isNetWtDisabled = !CommonUtil.isEmpty(rtnList[0]['ITEM_WT']);
    }

    _scanFocus.requestFocus();

    setState(() {});
  }

  Future<void> _insertOrderInfo() async {
    if (CommonUtil.isNull(_drumQty.text)) {
      showInfoAlert_pda(context, "chkDrumQty");
      return;
    }

    bool result = await confirmDialog(context, "확인", "실적등록을 하시겠습니까?");
    if (!result) return;

    await _doInsert(reInsertYn: 'N');
  }

  Future<void> _doInsert({String reInsertYn = 'N'}) async {
    Map<String, dynamic> param = {};
    param['LOT_NO']       = _lotValue.text;
    param['DRUM_QTY']     = _drumQty.text;
    param['STOCK_QTY']    = _selNetValue;
    param['LOCATION_CD']  = _selLocVal.text;
    param['GRADE']        = _selGradeValue;
    param['PLANT']        = _selPlantValue;
    param['SLOC']         = _selSLocValue;
    param['MEHQ']         = _selMehqValue.text;
    param['AO30']         = _selAo30Value.text;
    param['REMARK']       = _rmkValue.text;
    param['RE_INSERT_YN'] = reInsertYn;   // ← 플래그 추가

    double drumQty  = double.tryParse(_drumQty.text) ?? 0;
    double netValue = double.tryParse(_selNetValue?.toString() ?? "0") ?? 0;
    param['SUM_QTY'] = (drumQty * netValue).toString();

    await transaction(
        context, "inn/INN0006/insertWoInfo.do", param,
            (status, data) async {

              if (status == Constant.resSuccessCode) {
                if (data != null && data['DUPLICATE_YN'] == 'Y') {
                  // 서버에서 만든 메시지로 다이얼로그
                  String msg = data['MSG'] ?? "";
                  bool confirm = await confirmDialog(context, "확인", msg);
                  if (confirm) {
                    await _doInsert(reInsertYn: 'Y');
                  }
                } else {
                  // 정상 등록 완료
                  _clearFields();
                  showInfoAlert_pda(context, "생산등록이 완료되었습니다.");
                }
              }
        }
    );

    _scanFocus.requestFocus();
    setState(() {});
  }

  void _clearFields() {
    _lotValue.clear();
    _drumQty.clear();
    _selMehqValue.clear();
    _selAo30Value.clear();
    _rmkValue.clear();
    setState(() {
      _selGradeValue = _gradeList.isNotEmpty ? _gradeList[0]['CODE'] : null;
      _selNetValue   = _netWtList.isNotEmpty ? _netWtList[0]['CODE'] : null;
      _isNetWtDisabled = false;
    });
  }

  Future<void> _cancelOrderInfo(String msg) async {
    Map<String, dynamic> param = {};
    param['LOT_NO'] = _lotValue.text;
    param['DRUM_QTY'] = _drumQty.text;
    param['STOCK_QTY'] = _selNetValue;
    param['LOCATION_CD'] = _selLocVal.text;
    param['GRADE'] = _selGradeValue;
    param['PLANT'] = _selPlantValue;
    param['SLOC'] = _selSLocValue;

    double drumQty = double.tryParse(_drumQty.text) ?? 0;
    double netValue = double.tryParse(_selNetValue?.toString() ?? "0") ?? 0;
    double sumQty = drumQty * netValue;
    param['SUM_QTY'] = sumQty.toString();

    bool result = await confirmDialog(context, "확인", msg);

    if (result) {
      await transaction(
          context, "inn/INN0006/deleteWoInfo.do", param, (status, data) {
        if (status == Constant.resSuccessCode) {
          showInfoAlert_pda(context, "취소되었습니다.");
          _searchOrderInfo();
        }
      });

      _scanFocus.requestFocus();

      setState(() {});
    }
  }

  Future<void> _searchSLocCombo() async {

    Map<String, dynamic> param = {};

    List<dynamic> rtnList =
    await transaction(context, "inn/INN0006/searchSLocList.do", param);

    if (CommonUtil.isEmpty(rtnList))
      _sLocList = [];
    else {
      _sLocList = rtnList;
      _selSLocValue = _sLocList[0]['CODE'];
      _searchPlantCombo();
    }

    setState(() {});
  }

  Future<void> _searchPlantCombo() async {

    Map<String, dynamic> param = {};

    param['SLOC'] = _selSLocValue;

    List<dynamic> rtnList =
    await transaction(context, "inn/INN0006/searchPlantList.do", param);

    if (CommonUtil.isEmpty(rtnList))
      _plantList = [];
    else {
      _plantList = rtnList;
      _selPlantValue = _plantList[0]['CODE'];
    }

    setState(() {});
  }

  Future<void> _searchGradeCombo() async {

    Map<String, dynamic> param = {};

    List<dynamic> rtnList =
    await transaction(context, "inn/INN0006/searchGradeList.do", param);

    if (CommonUtil.isEmpty(rtnList))
      _gradeList = [];
    else {
      _gradeList = rtnList;
      _selGradeValue = _gradeList[0]['CODE'];
    }

    setState(() {});
  }

  Future<void> _searchNetCombo() async {

    Map<String, dynamic> param = {};

    List<dynamic> rtnList =
    await transaction(context, "inn/INN0006/searchNetWtList.do", param);

    if (CommonUtil.isEmpty(rtnList))
      _netWtList = [];
    else {
      _netWtList = rtnList;
      _selNetValue = _netWtList[0]['CODE'];
    }

    setState(() {});
  }

  Future<void> _handleCMScan(String scannedValue) async {

    print("CM 타입 스캔 처리 시작: $scannedValue");

    try {
      // BIN NO scan
      if (scannedValue.startsWith(Constant.BIN_BARCODE_DELIMIT)) {
        scannedValue = scannedValue.replaceAll(Constant.BIN_BARCODE_DELIMIT, "");
        _selLocVal.text = scannedValue;
      }
      else {
        // 바코드에 /가 있을경우
        if (scannedValue.contains('/')) {
          List<String> parts = scannedValue.split('/');

          if (parts.length >= 4) {
            String gradeCode = parts[0].trim();

            var matchedGrade = _gradeList.firstWhere(
                    (grade) => grade['CODE'] == gradeCode,
                orElse: () => null
            );

            if (matchedGrade != null) {
              setState(() {
                _selGradeValue = matchedGrade['CODE'];
              });
            }

            String lotNo = parts[1].trim();
            _lotValue.text = lotNo;

            String mehqPart = parts[2].trim();
            RegExp mehqRegex = RegExp(r'MEHQ\s+(\d+)');
            Match mehqMatch = mehqRegex.firstMatch(mehqPart);
            if (mehqMatch != null) {
              _selMehqValue.text = mehqMatch.group(1);
            }

            String ao30Part = parts[3].trim();
            RegExp ao30Regex = RegExp(r'AO30\s+(\d+)');
            Match ao30Match = ao30Regex.firstMatch(ao30Part);
            if (ao30Match != null) {
              _selAo30Value.text = ao30Match.group(1);
            }

            setState(() {});
            _searchOrderInfo();
          } else {
            showInfoAlert_pda(context, "스캔 데이터 형식이 올바르지 않습니다.");
            return;
          }

        } else {
          // 바코드 단일 형식

          _lotValue.text = scannedValue.trim();
          // Q(IBMAD), F(MAAD), E(MMAD), G(NBMAD)
          if(scannedValue.startsWith("Q")){_selGradeValue = "IBMAD";}
          else if(scannedValue.startsWith("F")){_selGradeValue = "MAAD";}
          else if(scannedValue.startsWith("E")){_selGradeValue = "MMAD";}
          else if(scannedValue.startsWith("G")){_selGradeValue = "NBMAD";}
          else{
            showInfoAlert_pda(context, "스캔 데이터 형식이 올바르지 않습니다.");
            return;
          }

          setState(() {});
          _searchOrderInfo();
        }
      }

      // 바코드를 조회했을때 값이 있으면 MEHQ, AO30, BatchMemo 박아주기
      _searchLotList();

    } catch (e) {
      print("스캔 데이터 파싱 오류: $e");
      showInfoAlert_pda(context, "스캔 데이터 형식이 올바르지 않습니다.");
      return;
    }

    print("CM 타입 스캔 처리 완료");
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchGradeCombo();
      _searchNetCombo();
      _searchSLocCombo();

      _selLocVal.text = "PROCSTAGE";
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
      appBar: pageAppBar(context, "DrumProductionRegister"),
      body: FooterLayout(
        footer: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CommonActionBtn(
                    "performanceCancel",
                    width: screenWidth * 0.5 - 10,
                    onPressed: () {
                      _errorMsg = "실적등록을 취소하시겠습니까?";
                      _cancelOrderInfo(_errorMsg);
                      _scanFocus.requestFocus();
                    },
                  ),
                  CommonActionBtn(
                    "performanceRegistration", // 저장 버튼 (실제 텍스트는 다국어 키에 맞게 수정)
                    width: screenWidth * 0.5 - 10,
                    onPressed: () {
                      _insertOrderInfo();
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
            _scanFocus.requestFocus();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                _searchField(),
                // Expanded(
                //   child: CustomGrid(
                //       ['lotNo', 'weight', 'performanceRegistrationDt','status'],
                //       ['LOT_NO', 'PROD_QTY', 'PROD_DT_NM','PROD_OUT_STATUS_NM'],
                //       _orderList,
                //       onTap: ([rowData]) {
                //       },
                //       onRefresh: () {
                //         _searchOrderInfo();
                //       }
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchField() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
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
              CommonText(
                "lotNo",
              ),
              CommonTextField(
                  _lotValue,
                  onEditingComplete: (scannedValue) async {
                    CommonUtil.hideKeyboard();
                    _scanFocus.requestFocus();
                  }
               ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText(
                "grade",
              ),
              CommonDropdown(null,_selGradeValue, _gradeList, (id, code, name){
                setState(() {
                  _selGradeValue = code;
                });
              }),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("drumProduction"),
              CommonTextField(_drumQty, keyboardType: TextInputType.number),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("netWtKg"),
              CommonDropdown(null,_selNetValue, _netWtList, (id, code, name){
                setState(() {
                  _selNetValue = code;
                });
              },
                enabled: !_isNetWtDisabled,)
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("bin"),
              CommonLocation(
                selLocVal: _selLocVal,
                param: {'LOCATION_KIND': 'P'},
                focusNode: fnOne,
                onEditingComplete: (result) {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText(
                "mehq",
              ),
              CommonTextField(_selMehqValue,  keyboardType: TextInputType.number),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText(
                "ao30",
              ),
              CommonTextField(_selAo30Value,  keyboardType: TextInputType.number),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText(
                "plant",
              ),
              CommonDropdown(null,_selPlantValue, _plantList, (id, code, name){
                setState(() {
                  _selPlantValue = code;
                });
              }),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText(
                "sloc",
              ),
              CommonDropdown(null,_selSLocValue, _sLocList, (id, code, name){
                setState(() {
                  _selSLocValue = code;
                  _searchPlantCombo();
                });
              }),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText(
                "BatchMemo",
                height: screenHeight * 0.2,
              ),
              CommonTextField(_rmkValue,
                  height: screenHeight * 0.2,
                  maxLines: 6,),
            ],
          ),
        ],
      ),
    );
  }
}
