import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
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
import 'package:dtwms_app/pages/out/OUT0012MP02.dart';
import 'package:dtwms_app/pages/out/OUT0012MP03.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:dtwms_app/pages/out/OUT0002P03.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'OUT0002P03.dart';

class OUT0012P01 extends StatefulWidget {
  @override
  _OUT0012P01 createState() => _OUT0012P01();
}

class _OUT0012P01 extends State<OUT0012P01> {
  final TextEditingController _carNo = TextEditingController();
  final TextEditingController _cntrNo = TextEditingController();
  final TextEditingController _pickingNo = TextEditingController();
  final TextEditingController _materialVal = TextEditingController();
  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();
  final FocusNode fnThree = FocusNode();
  final FocusNode fnFour = FocusNode();
  List<dynamic> _carList = [];
  //배송처에 속한 출고번호 List
  List<dynamic> _searchCustOutList = [];
  DateTime _schPickFrom = DateTime(
      DateTime.now().subtract(Duration(days:7)).year,
      DateTime.now().subtract(Duration(days:7)).month,
      DateTime.now().subtract(Duration(days:7)).day
  );
  DateTime _schPickDt = DateTime.now();
  final TextEditingController _selPickDtFrom = TextEditingController();
  final TextEditingController _selPickDtTo = TextEditingController();
  int _gridFocusIdx = 0;

  bool _autoNavigate = true;

  @override
  void initState() {
    _selPickDtFrom.text = formatDate(_schPickFrom, [yyyy, '-', mm, '-', dd]);
    _selPickDtTo.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _searchCarNo() async {
    _carList = [];
    
    Map<String, dynamic> param = {};
    param['VEHICLE_NO'] = _carNo.text;
    param['CNTR_NO'] = _cntrNo.text;
    param['PICK_ID'] = _pickingNo.text;
    param['PLAN_DATE_FROM'] = CommonUtil.removeDash(_selPickDtFrom.text);
    param['PLAN_DATE_TO'] = CommonUtil.removeDash(_selPickDtTo.text);

    print(param);

    List<dynamic> rtnList = await transaction(context, "out/OUT0005/searchPickingDispatchInfoList.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _carList = [];
    } else {
      _carList = rtnList;

      // 결과가 1개면 바로 해당 페이지로 이동
      if (_autoNavigate && _carList.length == 1) {
        _autoNavigate = false;
        final rowData = Map<String, dynamic>.from(_carList[0]);
        rowData['INDEX'] = 0;
        if (rowData["EX_TYPE"] == "30") {
          await callOutNavi(context, rowData);
        } else {
          await callInNavi(context, rowData);
        }
        return;
      }
    }

    setState(() {});
  }

  Future<dynamic> callInNavi(BuildContext context, [dynamic param]) async {

    param['custList'] = _searchCustOutList;
    _gridFocusIdx = param["INDEX"];

    print("param $param");

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0012MP02(param: param)));

    _autoNavigate = false;
    _searchCarNo();

  }

  Future<dynamic> callOutNavi(BuildContext context, [dynamic param]) async {

    param['custList'] = _searchCustOutList;
    _gridFocusIdx = param["INDEX"];

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0012MP03(param: param)));

    _autoNavigate = false;
    _searchCarNo();
}

  Future<void> _handleCMScan(String scannedValue) async {

    _carNo.text = scannedValue;

    _autoNavigate = true;

    setState(() {
      _searchCarNo();
    });

  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "상차출고 배차"),
        body: Container(
            child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
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
                  _gridFocusIdx = 0;
                  _autoNavigate = true;
                  _searchCarNo();
                },
              ),
              Expanded(
                child: CustomGrid(
                    ['carNo','containerNo', ['배차중량','상차량']],
                    ['VEHICLE_NO','CNTR_NO', ['CAR_QTY','TOTAL_CAR_INPUT_QTY']],
                    _carList,
                    focusIndex: _gridFocusIdx,
                    onTap: ([rowData]) {
                      if(rowData["EX_TYPE"] == "30") {
                        callOutNavi(context, rowData).then((data) {});
                      } else {
                        callInNavi(context, rowData).then((data) {});
                      }
                },
                onRefresh: () {
                  _gridFocusIdx = 0;
                  _searchCarNo();
                }),
              ),
              /*CommonActionBtn("Box 패킹", onPressed: () {_movePage();},),
              CommonActionBtn("Pallet 패킹", onPressed: () {_movePage();},),*/
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
              CommonText("outPlanDate", height: 95),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CommonDatePicker(
                    selConroller: _selPickDtFrom,
                    clearEnabled: false,
                    onEditingComplete: ([result]) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  CommonDatePicker(
                    selConroller: _selPickDtTo,
                    clearEnabled: false,
                    onEditingComplete: ([result]) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("carNo"),
              CommonTextField(_carNo,
                  focusNode: fnTwo,
                  onEditingComplete: ([result]) {
                    FocusScope.of(context).unfocus();
                    _gridFocusIdx = 0;
                    _searchCarNo();
              })
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("컨테이너 번호"),
              CommonTextField(_cntrNo,
                  focusNode: fnThree,
                  onEditingComplete: ([result]) {
                    FocusScope.of(context).unfocus();
                    _gridFocusIdx = 0;
                    _searchCarNo();
                  })
            ],
          ),
          // Row(
          //   children: <Widget>[
          //     CommonText("피킹지시서"),
          //     CommonTextField(_pickingNo,
          //         focusNode: fnFour,
          //         onEditingComplete: ([result]) {
          //           FocusScope.of(context).unfocus();
          //           _gridFocusIdx = 0;
          //           _searchField();
          //         })
          //   ],
          // ),
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
