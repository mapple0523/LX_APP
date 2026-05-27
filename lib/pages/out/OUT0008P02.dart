import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonCar.dart';
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
import 'package:dtwms_app/pages/out/OUT0005MP06.dart';
import 'package:dtwms_app/pages/out/OUT0005MP07.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class OUT0008P02 extends StatefulWidget {
  const OUT0008P02({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0008P02 createState() => _OUT0008P02();
}

class _OUT0008P02 extends State<OUT0008P02> {
  final TextEditingController _sLocValue = TextEditingController();
  final TextEditingController _binValue = TextEditingController();
  final TextEditingController _itemCd = TextEditingController();
  final TextEditingController _carCd = TextEditingController();
  final TextEditingController _materialVal = TextEditingController();
  final TextEditingController _selLocVal = TextEditingController();

  final TextEditingController _planQty = TextEditingController();
  final TextEditingController _confQty = TextEditingController();
  final TextEditingController _qty = TextEditingController();
  final FocusNode _scanFocus = FocusNode();
  final TextEditingController _scanValue = TextEditingController();

  dynamic popUpYn = "N";

  List<dynamic> _searchList = [];
  int _selectedIndex = -1;

  Future<void> _search() async {
    Map<String, dynamic> param = {};
    _searchList = [];
    param = {
      "SHPR_ITEM_CD" : _itemCd.text,
      "LOCATION_CD" : _selLocVal.text
    };

    List<dynamic> rtnList = await transaction(context, "out/OUT0008/searchStockList.do", param);

    for(int i=0; i < rtnList.length; i++){
      _searchList.add(rtnList[i]);
      _searchList[i]["index"] = i;
      _searchList[i]["ROW_COLOR"] = Colors.transparent;
    }

    // 1건만 조회될 경우 onTap이벤트 발생
    if(_searchList.length == 1){
      _rowDataOnTap(_searchList[0]);
    }

    setState(() {});
  }

  Future<void>  _updateOutDetail() async {
    Map<String, dynamic> newItem = <String, dynamic>{};

    if(_selectedIndex == -1) {
      showInfoAlert_pda(context, "재고를 선택해주세요.");
      return;
    }

    if(_qty.text == '0' || _qty.text.isEmpty) {
      showInfoAlert_pda(context, "0이상 입력해주세요.");
      return;
    }

    newItem["OUT_NO"] = widget.param["OUT_NO"];
    newItem["OUT_SEQ"] = widget.param["OUT_SEQ"];
    newItem["PLANT"] = widget.param["PLANT"];
    newItem["SLOC"] = widget.param["SLOC"];
    newItem["SHPR_ITEM_CD"] = widget.param["SHPR_ITEM_CD"];
    newItem["BWART"] = widget.param["BWART"];
    newItem['FROM_PLANT'] = widget.param['FROM_PLANT'];
    newItem['FROM_SLOC'] = widget.param['FROM_SLOC'];
    newItem['TO_PLANT'] = widget.param['TO_PLANT'];
    newItem['TO_SLOC'] = widget.param['TO_SLOC'];

    newItem["STOCK_SEQ"] = _searchList[_selectedIndex]["STOCK_SEQ"];
    newItem["LOCATION_CD"] = _searchList[_selectedIndex]["LOCATION_CD"];
    newItem["LOT_NO"] = _searchList[_selectedIndex]["LOT_NO"];
    newItem["GRADE"] = _searchList[_selectedIndex]["GRADE"];
    newItem["KDAUF"] = _searchList[_selectedIndex]["KDAUF"];
    newItem["KDPOS"] = _searchList[_selectedIndex]["KDPOS"];
    newItem["EBELN"] = _searchList[_selectedIndex]["EBELN"];
    newItem["EBELP"] = _searchList[_selectedIndex]["EBELP"];
    newItem["QC_STATUS"] = _searchList[_selectedIndex]["QC_STATUS"];
    newItem["LIMS_QC_STATUS"] = _searchList[_selectedIndex]["LIMS_QC_STATUS"];
    newItem["QC_FLAG"] = _searchList[_selectedIndex]["QC_FLAG"];
    newItem["STATUS"] = _searchList[_selectedIndex]["STATUS"];
    newItem["LOCATION_CD"] = _searchList[_selectedIndex]["LOCATION_CD"];
    newItem["STOCK_PLANT"] = _searchList[_selectedIndex]["PLANT"];
    newItem["STOCK_SLOC"] = _searchList[_selectedIndex]["SLOC"];

    newItem["STOCK_QTY"] = _qty.text;

    print("newItem : $newItem");

    if(widget.param['OUT_CONF_QTY'] <= widget.param['OUT_QTY']) {
      bool confirm = await confirmDialog(context, "취소", "요청수량보다 더 많이 불출하시겠습니까?");

      if(confirm) {
        print("_updateDispatch : ${newItem}");

        await transaction(context, "out/OUT0008/insertOutDetail.do", newItem, (status, responseData) {
          if (status == Constant.resSuccessCode) {
            showInfoAlert_pda(context, "저장되었습니다.");
            _search();
          }
        });
      }
    } else {
      print("_updateDispatch : ${newItem}");

      await transaction(context, "out/OUT0008/insertOutDetail.do", newItem, (status, responseData) async {
        if (status == Constant.resSuccessCode) {
          showInfoAlert_pda(context, "저장되었습니다.");
          await _qtySearch();
          await _search();
        }
      });
    }

    setState(() {});
  }

  Future<void> _qtySearch() async {
    Map<String, dynamic> param = {};

    param = {
      "OUT_NO" : widget.param["OUT_NO"],
      "SHPR_ITEM_CD" : widget.param["SHPR_ITEM_CD"],
    };

    print("%%%%%%%%%% ${param}");

    List<dynamic> rtnList = await transaction(context, "out/OUT0008/searchOutItemList.do", param);

    if(rtnList.length > 0){
      _planQty.text = rtnList[0]["OUT_CONF_QTY"].toString();
      _confQty.text = rtnList[0]["OUT_QTY"].toString();
    }

    setState(() {
    });
  }


  //
  // Future<dynamic> callInNavi(BuildContext context, [dynamic param]) async {
  //
  //   final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           fullscreenDialog: true,
  //           builder: (context) => OUT0008P02(param: param)));
  //
  //   _search();
  //
  // }

  void _rowDataOnTap(dynamic rowData){

    if (rowData != null && rowData is Map && rowData['SHPR_ITEM_CD'] != null) {
      _materialVal.text = rowData['SHPR_ITEM_CD'].toString();
    }
    // 이전에 선택된 항목들의 색상을 모두 투명하게 변경
    for (var item in _searchList) {
      item["ROW_COLOR"] = Colors.transparent;
    }

    rowData["ROW_COLOR"] = Colors.orange;
    _selectedIndex = rowData["index"];

    //_qty.text = _searchList[_selectedIndex]["STOCK_QTY"].toString();
    // {요청수량-불출수량} >= 0 ? (요청수량-불출수량) : 0
    double reqQty = double.parse(widget.param["OUT_CONF_QTY"].toString());
    double outQty = double.parse(widget.param["OUT_QTY"].toString());
    double edtQty = reqQty - outQty;
    double jago = double.parse(rowData["STOCK_QTY"].toString());

    _qty.text = edtQty >= 0 ? (edtQty > jago ? jago.toString() : edtQty.toString()) : "0";

    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();

    print(widget.param);

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

  Future<void> _handleData(String scannedValue) async {
    _scanFocus.requestFocus();

    // BIN NO scan
    if (scannedValue.startsWith(Constant.BIN_BARCODE_DELIMIT)) {
      scannedValue = scannedValue.replaceAll(Constant.BIN_BARCODE_DELIMIT, "");
      _selLocVal.text = scannedValue;
    }
    else{
      showInfoAlert_pda(context, "${Constant.BIN_BARCODE_DELIMIT}로 시작되는 Bin번호를 스캔해 주세요.");
    }

    setState(() {
      _search();
    });

    print("스캔 처리 완료");
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    ZebraDataWedgeListener.initFunc();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "재고목록",false),
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
                      Expanded(
                        child: CustomGrid([['plant','sloc'],'bin','재고수량'],
                         [['PLANT', "SLOC"], 'LOCATION_CD','STOCK_QTY'],
                          _searchList,
                          focusIndex: _selectedIndex,
                          onTap: (rowData) {
                            _rowDataOnTap(rowData);
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
                    await _handleData(scannedValue);
                  },
                ),
              )
            ],
          ),

          Row(
            children: <Widget>[
              CommonText("bin"),
              CommonLocation(
                selLocVal:_selLocVal,
                width: MediaQuery.of(context).size.width * 0.72-80,
                onEditingComplete: (scannedValue) async {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
              ),
              //CommonTextField(_selLocVal, width: MediaQuery.of(context).size.width * 0.72-100),
              CommonActionBtn("btnSearch",
                  width: 80,
                  height: MediaQuery.of(context).size.height * 0.06,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    CommonUtil.hideKeyboard();
                    _search();
              }),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("qty"),
              CommonTextField(_qty, width: MediaQuery.of(context).size.width * 0.72-100, keyboardType : TextInputType.numberWithOptions(decimal: true)),
              CommonActionBtn("불 출", width: 80,
                    height: MediaQuery.of(context).size.height * 0.06,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      CommonUtil.hideKeyboard();
                      _updateOutDetail();}),
            ],
          ),
        ],
      ),
    );
  }
}