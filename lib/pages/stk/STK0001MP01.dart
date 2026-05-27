import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class STK0001MP01 extends StatefulWidget {
  const STK0001MP01({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _STK0001MP01 createState() => _STK0001MP01();
}

class _STK0001MP01 extends State<STK0001MP01> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var color = 0xff453658;
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: pageAppBar(context, "stockSearch", true),
        body: FooterLayout(
          child: SingleChildScrollView(
              child: GestureDetector(
              onTap: () {
                CommonUtil.hideKeyboard();
              },
            child: Container(
              height: CommonUtil.pageMaxHeight(context,-300),
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: Column(
                      children: [
                        Row(children: <Widget>[_searchField()]),
                      ],
                    )
                  ),
                ],
              ),
            ),
          )
        ),
      )
    );
  }

  Widget _searchField() {
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
              CommonText("supplierNm"),
              CommonTextField(widget.param['CUST_NM'], enabled: false),
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
              CommonText("unit", width: 78),
              CommonTextField(widget.param['ITEM_UNIT'], width: 90, enabled: false),
              CommonText("grade", width: 78),
              CommonTextField(widget.param['GRADE'], width: 90, enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("bin"),
              CommonTextField(widget.param['LOCATION_CD'], enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("qty"),
              CommonTextField(
                  CommonUtil.nullStrDef(widget.param['STOCK_QTY'].toString()),
                  enabled: false)
            ],
          ),
        ],
      ),
    );
  }
}

//common.selectComCodeInfo
