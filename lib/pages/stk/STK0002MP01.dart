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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class STK0002MP01 extends StatefulWidget {
  const STK0002MP01({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _STK0002MP01 createState() => _STK0002MP01();
}

class _STK0002MP01 extends State<STK0002MP01> {
  final TextEditingController _selMoveQty = TextEditingController();
  final TextEditingController _selLocTo = TextEditingController();
  final FocusNode _scanFocus = FocusNode();
  final TextEditingController _scanValue = TextEditingController();


  _UpdateQty() async {
    if (CommonUtil.isNull(_selLocTo.text)) {
      showInfoAlert_pda(context, "chkMoveLoca");
    } else if (_selLocTo.text == widget.param['LOCATION_CD']) {
      showInfoAlert_pda(context, "chkMoveSameLoca");
    } else if (CommonUtil.isNull(_selMoveQty.text)) {
      showInfoAlert_pda(context, "chkMoveQty");
    } else if (double.parse(_selMoveQty.text) == 0) {
      showInfoAlert_pda(context, "chkValidQty");
    } else {
      Map<String, dynamic> paramMap = {
        "locationCd": widget.param['LOCATION_CD'],
        "packId": widget.param['PACK_ID'],
        "stockQty": double.parse(widget.param['STOCK_QTY']),
        "expireDate": widget.param['EXPIRE_DATE'],
        "EXPIRE_DATE": widget.param['EXPIRE_DATE'],
        "shprItemCd": widget.param['SHPR_ITEM_CD'],
        "stockSeq": widget.param['STOCK_SEQ'],
        "PLANT_VALUE": widget.param['PLANT'],
        "PLANT": widget.param['PLANT'],
        "S_LOC": widget.param['SLOC'],
        "SLOC": widget.param['SLOC'],
        "grade": widget.param['GRADE'],
        "GRADE": widget.param['GRADE'],
        "LOT_NO": widget.param['LOT_NO'],
        "PACK_ID": widget.param['PACK_ID'],
        "STOCK_SEQ": widget.param['STOCK_SEQ'],
        "IN_DATE": widget.param['IN_DATE'],
        "moveLocation": _selLocTo.text,
        "moveQty": double.parse(_selMoveQty.text),
        "holdQty": double.parse(widget.param['HOLD_QTY']),
        "KDAUF": widget.param['KDAUF'],
        "KDPOS": widget.param['KDPOS'],
        "EBELN": widget.param['EBELN'],
        "EBELP": widget.param['EBELP'],
        "QC_STATUS": widget.param['QC_STATUS'],
        "LIMS_QC_STATUS": widget.param['LIMS_QC_STATUS'],
        "QC_FLAG": widget.param['QC_FLAG'],
        "STATUS": widget.param['STATUS'],
        "RTN_MBLNR": widget.param['RTN_MBLNR'],
        "RTN_MJAHR": widget.param['RTN_MJAHR'],
        "MEHQ": widget.param['MEHQ'],
        "AO30": widget.param['AO30'],
      };
      Map<String, dynamic> _checkList =
          await transaction(context, "/stk0002/stockCheckInfo.do", paramMap);

      if (!CommonUtil.isNull(_checkList.toString())) {
        if (!CommonUtil.isNull(_checkList['CHECK_STATUS'])) {
          showInfoAlert_pda(context, "chkMoveStatus");
        }
      } else if (double.parse(_selMoveQty.text) >
          double.parse(widget.param['STOCK_QTY']) - double.parse(widget.param['HOLD_QTY'])) {
        showInfoAlert_pda(context, "chkHoldQty");
      } else {
        await transaction(context, "/stk0002/saveStockMove.do", paramMap,
            (status, data) {
          if (status == Constant.resSuccessCode) {
            Navigator.pop(context, true);
            showInfoAlert_pda(context, "alertMove");
          }
        });
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //FocusScope.of(context).requestFocus(fnOne);
      _selMoveQty.text = widget.param['STOCK_QTY'].toString();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleCMScan(String scannedValue) async {

    print("CM 타입 스캔 처리 시작: $scannedValue");

    // BIN NO scan
    if (scannedValue.startsWith(Constant.BIN_BARCODE_DELIMIT)) {
      scannedValue = scannedValue.replaceAll(Constant.BIN_BARCODE_DELIMIT, "");
      _selLocTo.text = scannedValue;
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
    var color = 0xff453658;
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: pageAppBar(context, "stockMove", true),
        body: FooterLayout(
            footer: CommonActionBtn(
              "btnStockMove",
              height: 50,
              onPressed: () {
                _UpdateQty();
              },
            ),
            child: SingleChildScrollView(
                child: GestureDetector(
                    onTap: () {
                      CommonUtil.hideKeyboard();
                      _scanFocus.requestFocus();
                    },
                    child: Container(
                      height: CommonUtil.pageMaxHeight(context,-280),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                              child: Column(children: [
                            Row(children: <Widget>[
                              _searchFieldDetail(),
                            ]),
                            // Row(children: <Widget>[_stockUpdate(),])
                          ])),
                        ],
                      ),
                    )))));
  }

  Widget _searchFieldDetail() {
    String itemDesc = widget.param['ITEM_DESC'];
    String trimmedItemDesc = itemDesc.length > 20 ? itemDesc.substring(0, 20) + '...' : itemDesc;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("plant", width: 78),
              CommonTextField(widget.param['PLANT'], width: 90, enabled: false),
              CommonText("sloc", width: 78,),
              CommonTextField(widget.param['SLOC'], width: 90, enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("inDt"),
              CommonTextField(widget.param['IN_DATE_FM'], enabled: false)
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("materialCd"),
              CommonTextField(widget.param['SHPR_ITEM_CD'], enabled: false)
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
              CommonTextField(trimmedItemDesc, enabled: false)
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("unit", width: 78),
              CommonTextField(widget.param['ITEM_UNIT'], width: 90, enabled: false),
              CommonText("grade", width: 78),
              CommonTextField(widget.param['GRADE'], width: 90, enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("MEHQ", width: 78),
              CommonTextField(widget.param['MEHQ'], width: 90, enabled: false),
              CommonText("AO30", width: 78),
              CommonTextField(widget.param['AO30'], width: 90, enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("bin"),
              CommonTextField(widget.param['LOCATION_CD'], enabled: false)
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("tobin"),
              CommonLocation(
                selLocVal:_selLocTo,
                onEditingComplete: (scannedValue) async {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("moveAvailQty"),
              CommonTextField(
                  CommonUtil.nullStrDef(widget.param['STOCK_QTY'].toString()),
                  enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("moveQty"),
              CommonTextField(_selMoveQty,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onEditingComplete: ([result]) {
                    CommonUtil.hideKeyboard();
                    _scanFocus.requestFocus();
                  }
              ),
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
        ],
      ),
    );
  }

}
