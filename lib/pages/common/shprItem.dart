
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';

import 'message.dart';

class ShprItem extends StatefulWidget {

  ShprItem({Key key, this.param}) : super(key: key);

  final dynamic param;

  TextEditingController _barcode;
  FocusNode _fnOne;

  @override
  _ShprItem createState() => _ShprItem();
}

class _ShprItem extends State<ShprItem>  {

  List<dynamic> _itemList               = [];
  List<dynamic> _seletedRecords         = [];

  @override
  void initState() {
    ZebraDataWedgeListener.initFunc();

    widget._barcode = TextEditingController();
    widget._fnOne = FocusNode();
    widget._barcode.text = widget.param['ITEM_BARCODE'];
    widget._fnOne.requestFocus();

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchOrderItemInfo();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _searchOrderItemInfo() async {
    widget.param['SCAN_BARCODE'] = widget._barcode.text;
    _itemList = await transaction(context, "inn/INN0001/getBarcodeItemInfo.do", widget.param);

    setState(() {});

    if(!CommonUtil.isEmpty(_itemList) && _itemList.length == 1) {
      Navigator.pop(context, _itemList[0]);
    }
  }

  _callBarcodeScanInfo() async {
    _searchOrderItemInfo();
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: pageAppBar(context, "품목 선택", null),
        body: Container(
          child: Column(
            children: <Widget> [
              Row(
                children: <Widget>[
                  CommonText("화주"),
                  CommonTextField(widget.param['SHPR_NM'], enabled: false,)
                ],
              ),
              Row(
                children: <Widget>[
                  CommonText("품목바코드"),
                  CommonScanTextField(widget._barcode
                      , focusNode : widget._fnOne
                      , scanType: "PD"
                      , onEditingComplete : (nodeObj) {
                        _callBarcodeScanInfo();
                      }
                  )
                ],
              ),
              Expanded(
                  child: CustomGrid( [['품목군', '품목'],['품목코드', '유형'], ['단위', '규격']], [['ITEM_NM', 'SHPR_ITEM_NM'],['SHPR_ITEM_CD','ITEM_ATTR_NM'], ['ITEM_UNIT', 'ITEM_STD']], _itemList
                    ,showCheckboxColumn : true
                    ,seletedRecords: _seletedRecords
                    ,multiSelected: false
                    ,onTap: ([rowData]) {
                      Navigator.pop(context, rowData);
                    },
                  )
              ),
              CommonActionBtn("선택", onPressed: () {
                  if(CommonUtil.isEmpty(_seletedRecords) || _seletedRecords.length == 0) {
                    showInfoAlert(context, "품목을 선택하세요.");
                  } else {
                    Navigator.pop(context, _seletedRecords[0]);
                  }
              },)
            ],
          ),
        )
    );
  }
}