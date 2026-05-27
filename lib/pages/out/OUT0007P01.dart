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
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class OUT0007P01 extends StatefulWidget {
  const OUT0007P01({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0007P01 createState() => _OUT0007P01();
}

class _OUT0007P01 extends State<OUT0007P01> {
  final TextEditingController _movingQty = TextEditingController();
  final TextEditingController _selLocVal = TextEditingController();

  final FocusNode fnOne = FocusNode();

  List<dynamic> _searchList = [];

  List<dynamic> _orderList = [{}];

  Future<void> _search() async {
    Map<String, dynamic> param = {};
    _searchList = [];

    param = {
      "OUT_NO": widget.param["OUT_NO"],
    };

    List<dynamic> rtnList = await transaction(context, "out/OUT0007/searchOutDetailList.do", param);
    if (CommonUtil.isEmpty(rtnList))
      _searchList = [];
    else {
      _searchList = rtnList;
      _orderList = rtnList;
    }

    setState(() {
    });
  }

  Future<void> _insertOutConfirm() async {

    await transaction(context, "out/OUT0007/insertOutConfirmList.do", _searchList, (status, responseData) {
      if (status == Constant.resSuccessCode) {
        showInfoAlert_pda(context, "alertBoxPack");
        //_search();
      }
    });


    setState(() {});
  }

  Future<void> _insertOutConfirmCancel() async {

    await transaction(context, "out/OUT0007/insertOutConfirmCancelList.do", _searchList, (status, responseData) {
      if (status == Constant.resSuccessCode) {
        showInfoAlert_pda(context, "alertBoxPack");
        //_search();
      }
    });


    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    print(widget.param);

    Future.delayed(Duration.zero, () {
      if(!CommonUtil.isEmpty(widget.param))
        _search();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: pageAppBar(context, "stockInfoDetail"),
        body: FooterLayout(
            footer: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CommonActionBtn(
                        "btnInstConfirmCancel",
                        width: screenWidth * 0.5 - 10,
                        onPressed: _insertOutConfirmCancel,
                      ),
                      CommonActionBtn(
                        "btnInstConfirm",
                        width: screenWidth * 0.5 - 10,
                        onPressed: _insertOutConfirm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            child: SingleChildScrollView(
                child: GestureDetector(
                    onTap: () {
                      CommonUtil.hideKeyboard();
                    },
                    child: Container(
                      height: CommonUtil.pageMaxHeight(context,-300),
                      child: Column(
                        children: <Widget>[
                          _searchField(_orderList),
                          Expanded(
                            child: CustomGrid(['No', 'itemCd', 'planQty','compQty'],
                              ['NUM_ID','SHPR_ITEM_NM', 'OUT_CONF_QTY','OUT_QTY'],
                              _searchList,
                              onTap: ([rowData]) {
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                )
            )
        )
    );
  }


  Widget _searchField(List<dynamic> list) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("outNum"),
              CommonTextField(list[0]['OUT_NO'], enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("moveKind"),
              CommonTextField(list[0]['OUT_TYPE_NM'], enabled: false),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("plant",),
              CommonTextField(list[0]['PLANT'], width: MediaQuery.of(context).size.width * 0.22-12.5, enabled: false),
              CommonText("sloc",),
              CommonTextField(list[0]['SLOC'], width: MediaQuery.of(context).size.width * 0.22-12.5, enabled: false),
            ],
          ),
        ],
      ),
    );
  }
}