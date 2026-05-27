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
import 'package:dtwms_app/pages/out/OUT0008P02.dart';
import 'package:dtwms_app/pages/out/OUT0008P03.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class OUT0008P01 extends StatefulWidget {
  const OUT0008P01({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0008P01 createState() => _OUT0008P01();
}

class _OUT0008P01 extends State<OUT0008P01> {
  final TextEditingController _sLocValue = TextEditingController();
  final TextEditingController _plantValue = TextEditingController();
  final TextEditingController _outNo = TextEditingController();
  final TextEditingController _carCd = TextEditingController();
  final TextEditingController _materialVal = TextEditingController();
  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();

  dynamic popUpYn = "N";

  List<dynamic> _searchList = [];
  int _selectedIndex = 0;

  Future<void> _search() async {
    Map<String, dynamic> param = {};
    _searchList = [];
    param = {
      "OUT_NO" : _outNo.text
    };

    List<dynamic> rtnList = await transaction(context, "out/OUT0008/searchOutItemList.do", param);

    for(int i=0; i < rtnList.length; i++){
      _searchList.add(rtnList[i]);
      _searchList[i]["index"] = i;
      _searchList[i]["ROW_COLOR"] = Colors.transparent;
    }

    setState(() {
    });
  }

  Future<void>  _updateDispatch() async {

    Map<String, dynamic> newItem = <String, dynamic>{};

    // 차량정보 추가
    newItem["DISPATCH_NO"] = widget.param["DISPATCH_NO"];
    newItem["VEHICLE_CD"] = _carCd.text;

    print("_updateDispatch : ${newItem}");

    await transaction(context, "out/OUT0005/updateDispatchList.do", newItem, (status, responseData) {
      if (status == Constant.resSuccessCode) {
        showInfoAlert_pda(context, "차량정보가 저장되었습니다.");
        _search();
      }
    });

    setState(() {});
  }


  Future<dynamic> callInNavi(BuildContext context, [dynamic param]) async {

    param['FROM_PLANT'] = widget.param['FROM_PLANT'];
    param['FROM_SLOC'] = widget.param['FROM_SLOC'];
    param['TO_PLANT'] = widget.param['TO_PLANT'];
    param['TO_SLOC'] = widget.param['TO_SLOC'];

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0008P02(param: param)));

    _search();

    setState(() {});

  }

  Future<dynamic> callInDetail(BuildContext context, [dynamic param]) async {

    param['FROM_PLANT'] = widget.param['FROM_PLANT'];
    param['FROM_SLOC'] = widget.param['FROM_SLOC'];
    param['TO_PLANT'] = widget.param['TO_PLANT'];
    param['TO_SLOC'] = widget.param['TO_SLOC'];

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0008P03(param: param)));

    _search();

    setState(() {});

  }

  @override
  void initState() {
    super.initState();

    if (!CommonUtil.isEmpty(widget.param)) {

      if (!CommonUtil.isEmpty(widget.param["OUT_NO"])) {
        _outNo.text = widget.param["OUT_NO"];
      }

      if (!CommonUtil.isEmpty(widget.param["PLANT"])) {
        _plantValue.text = widget.param["PLANT"];
      }

      if (!CommonUtil.isEmpty(widget.param["SLOC"])) {
        _sLocValue.text = widget.param["SLOC"];
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
        appBar: pageAppBar(context, "불출목록",false),
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
                            "상세재고",
                            width: screenWidth * 0.5 - 10,
                            onPressed: (){
                              callInDetail(context,_searchList[_selectedIndex]);
                            },
                          ),
                          CommonActionBtn(
                            "재고추가",
                            width: screenWidth * 0.5 - 10,
                            onPressed: (){
                              callInNavi(context,_searchList[_selectedIndex]);
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: CustomGrid([['품목코드','품목명'],'요청수량','불출수량'],
                         [['SHPR_ITEM_CD','ITEM_DESC'], "OUT_CONF_QTY", 'OUT_QTY'],
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

                            setState(() {});

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
              CommonText("outNum"),
              CommonTextField(
                _outNo,
                enabled: false,
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("plant"),
              CommonTextField(_plantValue, width: MediaQuery.of(context).size.width * 0.22-12.5, enabled: false),
              CommonText("sloc"),
              CommonTextField(_sLocValue, width: MediaQuery.of(context).size.width * 0.22-12.5, enabled: false),
            ],
          ),
        ],
      ),
    );
  }
}