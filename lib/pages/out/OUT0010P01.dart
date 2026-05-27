import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonCar.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/commOutNo.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class OUT0010P01 extends StatefulWidget {
  const OUT0010P01({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0010P01 createState() => _OUT0010P01();
}

class _OUT0010P01 extends State<OUT0010P01> {
  final TextEditingController _selLocVal = TextEditingController();

  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();

  List<dynamic> _searchList = [];
  List<dynamic> _orderList = [{}];

  dynamic _toPlantValue  = null;
  dynamic _toSelLocVal = null;
  dynamic _packVal = null;
  dynamic _attrVal = null;

  List<dynamic> _toPlantList = [];
  List<dynamic> _toSlocList = [];
  List<dynamic> _packList = [];
  List<dynamic> _attrList = [];

  Future<void> _attrSearch() async {
    Map<String, dynamic> param = {};
    _searchList = [];

    param = {
      "PLANT": widget.param["PLANT"],
      "SLOC": widget.param["SLOC"],
    };

    List<dynamic> rtnList =
    await transaction(context, "out/OUT0010/searchAttrCheck.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _attrList = [];
      _packVal = null; // 리스트가 비어있으면 null로 설정
    } else {
      _attrList = rtnList;
      _attrVal = _attrList[0]['ATTR_02'];
    }

    setState(() {
    });
  }

  Future<void> _packSearch() async {
    Map<String, dynamic> param = {};
    _searchList = [];

    param = {
      "SHPR_ITEM_CD": widget.param["SHPR_ITEM_CD"],
      "LOT_NO": widget.param["LOT_NO"],
      "PLANT": widget.param["FROM_PLANT"],
      "SLOC": widget.param["FROM_SLOC"],
    };

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

        //_tosLocSearch(_packVal);
      }
    }

    setState(() {
    });
  }

  Future<void> _insertPackId() async {
    Map<String, dynamic> sourceData = widget.param;

    Map<String, dynamic> resultData = Map<String, dynamic>.from(sourceData);
    resultData['TO_PLANT'] = _toPlantValue;
    resultData['TO_SLOC'] = _toSelLocVal;
    resultData['TO_LOCATION_CD'] = _selLocVal.text;
    resultData['TO_KDAUF'] = _packVal;

    await transaction(context, "out/OUT0010/insertOutItemList.do", resultData, (status, data) {
      if (status == Constant.resSuccessCode) {
        //showInfoAlert_pda(context, "이동하였습니다.");
        Navigator.pop(context, true);
      }
    });
  }

  Future<void> _toPlantSearch() async {
    Map<String, dynamic> param = {};
    _toPlantList = [];

    List<dynamic> rtnList =
    await transaction(context, "out/OUT0004/searchPlant.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _toPlantList = [];
      _toPlantValue = null; // 리스트가 비어있으면 null로 설정
    } else {
      _toPlantList = rtnList;
      // 첫 번째 항목을 기본값으로 설정
      if (_toPlantList.isNotEmpty) {
        _toPlantValue = widget.param['PLANT'];

        _tosLocSearch(_toPlantValue);
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
    await transaction(context, "out/OUT0005/searchSLoc.do", param);

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
    } else if(id == "PT"){
      _packVal = code;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    print(widget.param);

    _selLocVal.text = 'RCSTAGE';

    Future.delayed(Duration.zero, () async {
      if (!CommonUtil.isEmpty(widget.param)) {
        await _attrSearch();

        if (_attrVal == 'Y') {
          await _packSearch();

          _toPlantList = [];
          _toSlocList = [];
          setState(() {
            _toPlantList = [{"CODE": null, "NAME": "없음"}];
            _toPlantValue = null;

            _toSlocList = [{"CODE": null, "NAME": "없음"}];
            _toSelLocVal = null;
          });
        } else {
          _packSearch();
          _toPlantSearch();
        }
      }
    });

    setState(() {
      _orderList = [widget.param ?? {}];
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: pageAppBar(context, "stockInfoDetail"),
        body: FooterLayout(
            footer: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CommonActionBtn(
                        "RC 이전전기",
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
                    },
                    child: Container(
                      height: CommonUtil.pageMaxHeight(context,-300),
                      child: Column(
                        children: <Widget>[
                          _itemPutContents(_orderList)
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
              CommonText("storageNm"),
              CommonTextField(list[0]['LOCATION_CD'] ?? '', enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("자재명"),
              CommonTextField(list[0]['ITEM_NM'] ?? '', enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("Grade"),
              CommonTextField(list[0]['ZZGRADE'] ?? '', enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("포장량"),
              CommonTextField(list[0]['STOCK_QTY'] ?? '', enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("배치번호"),
              CommonTextField(list[0]['LOT_NO'] ?? '', enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("포장번호"),
              CommonTextField(list[0]['PACK_ID'] ?? '', enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("PLANT", width: MediaQuery.of(context).size.width * 0.2),
              CommonTextField(list[0]['FROM_PLANT'] ?? '', width : MediaQuery.of(context).size.width * 0.3-12.5, enabled: false),
              CommonText("SLOC", width: MediaQuery.of(context).size.width * 0.2),
              CommonTextField(list[0]['FROM_SLOC'] ?? '', width : MediaQuery.of(context).size.width * 0.3-12.5, enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("Bin"),
              CommonTextField(list[0]['LOCATION_CD'] ?? '', enabled: false),
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
              CommonText("toPlant", width: MediaQuery.of(context).size.width * 0.2),
              CommonDropdown("WT", _toPlantValue, _toPlantList, comboCallback, width : MediaQuery.of(context).size.width * 0.3-12.5),
              CommonText("toSloc", width: MediaQuery.of(context).size.width * 0.2),
              CommonDropdown("ZT", _toSelLocVal, _toSlocList, comboCallback, width : MediaQuery.of(context).size.width * 0.3-12.5),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("to Bin"),
              CommonTextField(_selLocVal, enabled: false),
            ],
          ),
        ],
      ),
    );
  }
}