import 'dart:developer';

import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonGroup.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/commWidget.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dtwms_app/models/restfulReq.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';

class OUT0003M extends StatefulWidget {
  @override
  _OUT0003M createState() => _OUT0003M();
}

class _OUT0003M extends State<OUT0003M> {
  final TextEditingController _selBarcode = TextEditingController();

  final TextEditingController _plantValue = TextEditingController();
  final TextEditingController _sLoc = TextEditingController();

  final TextEditingController _binValue = TextEditingController();
  final TextEditingController _materialValue = TextEditingController();


  //포커스 노드
  FocusNode fnOne;
  FocusNode fnTwo;
  FocusNode fnThree;
  FocusNode fnFour;

  //shpr_item list
  List<dynamic> _ItemList = [];
  dynamic _selItemId;

  //SHPR LIST
  List<dynamic> _ShprList = [];
  dynamic _selShprId;

  List<dynamic> _searchHeaderList = ['품목', '출고수량', '스캔수량'];
  List<dynamic> _searchHeaderList2 = [
    // ['SHPR_NM', 'SHPR_ITEM_NM'],
    'SHPR_ITEM_NM',
    'STOCK_QTY',
    'IN_DATE_FM',
    // ['PLANT', 'SLOC'],
  ];
  List<dynamic> _searchList = [];

  _search() async {
    Map<String, dynamic> paramMap = {
      "PLANT_VALUE": _plantValue.text,
      "S_LOC": _sLoc.text,
      "BIN_VALUE": _binValue.text,
      "MATERIAL_VALUE": _materialValue.text,
      "SHPR_ITEM_CD": _selItemId,
      "SHPR_CD": _selShprId,
      "ITEM_BARCODE": _selBarcode.text,
    };
    // if (CommonUtil.isNull(_binValue.text))
    //   showInfoAlert(context, '로케이션을 입력하세요');
    // else {
    _searchList = await transaction(context, "/stk0001/search.do", paramMap);
    // }
    setState(() {});

  }

  Future<dynamic> callNavi(BuildContext context, [dynamic param]) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            // builder: (context) => OUT0003MP01(param: param)
        ));

    if (result != null && result) {
      _search();
    }
  }

  @override
  void initState() {
    //포커스 인스턴스 저장
    fnOne = FocusNode();
    fnTwo = FocusNode();
    fnThree = FocusNode();
    fnFour = FocusNode();

    //비동기로 flutter secure storage 정보를 불러오는 작업.
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        shprItemInfo(context, {'ALL_FLAG': 'Y', 'SHPR_CD': _selShprId})
            .then((data) => setState(() {
          _ItemList = data;
          if (CommonUtil.isEmpty(_ItemList))
            _selItemId = "";
          else
            _selItemId = _ItemList[0]['CODE'];
        })));

    //비동기로 flutter secure storage 정보를 불러오는 작업.
    WidgetsBinding.instance.addPostFrameCallback(
            (_) => shprInfo(context, {'ALL_FLAG': 'Y'}).then((data) => setState(() {
          _ShprList = data;
          if (CommonUtil.isEmpty(_ShprList))
            _selShprId = "";
          else
            _selShprId = _ShprList[0]['CODE'];
        })));

    WidgetsBinding.instance.addPostFrameCallback(
            (_) => FocusScope.of(context).requestFocus(fnOne));

    super.initState();
  }

  @override
  void dispose() {
    //포커스 dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    var color = 0xff453658;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "Serial 등록"),
        body: Container(
            child: GestureDetector(
              onTap: () {
                CommonUtil.hideKeyboard();
              },
              child: Column(
                children: <Widget>[
                  _searchField(),
                  CommonActionBtn(
                    "조  회",
                    height: 50,
                    fontSize: 20,
                    onPressed: () {
                      _search();
                      //수량 update controller
                      //다시 서치
                      fnOne.unfocus();
                      fnTwo.unfocus();
                      fnThree.unfocus();
                      fnFour.unfocus();
                    },
                  ),
                  Expanded(
                    child: CustomGrid(
                        _searchHeaderList, _searchHeaderList2, _searchList,
                        onRefresh: () {
                          _search();
                        }, onTap: ([rowData]) {
                      callNavi(context, rowData).then((data) {});
                    }),
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

          Visibility(
            visible: false,
            child: Row(
              children: <Widget>[
                CommonText("화주"),
                CommonDropdown(null, _selShprId, _ShprList, (id, code, name) {
                  setState(() {
                    _selShprId = code;
                    shprItemInfo(
                        context, {'ALL_FLAG': 'Y', 'SHPR_CD': _selShprId})
                        .then((value) {
                      _selItemId = '';
                      _ItemList = value;
                      _selBarcode.text = "";
                      _search();
                    });
                  });
                }),
              ],
            ),
          ),
          Visibility(
            visible: false,
            child: Row(
              children: <Widget>[
                CommonText("품목"),
                CommonDropdown(null, _selItemId, _ItemList, (id, code, name) {
                  setState(() {
                    _selItemId = code;
                    _selBarcode.text = "";
                    _search();
                  });
                }),
              ],
            ),
          ),
          Visibility(
            visible: false,
            child: Row(
              children: <Widget>[
                CommonText("품목바코드"),
                CommonScanTextField(_selBarcode,
                    focusNode: fnTwo, scanType: "PD", refresh: () {
                      setState(() {});
                    }, onEditingComplete: (nodeObj) {
                      setState(() {
                        _search();
                        _selBarcode.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _selBarcode.text.length,
                        );
                      });
                    })
              ],
            ),
          ),
          //
          // Row(
          //   children: <Widget>[
          //     CommonText("PLANT", width: 78,),
          //     CommonTextField(_plantValue,
          //         width: 90,
          //         enabled: false
          //     ),
          //     CommonText("S.Loc", width: 78,),
          //     CommonTextField(list[0]['SLOC'], width: 90, enabled: false)
          //   ],
          // ),
          //
          Row(
            children: <Widget>[
              CommonText("PLANT", width: 78,),
              CommonTextField(_plantValue,
                focusNode: fnOne,
                width: 90,
                onEditingComplete: (nodeObj) {
                  fnOne.unfocus();
                  //조회버튼 누르면 실행 안 되게해야 함
                  FocusScope.of(context).requestFocus(fnTwo);
                  // _search();
                },
              ),
              CommonText("S.Loc", width: 78,),
              CommonTextField(_sLoc,
                  focusNode: fnTwo,
                  width: 90,
                  onEditingComplete: (nodeObj) {
                    fnTwo.unfocus();
                    FocusScope.of(context).requestFocus(fnThree);
                    // _search();
                  }),
            ],
          ),
          //
          Row(
            children: <Widget>[
              CommonText("출고번호"),
              CommonScanTextField(_selBarcode, focusNode: fnThree, scanType: "PI", refresh: () {
                setState(() {});
              }, onEditingComplete: ([result]) {
                fnThree.unfocus();
                _selBarcode.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _selBarcode.text.length,
                );
              }
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("배송처"),
              CommonScanTextField(_selBarcode, focusNode: fnFour, scanType: "PI", refresh: () {
                setState(() {});
              }, onEditingComplete: ([result]) {
                fnFour.unfocus();
                _selBarcode.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _selBarcode.text.length,
                );
              }
              )
            ],
          ),
        ],
      ),
    );
  }
}
