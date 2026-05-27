import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class OUT0001P01 extends StatefulWidget {
  const OUT0001P01({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0001P01 createState() => _OUT0001P01();
}

class _OUT0001P01 extends State<OUT0001P01> {
  final TextEditingController _locaBarcode  = TextEditingController();
  final TextEditingController _itemBarcode  = TextEditingController();
  final TextEditingController _selOutQty    = TextEditingController();
  final TextEditingController _outLocation  = TextEditingController();
  final FocusNode _fnOne = FocusNode();
  final FocusNode _fnTwo = FocusNode();
  final FocusNode _fnThr = FocusNode();

  @override
  void initState() {

    double pickQty     = CommonUtil.nullObjectDef(double.tryParse(widget.param['PICK_QTY'].toString()), 0.0);
    double pickInstQty = (CommonUtil.nullObjectDef(widget.param['PICK_INST_QTY'], 0.0) as num).toDouble();

    //_selOutQty.text = widget.param['STOCK_QTY'].toString();
    _locaBarcode.text = widget.param['LOCATION_CD'];

    // 피킹지시수량보다 재고수량이 많을경우에는 재고수량 적을경우에는 피킹지시수량
    if(widget.param['STOCK_QTY'] >= widget.param['PICK_INST_QTY'])
      _selOutQty.text = widget.param['PICK_INST_QTY'].toString();
    else
      _selOutQty.text = widget.param['STOCK_QTY'].toString();

    // if(CommonUtil.isNull(_locaBarcode.text)) {
    //   _fnOne.requestFocus();
    // }
    // else{
    //   _fnTwo.requestFocus();
    // }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _callBarcodeScanInfo() async {
    if(_itemBarcode.text.isNotEmpty && _locaBarcode.text.isNotEmpty) {
      Map<String, dynamic> param = {
        "LOCATION_CD": _locaBarcode.text.toUpperCase(),
        "ITEM_BARCODE": _itemBarcode.text,
        "SHPR_ITEM_CD": widget.param['SHPR_ITEM_CD'],
        "SHPR_CD": widget.param['SHPR_CD'],
        "STOCK_SEQ": widget.param['STOCK_SEQ'],
        "SHRP_ITEM_CD": widget.param['SHPR_ITEM_CD'],
        "IN_DATE": widget.param['IN_DATE'],
        "VAL_OUT_LOCATION_CD": widget.param['VAL_OUT_LOCATION_CD'],
        "HOLD_QTY": widget.param['HOLD_QTY'],
      };

      dynamic result = await transaction(context, "out/OUT0001/chkItemValid.do", param);
      if(result == "E") {
        showInfoAlert_pda(context, "chkPickItem");
        _itemBarcode.text = "";
        _locaBarcode.text = "";
        setState(() {
          FocusScope.of(context).requestFocus(_fnOne);
        });
      }

    }
  }

  Future<void> _saveInOrderInfo() async {

    if(_locaBarcode.text.toUpperCase() != widget.param['LOCATION_CD']) {
      showInfoAlert_pda(context, "chkDiffPickLoca");
      _fnOne.requestFocus();
      return;
    }

    if(CommonUtil.isNull(_selOutQty.text)) {
      showInfoAlert_pda(context, "chkPickQty");
      return;
    }

    // if(int.parse(_selOutQty.text) != widget.param['PICK_INST_QTY']) {
    //   showInfoAlert_pda(context, "chkDiffPickQty");
    //   _fnTwo.requestFocus();
    //   return;
    // }

    widget.param['SCAN_LOCATION_CD'] = _locaBarcode.text.toUpperCase();
    widget.param['SCAN_ITEM_BARCODE'] = _itemBarcode.text;
    widget.param['VAL_OUT_QTY'] = _selOutQty.text;
    widget.param['PICK_QTY'] = _selOutQty.text;

    print(widget.param);

    await transaction(context, "out/OUT0001/doPicking.do", widget.param, (status, data) {
      if(status == Constant.resSuccessCode) {
          Navigator.pop(context, true);
          showInfoAlert_pda(context, "alertPick");
      }
    });
  }

  Future<void> _handleCMScan(String scannedValue) async {
    FocusScope.of(context).unfocus();

    print("CM 타입 스캔 처리 시작: $scannedValue");
    _locaBarcode.text = scannedValue;
    setState(() {

    });

    print("CM 타입 스캔 처리 완료");
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset : true,
        appBar: pageAppBar(context, "분할피킹"),
        body: FooterLayout(
          footer:  CommonActionBtn("btnPick",
            onPressed: () {
            FocusScope.of(context).unfocus();
            _saveInOrderInfo();
          },),
          child: SingleChildScrollView(
            child: GestureDetector(
            onTap: (){
            CommonUtil.hideKeyboard();
            },
            child: Container(
              height: CommonUtil.pageMaxHeight(context,-280),
              child: Column(
                children: <Widget> [
                  _pickInfoContents(),
                ],
              ),
            )
          )
          )
          )
    );
  }

  Widget _pickInfoContents() {
    String itemDesc = widget.param['ITEM_DESC'];
    String trimmedItemDesc = itemDesc.length > 20 ? itemDesc.substring(0, 20) + '...' : itemDesc;

    return Expanded (
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("plant"),
              CommonTextField(widget.param['PLANT'], width: MediaQuery.of(context).size.width * 0.22-12.5, enabled: false),
              CommonText("sloc"),
              CommonTextField(widget.param['SLOC'], width: MediaQuery.of(context).size.width * 0.22-12.5, enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("inDt"),
              CommonTextField(widget.param['IN_DATE_FM'], enabled: false),
            ],
          ),

          Row(
            children: <Widget>[
              CommonText("materialCd"),
              CommonTextField(widget.param['SHPR_ITEM_CD'], enabled: false),
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
              CommonText("desc"),
              CommonTextField(trimmedItemDesc,
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("unit"),
              CommonTextField(widget.param['ITEM_UNIT'], width: MediaQuery.of(context).size.width * 0.22-12.5, enabled: false),
              CommonText("grade"),
              CommonTextField(widget.param['GRADE'], width: MediaQuery.of(context).size.width * 0.22-12.5, enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("instBin"),
              CommonTextField(widget.param['LOCATION_CD'],
                  enabled : false
              ),
            ],
          ),
          Visibility(
            visible: false,
            child: Row(
              children: <Widget>[
                CommonText("bin"),
                CommonScanTextField(_locaBarcode,
                  focusNode: _fnOne,
                  scanType: "CM",
                  onTap: () {},
                  onEditingComplete: (scannedValue) async {
                    await _handleCMScan(scannedValue);
                  },
                )
              ],
            ),
          ),
          Row(
            children: <Widget>[
              CommonText("pickInstQty"),
              CommonTextField(widget.param['PICK_INST_QTY'],
                  focusNode: _fnTwo,
                  enabled : false
              ),
            ],
          ),

          Row(
            children: <Widget>[
              CommonText("pickQty"),
              CommonTextField(_selOutQty,
                  focusNode : _fnThr
                  , keyboardType : TextInputType.numberWithOptions(decimal: true)
                  , onEditingComplete : (nodeObj) {
                    CommonUtil.hideKeyboard();
                    if(widget.param['REMAIN_QTY'] < int.parse(_selOutQty.text))
                      _selOutQty.text = widget.param['REMAIN_QTY'];
                  }
              ),
            ],
          ),
        ],
      ),
    );
  }
}