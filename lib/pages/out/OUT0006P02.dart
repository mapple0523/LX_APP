import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonMaterial.dart';
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
import 'package:dtwms_app/pages/out/OUT0006M.dart';
import 'package:dtwms_app/pages/out/OUT0006P01.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:dtwms_app/pages/out/OUT0002P03.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

import 'OUT0002P03.dart';

class OUT0006P02 extends StatefulWidget {
  @override
  _OUT0006P02 createState() => _OUT0006P02();
}

class _OUT0006P02 extends State<OUT0006P02> {
  final TextEditingController _materialNm = TextEditingController();
  final TextEditingController _materialCd = TextEditingController();

  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();
  final FocusNode fnThree = FocusNode();

  dynamic _plantValue  = null;
  dynamic _selLocVal = null;

  List<dynamic> _searchList = [];
  List<dynamic> _plantList = [];
  List<dynamic> _slocList = [];
  List<dynamic> _seletedRecords = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      if (mounted) {
        await _plantSearch();
      }
    });
  }

  @override
  void dispose() {
    FocusScope.of(context).unfocus();

    super.dispose();
  }

  Future<void> _plantSearch() async {
    Map<String, dynamic> param = {};
    _plantList = [];

    List<dynamic> rtnList =
    await transaction(context, "out/OUT0004/searchPlant.do", param);

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
    await transaction(context, "out/OUT0004/searchSLoc.do", param);

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

  Future<void> _addToSearchList(Map<String, dynamic> data) async {
    // 기존 리스트에서 SHPR_ITEM_CD와 STOCK_SEQ가 같은 항목 찾기
    int existingIndex = _searchList.indexWhere((item) =>
    item['SHPR_ITEM_CD'] == data['SHPR_ITEM_CD'] &&
        item['STOCK_SEQ'] == data['STOCK_SEQ'] &&
        item['LOCATION_CD'] == data['LOCATION_CD']
    );

    if (existingIndex != -1) {
      // 기존 항목이 있으면 MOVE_QTY만 업데이트
      _searchList[existingIndex]['MOVE_QTY'] = data['MOVE_QTY'];
      print("기존 항목의 MOVE_QTY 업데이트: ${data['MOVE_QTY']}");
    } else {
      // 기존 항목이 없으면 새로운 데이터를 _searchList에 추가
      _searchList.add(data);
      print("_searchList에 새로운 데이터 추가: $data");
    }

    print("현재 _searchList: $_searchList");

    setState(() {});
  }

  Future<void> _outReleaseList() async {
    // ROW_COLOR를 제거한 복사본 생성
    List<Map<String, dynamic>> sendList = _searchList.map((item) {
      Map<String, dynamic> cleanItem = Map.from(item);
      cleanItem.remove('ROW_COLOR'); // MaterialColor/Color 제거
      return cleanItem;
    }).toList();

    await transaction(context, "/out/OUT0006/insertOutItemList.do", sendList, (status, data) async {
      if(status == Constant.resSuccessCode) {
        _searchList.clear();
      }
    });

    setState(() {});
  }

  Future<void> _deleteSelectedItems() async {
    for (var selectedItem in _seletedRecords) {
      _searchList.removeWhere((item) =>
      item['SHPR_ITEM_CD'] == selectedItem['SHPR_ITEM_CD'] &&
          item['STOCK_SEQ'] == selectedItem['STOCK_SEQ'] &&
          item['LOCATION_CD'] == selectedItem['LOCATION_CD']
      );
    }

    // 선택된 항목 리스트 비우기
    _seletedRecords.clear();

    setState(() {});

  }

  Future<dynamic> callNavi(BuildContext context, [dynamic param]) async {
    Map<String, dynamic> passParam = {
      'searchList': _searchList,
    };

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0006M(param:passParam)));

    if (result != null) {
      await _addToSearchList(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "moveInst"),
        body: FooterLayout(
            footer: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonActionBtn(
                    "btnInst",
                    onPressed: () {
                      _outReleaseList();
                    },
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
                  Row(
                    children: [
                      CommonActionBtn(
                        "btnDel",
                        width: screenWidth * 0.5 - 10,
                        onPressed: () {
                          _deleteSelectedItems();
                        },
                      ),
                      CommonActionBtn(
                        "btnAdd",
                        width: screenWidth * 0.5 - 10,
                        onPressed: () {
                          callNavi(context);
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: CustomGrid(['bin', 'itemCd', 'qty'],
                      ['TO_LOCATION_CD','ITEM_NM', 'MOVE_QTY'],
                      _searchList,
                      onTap: (e) {
                        bool isAlreadySelected = _seletedRecords.any((record) =>
                        record['ITEM_CD'] == e['ITEM_CD'] && record['ITEM_SEQ'] == e['ITEM_SEQ']
                        );

                        if (!isAlreadySelected) {
                          e["ROW_COLOR"] = Colors.orange;
                          _seletedRecords.add(e);
                        } else {
                          e["ROW_COLOR"] = Colors.transparent;
                          _seletedRecords.removeWhere((record) =>
                          record['ITEM_CD'] == e['ITEM_CD'] && record['ITEM_SEQ'] == e['ITEM_SEQ']
                          );
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  /*CommonActionBtn("Box 패킹", onPressed: () {_movePage();},),
                CommonActionBtn("Pallet 패킹", onPressed: () {_movePage();},),*/
                ],
              ),
            )
        )
    );
  }

  Widget _searchField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Row(
          //   children: <Widget>[
          //     CommonText("plant", width: MediaQuery.of(context).size.width * 0.2),
          //     CommonDropdown("W", _plantValue, _plantList, comboCallback, width : MediaQuery.of(context).size.width * 0.3-12.5),
          //     CommonText("sloc", width: MediaQuery.of(context).size.width * 0.2),
          //     CommonDropdown("Z", _selLocVal, _slocList, comboCallback, width : MediaQuery.of(context).size.width * 0.3-12.5),
          //   ],
          // ),
        ],
      ),
    );
  }
}
