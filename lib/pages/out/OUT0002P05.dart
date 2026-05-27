import 'dart:async';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

enum Range { FromTo, Single }

class OUT0002P05 extends StatefulWidget {
  const OUT0002P05({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0002P05 createState() => _OUT0002P05();
}

class _OUT0002P05 extends State<OUT0002P05> {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_range == Range.FromTo) FocusScope.of(context).requestFocus(_fnOne);
      if (_range == Range.Single) FocusScope.of(context).requestFocus(_fnThree);
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

    dynamic check = "N";

    if (fromValueSubString != toValueSubString) {
      check = 'Y';
      showInfoAlert_pda(context, "chkSameBarcode");
      clearTextFieldsAndFocus(context, _selFromVal, _selToVal, _fnOne);
    } else if (int.parse(fromSerial) > int.parse(toSerial)) {
      showInfoAlert_pda(context, "chkFromLessThanTo");
      clearTextFieldsAndFocus(context, _selFromVal, _selToVal, _fnOne);
    }

    if (check == "N") {
      String prefix = _fromValue.substring(0, 5);
      String postfix = fromValueSubString;

      for (int i = startSerial, j = 1; i <= endSerial; i++, j++) {
        String paddedSerial = i.toString().padLeft(fromSerial.length, '0');
        _serialList.add('$prefix$paddedSerial$postfix');
      }
    }
  }

  _deleteSerialNums() async {
    setState(() {
      count = 0;
    });

    serialNums(_fromValue, _toValue);

    if (_fromValue.length < 8 || _toValue.length < 8) {
      showInfoAlert_pda(context, "chkValidBarcodeDelete");
      clearTextFieldsAndFocus(context, _selFromVal, _selToVal, _fnThree);
      return;
    }

    Map<String, dynamic> paramMap = {
      "SERIAL_LIST": _serialList,
      "SERIAL_FROM": _selFromVal.text,
      "SERIAL_TO": _selToVal.text,
    };

    if (CommonUtil.isEmpty(_serialList)) {
      clearTextFieldsAndFocus(context, _selFromVal, _selToVal, _fnOne);
      return;
    }
    await transaction(context, "out/OUT0002/deleteSerialNums.do", paramMap,
            (status, data) {
          if (status == Constant.resSuccessCode) {
            showInfoAlert_pda(context, 'alertRemoveSerial');
          }
          clearTextFieldsAndFocus(context, _selFromVal, _selToVal, _fnOne);
        });

    setState(() {});
  }

  _deleteSerialNo() async {
    Map<String, dynamic> paramMap = {
      "SERIAL_NO": _singleValue,
    };

    if (_singleValue.length < 8) {
      showInfoAlert_pda(context, "chkValidBarcodeDelete");
      clearTextFieldsAndFocus(context, _selSingleVal, _selSingleVal, _fnThree);
      return;
    }

    await transaction(context, "out/OUT0002/deleteSerialNo.do", paramMap,
            (status, data) {
          if (status == Constant.resSuccessCode) {
            showInfoAlert_pda(context, "alertRemoveSerial");
          }
          clearTextFieldsAndFocus(context, _selSingleVal, _selSingleVal, _fnThree);
        });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: pageAppBar(context, "returnSerial"),
      body: FooterLayout(
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
                                int a=10;
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
                              _deleteSerialNums();
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
                          _deleteSerialNo();
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}