import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonCar.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonMaterial.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/commOutNo.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/common/popup.dart';
import 'package:dtwms_app/pages/out/OUT0005MP05.dart';
import 'package:dtwms_app/pages/out/OUT0005MP06.dart';
import 'package:dtwms_app/pages/out/OUT0005MP07.dart';
import 'package:dtwms_app/pages/out/OUT0012MP02.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class OUT0012MP04 extends StatefulWidget {
  const OUT0012MP04({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0012MP04 createState() => _OUT0012MP04();
}

class _OUT0012MP04 extends State<OUT0012MP04> {
  final TextEditingController _selOutNoVal = TextEditingController();
  final TextEditingController _selPickVal = TextEditingController();
  final TextEditingController _carNo = TextEditingController();
  final TextEditingController _carCd = TextEditingController();
  final TextEditingController _driverNm = TextEditingController();
  final TextEditingController _driverCall = TextEditingController();
  final TextEditingController _materialVal = TextEditingController();
  final TextEditingController _containerNo = TextEditingController();
  final TextEditingController _sumStockQtyVal = TextEditingController();

  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();

  dynamic popUpYn = "N";

  List<dynamic> _searchList = [];
  int _selectedIndex = 0;
  String _packId;

  Future<void> _search() async {
    FocusScope.of(context).unfocus();
    Map<String, dynamic> param = {};
    _searchList = [];

    param = {
      "OUT_NO": widget.param["OUT_NO"],
      "DISPATCH_NO" : widget.param["DISPATCH_NO"],
      "PICK_SEQ" : widget.param["PICK_SEQ"],
      "LOT_NO" : widget.param["LOT_NO"]
    };

    List<dynamic> rtnList = await transaction(context, "out/OUT0005/searchOutPickItemDetailList.do", param);
    for(int i=0; i < rtnList.length; i++){
      _searchList.add(rtnList[i]);
      _searchList[i]["index"] = i;
      _searchList[i]["ROW_COLOR"] = _searchList[i]["CHECK_YN"]=="Y"? Colors.orange.shade100 : Colors.transparent;
    }

    setState(() {
      _sumStockQtyVal.text = _searchList.isNotEmpty
          ? (_searchList[0]['SUM_STOCK_QTY'] ?? '0').toString()
          : '0';
    });
  }

  Future<void> _updateDispatch() async {
    // 차량정보 추가
    List<dynamic> resultList = CommonUtil.findRegExpRtnList(_searchList, 'EDIT_QTY', '[1-9]');

    resultList = ConvertUtil.removeColumn(_searchList.where((item) => item["CHECK_YN"] == "N").toList(), ["ROW_COLOR"]);

    resultList = resultList.map((item) {
      item["OUT_QTY"] = item["EDIT_QTY"];
      return item;
    }).toList();

    print(resultList);

    await transaction(context, "out/OUT0005/updateDirectItemDispatch.do", resultList, (status, responseData) {
      if (status == Constant.resSuccessCode) {
        showInfoAlert_pda(context, "상차청보가 수정되었습니다.");
        _search();
      }
    });
  }

  Future<void> _deleteDispatch() async {
    Map<String, dynamic> newItem = <String, dynamic>{};

    if (_searchList.isEmpty || _selectedIndex >= _searchList.length) return;

    dynamic selectedRow = _searchList[_selectedIndex];

    confirmDialog(context, "상차취소", "상차가 완료된 품목입니다. 상차취소 하시겠습니까?").then((value) async {

      if (value != true) return;

      // 차량정보 추가
      List<dynamic> resultList = CommonUtil.findRegExpRtnList(_searchList, 'EDIT_QTY', '[1-9]');

      resultList = ConvertUtil.removeColumn([selectedRow], ["ROW_COLOR"]);

      print("deleteDispatch resultList: $resultList");

      await transaction(
          context, "out/OUT0005/cancelDirectItemDispatch.do", resultList, (status,
          responseData) {
        if (status == Constant.resSuccessCode) {
          showInfoAlert_pda(context, "상차취소가 완료되었습니다.");
          _search();
        }
      });
    });
  }

  Future<void> _handleCMScan(String scannedValue) async {
    print("CM 타입 스캔 처리 시작: $scannedValue");
    scannedValue = CommonUtil.parseLotNo(scannedValue);
    //_materialVal.text = scannedValue;
    _packId = scannedValue;

    //기존에 존재하는 값이 있으면 delete 이벤트
    int existingIndex = _searchList.indexWhere(
          (item) => item["PACK_ID"]?.toString() == scannedValue,
    );

    if (existingIndex != -1) {
      setState(() {
        for (var item in _searchList) {
          item["ROW_COLOR"] = item["CHECK_YN"] == "Y"
              ? Colors.orange.shade100
              : Colors.transparent;
        }
        _searchList[existingIndex]["ROW_COLOR"] = Colors.orange;
        _selectedIndex = existingIndex;
      });
      await _deleteDispatch();
      print("CM 타입 스캔 처리 완료 - 기존 항목 선택");
      return;
    } else {
      showInfoAlert_pda(context, "취소 품목을 확인해주십시오.");
    }

    setState(() {});

    print("CM 타입 스캔 처리 완료");
  }

  @override
  void initState() {
    super.initState();

    print("************************* \nOUT0012MP04 paramater ${widget.param}");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(!CommonUtil.isEmpty(widget.param))
        await _search();
    });
  }


  @override
  void dispose() {
    fnOne.dispose();
    fnTwo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    ZebraDataWedgeListener.initFunc();

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: pageAppBar(context, "상차출고 상세", false),
        body: FooterLayout(
          footer: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: <Widget>[
                    CommonActionBtn(
                      "저장",
                      onPressed: () => _updateDispatch(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          child: Container(
                //height : CommonUtil.pageMaxHeight(context,(55 * (_searchList.length - 7)).toDouble()),
                child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      CommonUtil.hideKeyboard();
                    },
                    child: Column(children: <Widget>[
                      _searchField(),
                      Expanded(
                        child: CustomGrid(['포장번호',['납품번호','Bin'],'상차량'],
                          ['PACK_ID',['IF_OUT_NO','LOCATION_CD'], "EDIT_QTY"],
                          _searchList,
                          focusIndex: _selectedIndex,
                          onFieldSubmitted: (rowData) {
                            setState(() {
                              _searchList[rowData["INDEX"]]["CHECK_YN"] = "N";
                              _searchList[rowData["INDEX"]]["ROW_COLOR"] = Colors.red.shade100;
                            });
                          },
                          onTap: (rowData) {
                            for (var item in _searchList) {
                              item["ROW_COLOR"] = item["CHECK_YN"]=="Y"? Colors.orange.shade100 : Colors.transparent;
                            }
                            rowData["ROW_COLOR"] = Colors.orange;
                            _selectedIndex = rowData["index"];

                            setState(() {
                              _deleteDispatch();
                            });
                          },
                        ),
                      ),
                    ]))),
        ));
  }

  Widget _searchField() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("GRADE", width: MediaQuery.of(context).size.width * 0.16),
              CommonTextField(widget.param['ZZGRADE'],enabled: false, width: MediaQuery.of(context).size.width * 0.34-12.5),
              CommonText("LOT", width: MediaQuery.of(context).size.width * 0.16),
              CommonTextField(widget.param['LOT_NO'],enabled: false, width: MediaQuery.of(context).size.width * 0.34-12.5)
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("지시량", width: MediaQuery.of(context).size.width * 0.16),
              CommonTextField(widget.param['PICK_INST_QTY'],enabled: false, width: MediaQuery.of(context).size.width * 0.34-12.5),
              CommonText("상차량", width: MediaQuery.of(context).size.width * 0.16),
              CommonTextField( _sumStockQtyVal, enabled: false, width: MediaQuery.of(context).size.width * 0.34-12.5)
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("납품문서 번호"),
              CommonTextField(widget.param['IF_OUT_NO'],
                enabled: false,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Offstage(
                offstage: true, // false로 바꾸면 다시 보임
                child: CommonScanTextField(
                  _materialVal,
                  focusNode: fnOne,
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