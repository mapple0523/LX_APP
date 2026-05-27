import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class INN0002P01 extends StatefulWidget {
  INN0002P01({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _NN0002P01 createState() => _NN0002P01();
}

class _NN0002P01 extends State<INN0002P01> {
  final TextEditingController _selLocVal = TextEditingController();
  final TextEditingController _selPutQtyVal = TextEditingController();
  final TextEditingController _scanValue = TextEditingController();

  final FocusNode _scanFocus = FocusNode();
  final FocusNode _fnTwo = FocusNode();

  List<dynamic> _orderList = [{}];

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<dynamic>>_searchOrderPutInfo(BuildContext context, Map<String, dynamic> param) async {
    print(widget.param);
    double PutQty = 0.0;
    Map<String, dynamic> param = {};
    param["IN_NO"] = widget.param['IN_NO'];
    param["SHPR_ITEM_CD"] = widget.param['SHPR_ITEM_CD'];
    param["IN_SEQ"] = widget.param['IN_SEQ'];
    param["ITEM_SEQ"] = widget.param['ITEM_SEQ'];
    List<dynamic> rtnList = await transaction(context, "inn/INN0002/getInOrderPutInfo.do", param);

    print(CommonUtil.isEmpty(rtnList));
    if(CommonUtil.isEmpty(rtnList)){
      PutQty = 0;
    }
    else{
      PutQty = CommonUtil.nullObjectDef(rtnList[0]['IN_QTY'], 0);
    }

    _selPutQtyVal.text = CommonUtil.getString(PutQty);

    _selPutQtyVal.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _selPutQtyVal.text.length,
    );

    _selLocVal.text = widget.param['LOCATION_CD'];

    return rtnList;
  }

  _saveInOrderItemPutInfo() async {
    if (CommonUtil.isNull(_selLocVal.text)) {
      showInfoAlert_pda(context, "chkPutLoca");
      _scanFocus.requestFocus();
      return;
    }

    if (CommonUtil.isNull(_selPutQtyVal.text)) {
      showInfoAlert_pda(context, "chkPutQty");
      return;
    }

    if (_selPutQtyVal.text == "0") {
      showInfoAlert_pda(context, "chkValidQty");
      return;
    }

    /*if (int.parse(_selPutQtyVal.text) != widget.param['IN_QTY']) {
      showInfoAlert_pda(context, "chkDiffPutQty");
      _fnTwo.requestFocus();
      return;
    }*/

    dynamic saveData = ConvertUtil.copyObject(widget.param);

    saveData['LOCATION_CD'] = _selLocVal.text.toUpperCase();
    saveData['IN_LOCATION_CD'] = widget.param['IN_LOCATION_CD'];
    saveData['PUT_QTY'] = _selPutQtyVal.text;
    await transaction(context, "inn/INN0002/saveInOrderItemPutInfo.do", saveData,(status, data) {
      print(status);
      if (status == Constant.resSuccessCode) {
        //여기부터 해야함 아침에 와서
        // _searchOrderPutInfo(context,widget.param).then((data) =>  setState(() {
        //   showInfoAlert_pda(context, "alertPut");
        // }));
        Navigator.pop(context, true);
        showInfoAlert_pda(context, "alertPut");
      }
    });
  }

  @override
  void initState() {

    //WidgetsBinding.instance.addPostFrameCallback((_) => FocusScope.of(context).requestFocus(_fnOne));
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _searchOrderPutInfo(context,widget.param).then((data) =>  setState(() {
          _orderList = data;
          if(CommonUtil.isEmpty(_orderList))
            _orderList = [];
          else
            _orderList = data;
        }))
    );

    super.initState();
  }

  Future<void> _handleCMScan(String scannedValue) async {
    print("CM 타입 스캔 처리 시작: $scannedValue");

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
    });

    print("CM 타입 스캔 처리 완료");
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: pageAppBar(context, "stockPut", true),
        body: FooterLayout(
            footer: CommonActionBtn(
              "btnStockPut",
              onPressed: () {
                _saveInOrderItemPutInfo();
              },
            ),
            child: SingleChildScrollView(
                child: GestureDetector(
                    onTap: () {
                      CommonUtil.hideKeyboard();
                    },
                    child: Container(
                      height: CommonUtil.pageMaxHeight(context,-230),
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
    String itemDesc = list[0]['ITEM_DESC'];
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
              CommonText("plant"),
              CommonTextField(list[0]['PLANT'], width: MediaQuery.of(context).size.width * 0.22-12.5 , enabled: false),
              CommonText("sloc"),
              CommonTextField(list[0]['SLOC'], width: MediaQuery.of(context).size.width * 0.22-12.5 , enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("inDt"),
              CommonTextField(list[0]['IN_DATE_FM'], enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("lotNo"),
              CommonTextField(list[0]['LOT_NO'], enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("materialCd"),
              CommonTextField(list[0]['SHPR_ITEM_CD'], enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("invoiceNo"),
              CommonTextField(list[0]['INVOICE_NO'], enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("desc"),
              CommonTextField(trimmedItemDesc, enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("lotNo"),
              CommonTextField(widget.param['LOT_NO'], enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("packId"),
              CommonTextField(widget.param['PACK_ID'], enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("차량번호"),
              CommonTextField(widget.param['VEHICLE_NO'], enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("unit"),
              CommonTextField(list[0]['ITEM_UNIT'],
                  width: MediaQuery.of(context).size.width * 0.22-12.5, enabled: false),
              CommonText("grade"),
              CommonTextField(list[0]['GRADE'], width: MediaQuery.of(context).size.width * 0.22-12.5, enabled: false),
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
                    await _handleCMScan(scannedValue);
                  },
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("putZone"),
              CommonLocation(
                  selLocVal: _selLocVal,
                  onEditingComplete: (result) {
                    CommonUtil.hideKeyboard();
                    _scanFocus.requestFocus();
                  },
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("inQty"),
              CommonTextField(list[0]['IN_QTY'], enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("putQty"),
              CommonTextField(
                _selPutQtyVal,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                focusNode: _fnTwo,
                onEditingComplete: (result) {
                  CommonUtil.hideKeyboard();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
