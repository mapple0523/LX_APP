import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/sys/function.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class INN0001P04 extends StatefulWidget {
  const INN0001P04({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _INN0001P04 createState() => _INN0001P04();
}

class _INN0001P04 extends State<INN0001P04> {
  final TextEditingController _scanValue = TextEditingController();
  final TextEditingController _selInQty = TextEditingController();
  final TextEditingController _selBinVal = TextEditingController();
  final TextEditingController _selInDt = TextEditingController();
  final TextEditingController _selLabelQty = TextEditingController();

  final FocusNode _fnOne = FocusNode();
  final FocusNode _fnTwo = FocusNode();
  final FocusNode _scanFocus = FocusNode();

  dynamic _selLocVal = null;
  bool _preReceiptChecked = false;
  bool _preRackChecked = false;

  List<dynamic> _slocList = [];

  @override
  void initState() {
    double InQty = double.tryParse(CommonUtil.nullObjectDef(widget.param['IN_QTY'], 0).toString()) ?? 0.0;

    double inInstQty = double.tryParse(CommonUtil.nullObjectDef(widget.param['IN_CONF_QTY'], 0).toString()) ?? 0.0;

    _selLabelQty.text = "1";

    _selInQty.text = (InQty == 0
        ? CommonUtil.getString(inInstQty)
        : CommonUtil.getString(InQty));

    _selInQty.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _selInQty.text.length,
    );

    Future.delayed(Duration.zero, () async {
      if (mounted) {
        await _sLocSearch(widget.param['PLANT']);

        print(widget.param);

        _selBinVal.text = widget.param['LOCATION_CD'];

        _selInDt.text = widget.param['IN_PLAN_DATE'];
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> updateItemInfo() async {
    if (CommonUtil.isNull(_selInQty.text)) {
      showInfoAlert_pda(context, "chkInQty");
      return;
    }

    if (_selInQty.text == "0") {
      showInfoAlert_pda(context, "chkValidQty");
      return;
    }

    // if (double.parse(_selInQty.text) != widget.param['IN_CONF_QTY']) {
    //   showInfoAlert_pda(context, "chkDiffInQty");
    //   _fnOne.requestFocus();
    //   return;
    // }

    widget.param['IN_QTY'] = _selInQty.text;
    widget.param['STOCK_QTY'] = _selInQty.text;
    widget.param['SLOC'] = _selLocVal;
    widget.param['LOCATION_CD'] = _selBinVal.text;
    widget.param['BIN'] = _selBinVal.text;
    widget.param['IN_PLAN_DATE']  = CommonUtil.removeDash(_selInDt.text);
    widget.param['LABEL_YN'] = (_preReceiptChecked || _preRackChecked) ? 'Y' : 'N';
    widget.param['PRINT_QTY']  = _selLabelQty.text;
    widget.param['LABEL_PRINT_HEADER'] = {
      "MATL_CD": widget.param['SHPR_ITEM_CD'],
      "LINE_CD": '',
      "TABLE": 'TBL_STOCK_INFO',
      "COLUMN": 'LP_BCD',
      "LABEL_TYPE": _preReceiptChecked ? '10' : '60'
    };

    Map<String, dynamic> paramCopy = Map<String, dynamic>.from(widget.param);
    widget.param['LABEL_PRINT_DATA'] = [paramCopy];

    await transaction(
        context, "inn/INN0001/saveInOrderItemInfo.do", widget.param,
            (status, data) {
          if (status == Constant.resSuccessCode) {
            Navigator.pop(context, true);
            showInfoAlert_pda(context, "alertIn");
          }
        });
  }

  Future<void> comboCallback(String id, dynamic code, dynamic name) async {
    if(id == Constant.LOCATION_TYPE_Z) {
      _selLocVal = code;
    }

    setState(() {});
  }

  Future<void> _sLocSearch(String code) async {
    Map<String, dynamic> param = {};
    _slocList = [];

    param = {
      "PLANT": code,
    };

    List<dynamic> rtnList =
    await transaction(context, "common/getCommonSlocList.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _slocList = [];
      _selLocVal = null;
    } else {
      _slocList = rtnList;
      if (_slocList.isNotEmpty) {
        String slocParam = CommonUtil.nullObjectDef(widget.param['SLOC'], '');

        if (!CommonUtil.isNull(slocParam)) {
          dynamic matched = _slocList.firstWhere(
                (item) => item["CODE"] == slocParam,
            orElse: () => null,
          );
          _selLocVal = matched != null ? matched["CODE"] : _slocList[0]["CODE"];
        } else {
          _selLocVal = _slocList[0]["CODE"];
        }
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleCMScan(String scannedValue) async {
    print("CM 타입 스캔 처리 시작: $scannedValue");
    scannedValue = CommonUtil.parseLotNo(scannedValue);

    // BIN NO scan
      if (scannedValue.startsWith(Constant.BIN_BARCODE_DELIMIT)) {
        //  기존값이 있으면 변경 불가
        if (widget.param['LOC_CHECK'] == 'Y') return;
        scannedValue = scannedValue.replaceAll(Constant.BIN_BARCODE_DELIMIT, "");
        _selBinVal.text = scannedValue;
      }
  }

  @override
  Widget build(BuildContext context) {
    //ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: pageAppBar(context, "in"),
        body: FooterLayout(
            footer: CommonActionBtn(
              "btnIn",
              onPressed: () {
                updateItemInfo();
              },
            ),
            child: SingleChildScrollView(
                child: GestureDetector(
                  onTap: () {
                    CommonUtil.hideKeyboard();
                  },
                  // ✅ Container 고정 높이 제거
                  child: _itemInfoContents(),
                )
            )
        )
    );
  }

  Widget _itemInfoContents() {
    final screenWidth = MediaQuery.of(context).size.height;
    String itemDesc = widget.param['ITEM_DESC'];
    String trimmedItemDesc = itemDesc.length > 20 ? itemDesc.substring(0, 20) + '...' : itemDesc;

    // ✅ Expanded 제거 → Column으로 변경
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
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
            CommonText("plant"),
            CommonTextField(widget.param['PLANT'], width: MediaQuery.of(context).size.width * 0.22-12.5, enabled: false),
            CommonText("sloc"),
            CommonDropdown("Z", _selLocVal, _slocList, comboCallback, width : MediaQuery.of(context).size.width * 0.22-12.5, viewType: "CN",),
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("inPlanDt"),
            CommonDatePicker( selConroller: _selInDt, clearEnabled: false),
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("inType", width: screenWidth * 0.1),
            CommonTextField(widget.param['IN_TYPE'], width: MediaQuery.of(context).size.width * 0.31-12.5, enabled: false),
            CommonText("invoiceNo", width: screenWidth * 0.11),
            CommonTextField(widget.param['INVOICE_NO'], width: MediaQuery.of(context).size.width * 0.35-12.5, enabled: false),
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
            CommonText("desc"),
            CommonTextField(trimmedItemDesc, enabled: false),
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("lotNo", width: screenWidth * 0.1,),
            CommonTextField(widget.param['LOT_NO'], width: MediaQuery.of(context).size.width * 0.31-12.5, enabled: false),
            CommonText("packId", width: screenWidth * 0.11),
            CommonTextField(widget.param['PACK_ID'], width: MediaQuery.of(context).size.width * 0.35-12.5, enabled: false),
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
            CommonText("inZone"),
            AbsorbPointer(
              absorbing: widget.param['LOC_CHECK'] == 'Y',  // Y면 터치 차단
              child: Opacity(
                opacity: widget.param['LOC_CHECK'] == 'Y' ? 0.5 : 1.0,
                child: CommonLocation(
                    focusNode: _fnTwo,
                    selLocVal: _selBinVal,
                    param: {'LOCATION_KIND': 'I'},
                    onEditingComplete: (result) {
                      CommonUtil.hideKeyboard();
                    }
                ),
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("오더번호"),
            CommonTextField(widget.param['AUFNR'], enabled: false),
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("예정/입고"),
            CommonTextField(widget.param['IN_CONF_QTY'],width: screenWidth * 0.2, enabled: false),
            SizedBox(width: 8),
            CommonTextField(
              _selInQty,
              width: screenWidth * 0.2,
              focusNode: _fnOne,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onEditingComplete: (result) {
                CommonUtil.hideKeyboard();
              },
            ),
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("입고라밸발행여부"),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              height: 24,
              child: Checkbox(
                value: _preReceiptChecked,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                onChanged: (bool value) {
                  setState(() {
                    _preReceiptChecked = value;
                    if (value) _preRackChecked = false;
                  });
                },
              ),
            ),
            CommonText("렉라밸발행여부"),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              height: 24,
              child: Checkbox(
                value: _preRackChecked,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                onChanged: (bool value) {
                  setState(() {
                    _preRackChecked = value;
                    if (value) _preReceiptChecked = false;
                  });
                },
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("라벨수량"),
            CommonTextField(
              _selLabelQty,
              focusNode: _fnOne,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onEditingComplete: (result) {
                CommonUtil.hideKeyboard();
              },
            ),
          ],
        ),
      ],
    );
  }
}