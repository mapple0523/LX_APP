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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class INN0005MP02 extends StatefulWidget {
  const INN0005MP02({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _INN0005MP02 createState() => _INN0005MP02();
}

class _INN0005MP02 extends State<INN0005MP02> {
  final FocusNode _scanFocus = FocusNode();
  final TextEditingController _scanValue = TextEditingController();
  final TextEditingController _lotValue = TextEditingController();
  final TextEditingController _selLocVal = TextEditingController();
  final TextEditingController _planQty = TextEditingController();

  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();
  final FocusNode fnThree = FocusNode();
  final FocusNode fnFour = FocusNode();

  bool _checkBoxQty = false;
  int _selIndex;
  bool _btnConfirmAble = false;

  DateTime _schPickDt = DateTime.now();
  final TextEditingController _selPickDtFrom = TextEditingController();

  void initStatus() {
    _selPickDtFrom.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);

    super.initState();
  }

  dynamic popUpYn = "N";

  List<dynamic> _searchList = [];
  List<dynamic> _orderList = [{}];
  List<dynamic> _seletedRecords = [];


  Future<void> _search() async {
    Map<String, dynamic> param = {};
    _searchList = [];
    _seletedRecords = [];
    _selIndex = 0;
    param = {
      "LOT_NO": _lotValue.text,
    };

    List<dynamic> inList = await transaction(context, "inn/INN0005/selectShuttleInNo.do", param);
    if(inList.length > 1){
      final result = await showSmallPopup(context, inList, ["PACK_ID","IN_NO"]);
      // 선택을 하지 않을 경우 종료
      if(result == null){
        return;
      }
      inList.clear();
      inList.add(result);
    }

    param["IN_NO"] = inList[0]["IN_NO"];

    List<dynamic> rtnList = await transaction(context, "inn/INN0005/selectShuttleDetailList.do", param);
    if (CommonUtil.isEmpty(rtnList)) {
      _searchList = [];
      _orderList = [{}];
    }
    else {
      _searchList = rtnList;
      _orderList = rtnList;
    }

    for(int i =0; i < _searchList.length; i++){
      _searchList[i]["INDEX"] = i;
    }
    _updatePlanQty();

    setState(() {
      _lotValue.text = "";
    });
  }

  Future<void> _cancelInsertConfirmed() async {
    confirmDialog(context, "실적취소", "실적등록이 완료된 포장입니다. 실적등록을 취소하시겠습니까?").then((value) async { // async 추가
      if(value) {

        List<dynamic> resultList = ConvertUtil.removeColumn(_searchList, ["ROW_COLOR"]);

          await transaction(context, "inn/INN0005/deleteInsertOut.do", resultList, (status, data) {
            if (status == Constant.resSuccessCode) {
              showInfoAlert_pda(context, "취소가 완료되었습니다.");
              _search();
            }
          });
      }
    });
    setState(() {});
  }

  Future<void> _insertConfirmed() async {

    if(_selLocVal.text == "") {
      showInfoAlert_pda(context, "Bin을 입력하십시오.");
      return;
    }

    List<dynamic> resultList = ConvertUtil.removeColumn(_seletedRecords, ["ROW_COLOR"]);

    print(resultList);

    for (var item in resultList) {
      item['LOCATION_CD'] = _selLocVal.text;
    }

    if (resultList.isEmpty) {
      showInfoAlert_pda(context, "chkSelectedIn");
      return;
    }
    else if(_searchList.length != _seletedRecords.length) {
      //showInfoAlert_pda(context, "chkDiffInQty");
      List<dynamic> notInList = [];
      notInList.addAll(_searchList);
      for(int i = 0 ; i < _seletedRecords.length; i++){
        notInList.removeWhere((item) => item['PACK_ID'] == _seletedRecords[i]["PACK_ID"]);
      }

      // if(notInList.length >= 5){
      //   await confirmDialogList(
      //       context, "셔틀입고", "스캔되지 않은 포장번호가 5건 이상입니다. 입고자재를 확인하세요.\n",
      //      notInList
      //   );
      //   return;
      // }

      bool cResult = await confirmDialogList(
          context, "셔틀입고", "스캔되지 않은 포장번호가 존재합니다.\n함께 입고확정 처리 하시겠습니까?\n",
          notInList
      );

      if (cResult == true) {
        resultList = ConvertUtil.removeColumn(_searchList, ["ROW_COLOR"]);
        for (var item in resultList) {
          item['LOCATION_CD'] = _selLocVal.text;
        }

        await transaction(context, "inn/INN0005/updateInsertList.do", resultList, (status, data) {
          if (status == Constant.resSuccessCode) {
            showInfoAlert_pda(context, "입고가 완료되었습니다.");
            _search();
          }
        });
      }
    }
    else {
      await transaction(context, "inn/INN0005/updateInsertList.do", resultList, (status, data) {
        if (status == Constant.resSuccessCode) {
          showInfoAlert_pda(context, "입고가 완료되었습니다.");
          _search();
        }
      });
    }
    setState(() {});
  }

  Future<void> _handleCMScan(String scannedValue) async {
    scannedValue = CommonUtil.parseLotNo(scannedValue);
    // BIN NO scan
    if (scannedValue.startsWith(Constant.BIN_BARCODE_DELIMIT)) {
      scannedValue = scannedValue.replaceAll(Constant.BIN_BARCODE_DELIMIT, "");
      _selLocVal.text = scannedValue;
    }else{
      _lotValue.text = scannedValue;

      var existingItem = _searchList.firstWhere(
            (item) => item['PACK_ID'] == _lotValue.text,
        orElse: () => null,
      );

      if (existingItem != null) {
        print("이미 존재하는 PACK_ID 스캔됨: ${_lotValue.text}");
        var alreadySelected;

        List<dynamic> _dupList = [];
        for (var item in _searchList) {
          if (item['PACK_ID'] == _lotValue.text) {
            _dupList.add(item);
          }
        }

        if(_dupList.length > 1){
          final result = await showSmallPopup(context, _dupList, ["PACK_ID","GRADE","IN_CONF_QTY_KG"]);
          // 선택을 하지 않을 경우 종료
          if(result == null){
            return;
          }

          alreadySelected = _seletedRecords.firstWhere(
                (item) => mapEquals(item, result),
            orElse: () => null,
          );
        }
        else{
          alreadySelected = _seletedRecords.firstWhere(
                (item) => item['PACK_ID'] == _lotValue.text,
            orElse: () => null,
          );
        }

        if (alreadySelected == null) {
          existingItem["ROW_COLOR"] = Colors.orange;
          _seletedRecords.add(existingItem);
          _updatePlanQty();
          _selIndex = existingItem["INDEX"];
          setState(() {});
          print("선택 목록에 추가됨: ${_lotValue.text}");
        } else {
          print("이미 선택된 아이템: ${_lotValue.text}");
        }
      } else {
        print("새로운 LOT 검색: ${_lotValue.text}");
        if(_searchList.length > 0 && _searchList[0]["IN_STATUS"] == "20"){
          bool cResult = await confirmDialog(context, "셔틀입고", "입고확정 되지 않았습니다. 다른 입고번호의 입고를 진행하시겠습니까?");
          if(cResult == false){
            return;
          }
        }
        _search();
      }
    }

    print("CM 타입 스캔 처리 완료");
  }

  bool _cancelDisable() {
    if (_searchList.isEmpty) {
      return true;
    }

    for (var item in _searchList) {
      if (item['IN_STATUS'] != "40") {
        return true;
      }
    }
    return false;
  }

  bool _registrationDisable() {
    _btnConfirmAble = false;

    if (_searchList.isEmpty) {
      _btnConfirmAble = true;
      return true;
    }

    for (var item in _searchList) {
      if (item['IN_STATUS'] != "20") {
        _btnConfirmAble = true;
        return true;
      }
    }

    return false;
  }

  @override
  void initState() {
    super.initState(); // 먼저 호출

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _selLocVal.text = await App_Function.GetLocation(context,"I");
    });

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updatePlanQty() {
    int total = _searchList.length;
    int selected = _seletedRecords.length;
    _planQty.text = "$total/$selected";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: pageAppBar(context, "shuttleDetailSearch",false),
        body: FooterLayout(
          footer: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 두 개의 버튼을 나란히 배치
                Row(
                  children: [
                    CommonActionBtn(
                      "inConfirmedCancel",
                      width: screenWidth * 0.5 - 10,
                      disabledBtn: _cancelDisable(),
                      onPressed: _cancelInsertConfirmed,
                    ),
                    CommonActionBtn(
                        "inConfirmed",
                        width: screenWidth * 0.5 - 10,
                        disabledBtn: _registrationDisable(),
                        onPressed: _insertConfirmed
                    ),
                  ],
                ),
              ],
            ),
          ),
          child: Container(
            child: GestureDetector(
                onTap: () {
                  CommonUtil.hideKeyboard();
                },
                child: Column(
                    children: <Widget>[
                      _searchField(_orderList),
                      Expanded(
                        child: CustomGrid(['packId', 'expectedWeight'],
                          ['PACK_ID', 'IN_CONF_QTY'],
                          _searchList,
                          focusIndex: _selIndex,
                          onTap: (e) {
                            if(CommonUtil.isNull(CommonUtil.findValFromList(_seletedRecords, 'PACK_ID', e['PACK_ID'], 'PACK_ID'))) {
                              e["ROW_COLOR"] = Colors.orange;
                              _seletedRecords.add(e);
                              _selIndex = e["INDEX"];
                            }
                            else{
                              e["ROW_COLOR"] = Colors.transparent;
                              _seletedRecords.remove(e);
                              _selIndex = e["INDEX"];
                            }

                            _updatePlanQty();

                            setState(() {});
                          },
                        ),
                      ),
                    ])),
          ),
        ));
  }

  Widget _searchField(List<dynamic> list) {
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
              CommonText("lotNo"),
              CommonTextField(_lotValue,
                onEditingComplete: (result) async {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
                onSubmitted: (value){
                  _handleCMScan(value);
                },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("grade"),
              CommonTextField(list[0]['GRADE'] ?? '', width: MediaQuery.of(context).size.width * 0.22 - 12.5, enabled: false),
              CommonText("netWt"),
              CommonTextField(list[0]['IN_CONF_QTY_KG'] ?? '', width: MediaQuery.of(context).size.width * 0.22 - 12.5, enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("planPick"),
              CommonTextField(_planQty, enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("합계 예정중량"),
              CommonTextField(list[0]['ITEM_SUM_QTY'], enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("차량정보"),
              CommonTextField(list[0]['VEHICLE_NO'], enabled: false),
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
                  _selLocVal.text = result;
                },

              )
            ],
          ),
        ],
      ),
    );
  }
}