import 'dart:async';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/stk/STK0006MP01.dart';
import 'package:dtwms_app/pages/stk/STK0006MP02.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

enum Range { FromTo, Single }

class OUT0002P03 extends StatefulWidget {
  const OUT0002P03({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0002P03 createState() => _OUT0002P03();
}

class _OUT0002P03 extends State<OUT0002P03> {
  List<dynamic> _orderItemList = [];
  TextEditingController _selSingleVal = TextEditingController();
  TextEditingController _selFromVal = TextEditingController();
  TextEditingController _selToVal = TextEditingController();
  FocusNode _fnOne;
  FocusNode _fnTwo;
  FocusNode _fnThree;

  Range _range = Range.FromTo;

  String _fromValue = "";
  String _toValue = "";
  String _singleValue = "";
  List<String> _serialList = [];

  String fromValueSubString = "";
  String toValueSubString = "";

  bool selectScanReadOnly = false;

  int count = 0;

  @override
  void initState() {
    _fnOne = FocusNode();
    _fnTwo = FocusNode();
    _fnThree = FocusNode();

    if (widget.param['OUT_CONF_QTY'] == 1) _range = Range.Single;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_range == Range.FromTo) FocusScope.of(context).requestFocus(_fnOne);
      if (_range == Range.Single) FocusScope.of(context).requestFocus(_fnThree);
      _searchOutOrderItemInfo();
    });
    super.initState();
  }

  @override
  void dispose() {
    _fnOne.unfocus();
    _fnTwo.unfocus();
    _fnThree.unfocus();
    super.dispose();
  }

  _searchOutOrderItemInfo() async {
    Map<String, dynamic> param = {};

    List<dynamic> rtnList =
    await transaction(context, "out/OUT0002/getOutList.do", widget.param);

    if (CommonUtil.isEmpty(rtnList))
      _orderItemList = [];
    else
      _orderItemList = rtnList;

    if (_range == Range.FromTo)
      clearTextFieldsAndFocus(context, _selFromVal, _selToVal, _fnOne);
    if (_range == Range.Single)
      clearTextFieldsAndFocus(context, _selSingleVal, _selSingleVal, _fnThree);

    setState(() {});
  }

  void clearTextFieldsAndFocus(
      BuildContext context,
      TextEditingController textField1,
      TextEditingController textField2,
      FocusNode focusNode) {
    Timer(Duration(seconds: 1), () {
      textField1.text = "";
      textField2.text = "";
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(focusNode);
      });
    });
  }

  dynamic serialNums(String _fromValue, String _toValue) {
    if (_fromValue.length < 8 || _toValue.length < 8) return false;

    String fromSerial = "";
    String toSerial = "";

    if (_fromValue.length == 14) {
      fromSerial = _fromValue.substring(5, _fromValue.length - 4);
      toSerial = _toValue.substring(5, _toValue.length - 4);
      fromValueSubString =
          _fromValue.substring(_fromValue.length - 4, _fromValue.length);
      toValueSubString =
          _toValue.substring(_toValue.length - 4, _toValue.length);
    } else {
      fromSerial = _fromValue.substring(5, _fromValue.length - 3);
      toSerial = _toValue.substring(5, _toValue.length - 3);
      fromValueSubString =
          _fromValue.substring(_fromValue.length - 3, _fromValue.length);
      toValueSubString =
          _toValue.substring(_toValue.length - 3, _toValue.length);
    }

    int startSerial = int.parse(fromSerial);
    int endSerial = int.parse(toSerial);

    _serialList = [];

    dynamic check1 = "N";
    // dynamic check2 = "N";

    if (fromValueSubString != toValueSubString) {
      check1 = 'Y';
    }
    /*FROM과 TO의 바코드 뒷자리 3개가 맞지 않을 시에만 Y로 변경
    if(_fromValue.substring(_fromValue.length-3,_fromValue.length) != widget.param['ITEM_BARCODE']){
      check1 = 'Y';
    }
    else if(_toValue.substring(_toValue.length-3,_toValue.length) != widget.param['ITEM_BARCODE']) {
      check2 = 'Y';
    }*/

    if (int.parse(fromSerial) > int.parse(toSerial)) {
      showInfoAlert_pda(context, "chkFromLessThanTo");
      clearTextFieldsAndFocus(context, _selFromVal, _selToVal, _fnOne);
      return false;
    }

    if (check1 == "N") {
      String prefix = _fromValue.substring(0, 5);
      String postfix = fromValueSubString;
      for (int i = startSerial, j = 1; i <= endSerial; i++, j++) {
        String paddedSerial = i.toString().padLeft(fromSerial.length, '0');
        _serialList.add('$prefix$paddedSerial$postfix');
      }
    }
  }

  _saveSerialNums() async {
    setState(() {
      count = 0;
    });

    serialNums(_fromValue, _toValue);

    if (_fromValue.length < 8 || _toValue.length < 8) {
      showInfoAlert_pda(context, "chkValidBarcode");
      clearTextFieldsAndFocus(context, _selFromVal, _selToVal, _fnThree);
      return;
    }

    dynamic flag;
    if (CommonUtil.isEmpty(widget.param['custList'])) {
      flag = "Y";
    } else {
      flag = "N";
    }
    Map<String, dynamic> paramMap = {
      "OUT_NO": widget.param['OUT_NO'],
      "OUT_SEQ": widget.param['OUT_SEQ'],
      "POSNR": widget.param['POSNR'],
      "OUT_VIEW_NO": widget.param['OUT_VIEW_NO'],
      "ITEM_BARCODE": fromValueSubString,
      "PLANT": widget.param['PLANT'],
      "SLOC": widget.param['SLOC'],
      "CUST_CD": widget.param['CUST_CD'],
      "CUST_NM": widget.param['CUST_NM'],
      "OUT_TYPE": widget.param['OUT_TYPE'],
      /*"ITEM_DESC": widget.param['ITEM_DESC'],
      "SHPR_ITEM_CD": widget.param['SHPR_ITEM_CD'],
      "ITEM_UNIT": widget.param['ITEM_UNIT'],*/
      "FLAG": flag,
      "custList": widget.param['custList'],
      "SERIAL_LIST": _serialList,
      "SERIAL_FROM": _selFromVal.text,
      "SERIAL_TO": _selToVal.text,
      "SERIAL_COUNT": _serialList.length
    };

    if (CommonUtil.isEmpty(_serialList)) {
      showInfoAlert_pda(context, "chkValidBarcode");
      clearTextFieldsAndFocus(context, _selFromVal, _selToVal, _fnOne);
      return;
    }
    await transaction(context, "out/OUT0002/saveSerialNums.do", paramMap,
            (status, data) {
          if (status == Constant.resSuccessCode) {
            showInfoAlert_pda(context, "alertRegisterSerial");
            _searchOutOrderItemInfo();
          }
          clearTextFieldsAndFocus(context, _selFromVal, _selToVal, _fnOne);
        });

    setState(() {});
  }

  _saveSerialNo() async {
    dynamic flag;
    if (CommonUtil.isEmpty(widget.param['custList'])) {
      flag = "Y";
    } else {
      flag = "N";
    }

    if (_singleValue.length < 8) {
      showInfoAlert_pda(context, "chkValidBarcode");
      clearTextFieldsAndFocus(context, _selSingleVal, _selSingleVal, _fnThree);
      return;
    }

    dynamic barCode;

    if (_singleValue.length == 14) {
      barCode =
          _singleValue.substring(_singleValue.length - 4, _singleValue.length);
    } else {
      barCode =
          _singleValue.substring(_singleValue.length - 3, _singleValue.length);
    }

    Map<String, dynamic> paramMap = {
      "OUT_NO": widget.param['OUT_NO'],
      "OUT_SEQ": widget.param['OUT_SEQ'],
      "POSNR": widget.param['POSNR'],
      "OUT_VIEW_NO": widget.param['OUT_VIEW_NO'],
      "ITEM_BARCODE": barCode, //내가 찍은 바코드 뒤의 3자리를 들고와야 한다.
      "SERIAL_NO": _singleValue,
      "PLANT": widget.param['PLANT'],
      "SLOC": widget.param['SLOC'],
      "CUST_CD": widget.param['CUST_CD'],
      "CUST_NM": widget.param['CUST_NM'],
      "OUT_TYPE": widget.param['OUT_TYPE'],
      /*"SHPR_ITEM_CD": widget.param['SHPR_ITEM_CD'], //내가 찍은 바코드 뒤 3자리로 찾아서 가져와야 한다.
        "ITEM_DESC": widget.param['ITEM_DESC'],//따로 찾아야함
        "ITEM_UNIT": widget.param['ITEM_UNIT'],//따로 찾아야함*/
      "FLAG": flag,
      "custList": widget.param['custList'],
      "SERIAL_COUNT": 1
    };

    await transaction(context, "out/OUT0002/saveSerialNo.do", paramMap,
            (status, data) {
          if (status == Constant.resSuccessCode) {
            showInfoAlert_pda(context, 'alertRegisterSerial');
            _searchOutOrderItemInfo();
          }
          clearTextFieldsAndFocus(context, _selSingleVal, _selSingleVal, _fnThree);
        });

    setState(() {});
  }

  Future<dynamic> _movePageBoxPacking(BuildContext context,
      [dynamic param]) async {
    Map<String, dynamic> param = {};
    if (CommonUtil.isEmpty(widget.param['custList'])) {
      param["OUT_NO"] = widget.param['OUT_VIEW_NO'];
    } else {
      param["CUST_CD"] = widget.param['CUST_CD'];
      param["_searchCustOutList"] = widget.param['custList'];
    }
    await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => STK0006MP01(param: param)));
  }

  Future<dynamic> _movePagePalletPacking(BuildContext context,
      [dynamic param]) async {
    Map<String, dynamic> param = {};
    if (CommonUtil.isEmpty(widget.param['custList'])) {
      param["OUT_NO"] = widget.param['OUT_VIEW_NO'];
    } else {
      param["CUST_CD"] = widget.param['CUST_CD'];
      param["_searchCustOutList"] = widget.param['custList'];
    }
    await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => STK0006MP02(param: param)));
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: pageAppBar(context, "registerSerial", true),
      body: FooterLayout(
        footer: Row(
          children: [
            CommonActionBtn(
              "boxPacking",
              width: 170,
              onPressed: () {
                _movePageBoxPacking(context);
              },
            ),
            CommonActionBtn(
              "palletPacking",
              width: 170,
              onPressed: () {
                _movePagePalletPacking(context);
              },
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              CommonUtil.hideKeyboard();
            },
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _range = Range.FromTo;
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            Radio(
                              value: Range.FromTo,
                              groupValue: _range,
                              onChanged: (value) {
                                setState(() {
                                  _range = value as Range;
                                  _selFromVal = TextEditingController();
                                  _selToVal = TextEditingController();
                                  _fnThree.unfocus();
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    FocusScope.of(context).requestFocus(_fnOne);
                                  });
                                });
                              },
                            ),
                            Text('From To'),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _range = Range.Single;
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            Radio(
                              value: Range.Single,
                              groupValue: _range,
                              onChanged: (value) {
                                setState(() {
                                  _range = value as Range;
                                  _selSingleVal = TextEditingController();
                                  _fnOne.unfocus();
                                  _fnTwo.unfocus();
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    FocusScope.of(context)
                                        .requestFocus(_fnThree);
                                  });
                                });
                              },
                            ),
                            Text('Single'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_range == Range.FromTo)
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          CommonText("from"),
                          /*CommonTextField(
                            _selFromVal,
                            focusNode: _fnOne,
                            onSubmitted: ([result]) {
                              _selFromVal = _selFromVal;
                              _fromValue = _selFromVal.text;
                              _fnOne.unfocus();
                              FocusScope.of(context).requestFocus(_fnTwo);
                            },
                          )*/
                          CommonScanTextField(
                            _selFromVal,
                            focusNode: _fnOne,
                            scanType: 'SE',
                            keyboardEnabled: false,
                            selectScanReadOnly: false,
                            selectAllFlag: false,
                            iconClearFlag: true,
                            onChanged: ([result]) {
                              if (count == 1 && _fromValue.length == 13) {
                                int currentLength = _selFromVal.text.length;
                                if (currentLength == 13) {
                                  _selFromVal = _selFromVal;
                                  _fromValue = _selFromVal.text;
                                  _fnOne.unfocus();
                                  FocusScope.of(context).requestFocus(_fnTwo);
                                }
                              } else if (count == 1 &&
                                  _fromValue.length == 14) {
                                int currentLength = _selFromVal.text.length;
                                if (currentLength == 14) {
                                  _selFromVal = _selFromVal;
                                  _fromValue = _selFromVal.text;
                                  _fnOne.unfocus();
                                  FocusScope.of(context).requestFocus(_fnTwo);
                                }
                              }
                            },
                            onEditingComplete: ([result]) {
                              setState(() {
                                count++;
                              });
                              _selFromVal = _selFromVal;
                              _fromValue = _selFromVal.text;
                              _fnOne.unfocus();
                              if (!CommonUtil.isNull(_selFromVal.text)) {
                                Timer(Duration(milliseconds: 100), () {
                                  FocusScope.of(context).requestFocus(_fnTwo);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          CommonText("to"),
                          /*CommonTextField(
                            _selToVal,
                            focusNode: _fnTwo,
                            onSubmitted: ([result]) {
                              _selToVal = _selToVal;
                              _toValue = _selToVal.text;
                              _saveSerialNums();
                            },
                          )*/
                          CommonScanTextField(
                            _selToVal,
                            focusNode: _fnTwo,
                            scanType: 'SE',
                            keyboardEnabled: false,
                            selectScanReadOnly: false,
                            selectAllFlag: false,
                            iconClearFlag: true,
                            onEditingComplete: ([result]) {
                              _selToVal = _selToVal;
                              _toValue = _selToVal.text;
                              _fnTwo.unfocus();
                              Timer(Duration(milliseconds: 100), () {
                                FocusScope.of(context).requestFocus(_fnTwo);
                              });
                            },
                            onSubmitted: (result) {
                              _saveSerialNums();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                if (_range == Range.Single)
                  Row(
                    children: <Widget>[
                      CommonText("single"),
                      /*CommonTextField(
                        _selSingleVal,
                        focusNode: _fnThree,
                        onSubmitted: ([result]) {
                          _singleValue = _selSingleVal.text;
                          _saveSerialNo();
                        },
                      )*/
                      CommonScanTextField(
                        _selSingleVal,
                        focusNode: _fnThree,
                        keyboardEnabled: false,
                        selectScanReadOnly: false,
                        selectAllFlag: false,
                        iconClearFlag: true,
                        scanType: 'SE',
                        onEditingComplete: ([result]) {
                          _singleValue = _selSingleVal.text;
                          _saveSerialNo();
                        },
                      ),
                    ],
                  ),
                _orderItemListView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderItemListView() {
    return CustomGrid(
      ['item', 'outQty', 'scanQty'],
      ['SHPR_ITEM_CD', 'OUT_CONF_QTY', 'SERIAL_COUNT'],
      _orderItemList,
      //height: 320,
      onRefresh: () {
        _searchOutOrderItemInfo();
      },
    );
  }
}