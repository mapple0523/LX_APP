import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/commOutNo.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/out/OUT0002P04.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:dtwms_app/pages/out/OUT0002P03.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'OUT0002P03.dart';

class OUT0002P02 extends StatefulWidget {
  @override
  _OUT0002P02 createState() => _OUT0002P02();
}

class _OUT0002P02 extends State<OUT0002P02> {
  final TextEditingController _selOutNoVal = TextEditingController();
  final TextEditingController _selCustCD = TextEditingController();
  final TextEditingController _plantValue = TextEditingController();
  final TextEditingController _sLoc = TextEditingController();
  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();
  final FocusNode fnThree = FocusNode();
  final FocusNode fnFour = FocusNode();

  List<dynamic> _orderList = [];
  //배송처에 속한 출고번호 List
  List<dynamic> _searchCustOutList = [];

  @override
  void initState() {

    super.initState();
  }

  @override
  void dispose() {
    fnOne.unfocus();
    fnTwo.unfocus();
    fnThree.unfocus();
    fnFour.unfocus();
    super.dispose();
  }

  _searchOutOrderInfo() async {
    _orderList = [];

    if(CommonUtil.isNull(_selOutNoVal.text) && CommonUtil.isNull((_selCustCD.text))) {
      showInfoAlert_pda(context, "chkScanYN");
      setState(() {
        _orderList = [];
      });
      return;
    }

    Map<String, dynamic> param = {};
    param['PLANT_VALUE'] = _plantValue.text;
    param['S_LOC'] = _sLoc.text;
    param['OUT_NO'] = _selOutNoVal.text;
    param['CUST_CD'] = _selCustCD.text;
    param['custList'] = _searchCustOutList;

    List<dynamic> rtnList =
    await transaction(context, "out/OUT0002/getOutList.do", param);

    if (CommonUtil.isEmpty(rtnList))
      _orderList = [];
    else
      _orderList = rtnList;

    setState(() {});
  }

  Future<dynamic> callNavi(BuildContext context, [dynamic param]) async {
    param['custList'] = _searchCustOutList;
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0002P04(param: param)));

    if (result != null && result) {
      _searchOutOrderInfo();
    }
  }

  Future<int> _searchOutCnt() async {

    Map<String, dynamic> param = {
      "CUST_CD": _selCustCD.text
    };
    dynamic outCnt = await transaction(context, "stk0006/searchOutCnt.do", param);

    return outCnt;
  }

  Future<dynamic> _movePageSelection(BuildContext context, [dynamic param]) async {
    _orderList = [];
    _searchCustOutList = [];
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OutNoPage(param: param)));
    if(!CommonUtil.isEmpty(result) && result is List) {
      return result;
    }
  }


  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "removeSerial"),
        body: Container(
            child: GestureDetector(
              onTap: () {
                CommonUtil.hideKeyboard();
              },
              child: Column(
                children: <Widget>[
                  _searchField(),
                  CommonActionBtn(
                    "btnSearch",
                    height: 50,
                    fontSize: 20,
                    onPressed: () {
                      _searchCustOutList = [];
                      Map<String, dynamic> paramMap = {
                        "CUST_CD": _selCustCD.text
                      };
                      if(CommonUtil.isNull(_selOutNoVal.text) && CommonUtil.isNull((_selCustCD.text))) {
                        showInfoAlert_pda(context, "chkScanYN");
                        setState(() {
                          _orderList = [];
                        });
                        return;
                      }
                      if(CommonUtil.isNull(_selOutNoVal.text.trim())) {
                        _searchOutCnt().then((value) {
                          if (value > 0) {
                            _movePageSelection(context, paramMap).then((data) {
                              if(!CommonUtil.isEmpty(data)){
                                _searchCustOutList = data;
                                _searchOutOrderInfo();
                              }
                            });
                          }
                        });
                      }
                      else{
                        _searchOutOrderInfo();
                      }
                      fnOne.unfocus();
                      fnTwo.unfocus();
                      fnThree.unfocus();
                      fnFour.unfocus();
                    },
                  ),
                  Expanded(
                    child: CustomGrid(
                        ['item', 'outQty', 'scanQty'],
                        ['SHPR_ITEM_CD', 'OUT_CONF_QTY', 'SERIAL_COUNT'],
                        _orderList, onTap: ([rowData]) {
                      callNavi(context, rowData).then((data) {});
                    }, onRefresh: () {
                      _searchOutOrderInfo();
                    }),
                  ),
                  /*CommonActionBtn("Box 패킹", onPressed: () {_movePage();},),
              CommonActionBtn("Pallet 패킹", onPressed: () {_movePage();},),*/
                ],
              ),
            )));
  }

  Widget _searchField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText(
                "plant",
                width: 78,
              ),
              CommonTextField(
                _plantValue,
                focusNode: fnOne,
                width: 90,
                onEditingComplete: (nodeObj) {
                  fnOne.unfocus();
                  FocusScope.of(context).requestFocus(fnTwo);
                },
              ),
              CommonText(
                "sloc",
                width: 78,
              ),
              CommonTextField(_sLoc, focusNode: fnTwo, width: 90,
                  onEditingComplete: (nodeObj) {
                    fnTwo.unfocus();
                    FocusScope.of(context).requestFocus(fnThree);
                  }),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("outNo"),
              CommonScanTextField(
                _selOutNoVal,
                focusNode: fnThree,
                scanType: "OT",
                onEditingComplete: ([result]) {
                  _searchCustOutList = [];
                  _searchOutOrderInfo();
                  FocusScope.of(context).requestFocus(fnFour);
                },
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("deliveryLocation"),
              CommonScanTextField(_selCustCD,
                  focusNode: fnFour,
                  scanType: "PI",
                  onEditingComplete: ([result]) {
                    _searchCustOutList = [];
                    Map<String, dynamic> paramMap = {
                      "CUST_CD": _selCustCD.text
                    };
                    _searchOutCnt().then((value){
                      if(value > 0){
                        _movePageSelection(context,paramMap).then((data){
                          if(!CommonUtil.isEmpty(data)){
                            _searchCustOutList = data;
                            _searchOutOrderInfo();
                          }
                        });
                      }
                    });
                    fnFour.unfocus();
                  })
            ],
          ),
        ],
      ),
    );
  }
}
