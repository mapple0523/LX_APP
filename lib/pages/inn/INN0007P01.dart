import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/commWidget.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'INN0002P01.dart';

class INN0007P01 extends StatefulWidget {
  INN0007P01({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _INN0007P01 createState() => _INN0007P01();
}

class _INN0007P01 extends State<INN0007P01>  {
  DateTime _schInDt = DateTime.now();

  dynamic _plantValue  = null;
  dynamic _slocVal = null;

  final TextEditingController _inLabelQty = TextEditingController();
  final TextEditingController _lackLabelQty = TextEditingController();

  bool _preReceiptChecked = false;

  // ✅ CustomGrid 강제 재빌드용 key
  int _gridKey = 0;

  final TextEditingController _selInDt = TextEditingController();

  FocusNode _fnOne;
  FocusNode _fnTwo;
  FocusNode _fnThree;

  List<dynamic> _orderList = [];
  List<dynamic> _slocList = [];
  List<dynamic> _selectedItems = [];

  Future<void> _searchOrderPutInfo(bool autoFlag) async {
    FocusScope.of(context).unfocus();

    List<dynamic> rtnList =
    await transaction(context, "inn/INN0007/searchPoDetailList.do", widget.param);

    if(CommonUtil.isEmpty(rtnList)) {
      _orderList = [];
    } else {
      // ✅ 소수점 정리
      _orderList = rtnList.map((item) {
        Map<String, dynamic> row = Map<String, dynamic>.from(item);

        if (row['PO_QTY'] != null) {
          double val = double.tryParse(row['PO_QTY'].toString()) ?? 0;
          row['PO_QTY'] = double.parse(val.toStringAsFixed(3));
        }
        if (row['BAL_QTY'] != null) {
          double val = double.tryParse(row['BAL_QTY'].toString()) ?? 0;
          row['BAL_QTY'] = double.parse(val.toStringAsFixed(3));
          row['EDIT_QTY'] = row['BAL_QTY'].toString();
        }

        return row;
      }).toList();
    }

    setState(() {});
  }

  Future<void> _saveInOrderInfo() async {

    if(_slocVal == '' || _slocVal == null) {
      showInfoAlert_pda(context, "SLOC를 입력해주십시오.");
      return;
    }

    for (var item in _orderList) {
      String editQty = item['EDIT_QTY']?.toString() ?? '';
      if (editQty.isEmpty || editQty == '0') {
        showInfoAlert_pda(context, "입고수량을 입력해주세요.");
        return;
      }
    }

    // ✅ orderList 길이만큼 순차 호출
    for (var item in _orderList) {
      bool success = false;

      Map<String, dynamic> rowItem = Map<String, dynamic>.from(item);
      rowItem['IN_QTY'] = item['EDIT_QTY'];
      rowItem['LOCATION_CD'] = item['LOCATION_CD'];
      rowItem['preInYn'] = _preReceiptChecked ? 'Y' : 'N';
      rowItem['LOC_CHECK'] = item['LOC_CHECK'];

      Map<String, dynamic> sendData = {
        ...Map<String, dynamic>.from(item),
        "plant": widget.param['PLANT'],
        "sLoc": _slocVal,
        'preInYn': _preReceiptChecked ? 'Y' : 'N',
        'inPlanDt': CommonUtil.removeDash(_selInDt.text),
        "LOCATION_CD": item['LOCATION_CD'],
        "LOC_CHECK": item['LOC_CHECK'],
        "IN_QTY": item['EDIT_QTY'],
        "list": [rowItem],  // ✅ 단일 아이템을 list로 감싸서 전송
      };

      await transaction(context, "inn/INN0007/saveInOrderItemPutInfo.do", sendData, (status, data) {
        if (status == Constant.resSuccessCode) {
          success = true;
        }
      });

      //if (!success) return;
    }

    Navigator.pop(context, true);
    showInfoAlert_pda(context, "입고되었습니다.");
  }

  Future<void> _sLocSearch() async {
    Map<String, dynamic> param = {};
    _slocList = [];

    param = {
      "PLANT": widget.param['PLANT'],
    };

    List<dynamic> rtnList = await transaction(context, "common/getCommonSlocList.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _slocList = [];
      _slocVal = null;
    } else {
      _slocList = rtnList;
      if (widget.param['SLOC'] != null)
        _slocVal = widget.param['SLOC'];
      else
        _slocVal = _slocList[0]["CODE"];
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> comboCallback(String id, dynamic code, dynamic name) async {
    if(id == Constant.LOCATION_TYPE_Z) {
      _slocVal = code;
    }
    setState(() {});
  }

  Future<void> _labelPrint() async {

    if (_selectedItems.isEmpty) {
      showInfoAlert_pda(context, "항목을 선택해주세요.");
      return;
    }

    String printQty = _inLabelQty.text.isNotEmpty
        ? _inLabelQty.text
        : _lackLabelQty.text;
    String labelType = _inLabelQty.text.isNotEmpty ? '10' : '60';

    List<Map<String, dynamic>> labelDataList = _selectedItems.map((item) {
      Map<String, dynamic> itemCopy = Map<String, dynamic>.from(item);
      itemCopy['LABEL_PRINT_HEADER'] = {
        "MATL_CD": item['SHPR_ITEM_CD'],
        "LINE_CD": '',
        "TABLE": 'TBL_STOCK_INFO',
        "COLUMN": 'LP_BCD',
        "LABEL_TYPE": labelType
      };
      itemCopy['PRINT_QTY'] = printQty;
      itemCopy['STOCK_QTY'] = (item['EDIT_QTY'] != null && item['EDIT_QTY'].toString().isNotEmpty) ? item['EDIT_QTY'] : '0';
      itemCopy['BIN'] = item['LOCATION_CD'];
      itemCopy['IN_DT'] = _selInDt.text;
      return itemCopy;
    }).toList();

    for (var item in _selectedItems) {
      item['LABEL_PRINT_DATA'] = labelDataList;
    }

    await transaction(context, "inn/INN0007/poLabelPrint.do", labelDataList, (status, data) {
      if (status == Constant.resSuccessCode) {
        showInfoAlert_pda(context, "라벨 발행 되었습니다.");
      }
    });


  }

  void _onEditQtyChanged(Map<String, dynamic> rowData) {
    double editQty = double.tryParse(rowData['EDIT_QTY']?.toString() ?? '0') ?? 0;
    double balQty  = double.parse(rowData['BAL_QTY']?.toString() ?? '0') ?? 0;

    if (editQty > balQty) {
      showInfoAlert_pda(context, "Balance수량을 넘을 수 없습니다.");
      rowData['EDIT_QTY'] = '';

      setState(() {
        _gridKey++;
      });
    }
  }

  void _onLocationCdTap(Map<String, dynamic> rowData) {
    if (rowData['LOC_CHECK'] == 'Y') {
      showInfoAlert_pda(context, "이미 저장된 LOCATION이 있습니다.");
      return;
    }

    Future<dynamic> result = navigateLocationSelection(context, {
      "PLANT": widget.param['PLANT'],
    });

    result.then((data) {
      if (!CommonUtil.isEmpty(data)) {
        setState(() {
          int index = rowData['INDEX'];
          _orderList[index]['LOCATION_CD'] = data['LOCATION_CD'];
          _gridKey++;
        });
      }
    });
  }

  @override
  void initState() {
    _fnOne = FocusNode();
    _fnTwo = FocusNode();
    _fnThree = FocusNode();
    _selInDt.text = formatDate(_schInDt, [yyyy, '-', mm, '-', dd]);

    _inLabelQty.addListener(() {
      if (_inLabelQty.text.isNotEmpty && _lackLabelQty.text.isNotEmpty) {
        _lackLabelQty.clear();
      }
    });

    _lackLabelQty.addListener(() {
      if (_lackLabelQty.text.isNotEmpty && _inLabelQty.text.isNotEmpty) {
        _inLabelQty.clear();
      }
    });

    Future.delayed(Duration.zero, () async {
      if (mounted) {
        await _sLocSearch();
        await _searchOrderPutInfo(false);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();

    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: pageAppBar(context, "PO입고"),
        body: Container(
            child: GestureDetector(
              onTap: (){
                CommonUtil.hideKeyboard();
              },
              child: Column(
                children: <Widget> [
                  _searchField(),
                  Row(
                    children: <Widget>[
                      // CommonActionBtn("btnSearch"
                      //     , height: 50
                      //     , fontSize: 20
                      //     , onPressed: () {
                      //       _searchOrderPutInfo(true);
                      //     }
                      // )
                    ],
                  ),
                  Expanded(
                    child: KeyedSubtree(
                      key: ValueKey(_gridKey),
                      child: CustomGrid(
                          [['Material','자재명'], ['PO수량','Balance수량'],'입고Bin', '입고수량'],
                          [['SHPR_ITEM_CD','ITEM_DESC'], ['PO_QTY','BAL_QTY'],'LOCATION_CD', 'EDIT_QTY'],
                          _orderList,
                          showCheckboxColumn: true,
                          seletedRecords: _selectedItems,
                          multiSelected: true,
                          onFieldSubmitted: _onEditQtyChanged,
                          onCellTap: (cellInfo) {
                            if (cellInfo['TAP_COL'] == 'LOCATION_CD') {
                              _onLocationCdTap(cellInfo);
                            }
                          },
                          onRefresh : () {
                            _searchOrderPutInfo(true);
                          }
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      CommonActionBtn("btnSave"
                          , height: 50
                          , fontSize: 20
                          , onPressed: () {
                            _saveInOrderInfo();
                          }
                      )
                    ],
                  ),
                ],
              ),
            )
        )
    );
  }

  Widget _searchField() {
    return Container (
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("PO번호"),
              CommonTextField(widget.param['PO_NO'], width: MediaQuery.of(context).size.width * 0.4, enabled : false),
              CommonText("선입고", width: MediaQuery.of(context).size.width * 0.15),
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
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("공급처명"),
              CommonTextField(widget.param['CUST_NM'], enabled : false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("오더번호"),
              CommonTextField(widget.param['AUFNR'], enabled : false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("PLANT", width: MediaQuery.of(context).size.width * 0.2),
              CommonTextField(widget.param['PLANT'], width: MediaQuery.of(context).size.width * 0.2, enabled : false),
              CommonText("sloc", width: MediaQuery.of(context).size.width * 0.2),
              CommonDropdown("Z", _slocVal, _slocList, comboCallback, width : MediaQuery.of(context).size.width * 0.3-12.5, viewType: "CN",),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("생성일자"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CommonDatePicker(
                    selConroller: _selInDt,
                    clearEnabled: false,
                    onEditingComplete: ([result]) {
                      //_searchOrderPutInfo(true);
                    },
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("입고라벨수량", width: MediaQuery.of(context).size.width * 0.23),
              CommonTextField(_inLabelQty, width: MediaQuery.of(context).size.width * 0.15, keyboardType: TextInputType.numberWithOptions(decimal: false), clearEnabled: false),
              CommonText("랙라벨수량", width: MediaQuery.of(context).size.width * 0.2),
              CommonTextField(_lackLabelQty, width: MediaQuery.of(context).size.width * 0.15, keyboardType: TextInputType.numberWithOptions(decimal: false), clearEnabled: false),
              CommonActionBtn(
                "발행",
                width: MediaQuery.of(context).size.width * 0.2,
                onPressed: (){
                  FocusScope.of(context).unfocus();
                  _labelPrint();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}