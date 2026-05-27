import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonCar.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/commOutNo.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/out/OUT0005MP06.dart';
import 'package:dtwms_app/pages/out/OUT0005MP07.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class OUT0008P03 extends StatefulWidget {
  const OUT0008P03({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0008P03 createState() => _OUT0008P03();
}

class _OUT0008P03 extends State<OUT0008P03> {
  final TextEditingController _itemCd = TextEditingController();
  final TextEditingController _materialVal = TextEditingController();

  final TextEditingController _planQty = TextEditingController();
  final TextEditingController _confQty = TextEditingController();
  final TextEditingController _qty = TextEditingController();
  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();

  dynamic popUpYn = "N";

  List<dynamic> _searchList = [];
  int _selectedIndex = -1;

  Future<void> _search() async {
    Map<String, dynamic> param = {};
    _searchList = [];
    param = {
      "OUT_NO" : widget.param['OUT_NO'],
      "OUT_SEQ" : widget.param['OUT_SEQ'],
    };

    List<dynamic> rtnList = await transaction(context, "out/OUT0008/searchOutDetailList.do", param);

    for(int i=0; i < rtnList.length; i++){
      _searchList.add(rtnList[i]);
      _searchList[i]["index"] = i;
      _searchList[i]["ROW_COLOR"] = Colors.transparent;
    }

    setState(() {});
  }

  Future<void>  _updateOutDetail() async {
    Map<String, dynamic> newItem = <String, dynamic>{};

    if(_selectedIndex == -1) {
      showInfoAlert_pda(context, "재고를 선택해주세요.");
      return;
    }

    newItem = _searchList[_selectedIndex];

    newItem.remove("ROW_COLOR");

    newItem['FROM_PLANT'] = widget.param['FROM_PLANT'];
    newItem['FROM_SLOC'] = widget.param['FROM_SLOC'];
    newItem['TO_PLANT'] = widget.param['TO_PLANT'];
    newItem['TO_SLOC'] = widget.param['TO_SLOC'];
    
    print("_updateDispatch : ${newItem}");

    await transaction(context, "out/OUT0008/deleteOutDetail.do", newItem, (status, responseData) {
      if (status == Constant.resSuccessCode) {
        showInfoAlert_pda(context, "취소되었습니다.");
        _search();
      }
    });

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    if (!CommonUtil.isEmpty(widget.param)) {

      if (!CommonUtil.isEmpty(widget.param["SHPR_ITEM_CD"])) {
        _itemCd.text = widget.param["SHPR_ITEM_CD"];
      }

      if (!CommonUtil.isEmpty(widget.param["OUT_CONF_QTY"])) {
        _planQty.text = widget.param["OUT_CONF_QTY"].toString();
      }

      if (!CommonUtil.isEmpty(widget.param["OUT_QTY"])) {
        _confQty.text = widget.param["OUT_QTY"].toString();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(!CommonUtil.isEmpty(widget.param))
        await _search();
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
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "상세재고목록",false),
        body: FooterLayout(
          footer: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                      Row(children: <Widget>[_searchField()]),
                      Row(
                        children: [
                          CommonActionBtn(
                            "출고취소",
                            onPressed: (){
                              _updateOutDetail();
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: CustomGrid([['plant','sloc'],'bin','재고수량'],
                         [['PLANT', "SLOC"], 'LOCATION_CD','STOCK_QTY'],
                          _searchList,
                          focusIndex: _selectedIndex,
                          onTap: (rowData) {
                            if (rowData != null && rowData is Map && rowData['SHPR_ITEM_CD'] != null) {
                              _materialVal.text = rowData['SHPR_ITEM_CD'].toString();
                            }
                            // 이전에 선택된 항목들의 색상을 모두 투명하게 변경
                            for (var item in _searchList) {
                              item["ROW_COLOR"] = Colors.transparent;
                            }

                            rowData["ROW_COLOR"] = Colors.orange;
                            _selectedIndex = rowData["index"];

                            _qty.text = _searchList[_selectedIndex]["STOCK_QTY"].toString();

                            setState(() {
                            });

                          },
                        ),
                      ),

                    ]))),
        ));
  }

  Widget _searchField() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("품목명"),
              CommonTextField(
                _itemCd,
                enabled: false,
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("요청수량"),
              CommonTextField(_planQty, width: MediaQuery.of(context).size.width * 0.22-12.5, enabled: false),
              CommonText("불출수량"),
              CommonTextField(_confQty, width: MediaQuery.of(context).size.width * 0.22-12.5, enabled: false),
            ],
          ),
        ],
      ),
    );
  }
}