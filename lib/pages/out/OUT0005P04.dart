import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/commOutNo.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/out/OUT0005MP02.dart';
import 'package:dtwms_app/pages/out/OUT0005MP03.dart';
import 'package:dtwms_app/pages/out/OUT0005MP05.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:dtwms_app/pages/out/OUT0002P03.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'OUT0002P03.dart';

class OUT0005P04 extends StatefulWidget {
  @override
  _OUT0005P04 createState() => _OUT0005P04();
}

class _OUT0005P04 extends State<OUT0005P04> {
  final TextEditingController _carNo = TextEditingController();
  final FocusNode fnOne = FocusNode();

  List<dynamic> _carList = [];
  //배송처에 속한 출고번호 List
  List<dynamic> _searchCustOutList = [];

  DateTime _schPickFrom = DateTime(
      DateTime.now().subtract(Duration(days:7)).year,
      DateTime.now().subtract(Duration(days:7)).month,
      DateTime.now().subtract(Duration(days:7)).day
  );
  DateTime _schPickDt = DateTime.now();

  final TextEditingController _selPickDtFrom = TextEditingController();
  final TextEditingController _selPickDtTo = TextEditingController();

  int _gridFocusIdx = 0;

  @override
  void initState() {
    _selPickDtFrom.text = formatDate(_schPickFrom, [yyyy, '-', mm, '-', dd]);
    _selPickDtTo.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);

    super.initState();
  }

  @override
  void dispose() {
    fnOne.unfocus();
    super.dispose();
  }

  _searchCarNo() async {
    _carList = [];
    
    Map<String, dynamic> param = {};
    param['CNTR_NO'] = _carNo.text;
    param['PLAN_DATE_FROM'] = CommonUtil.removeDash(_selPickDtFrom.text);
    param['PLAN_DATE_TO'] = CommonUtil.removeDash(_selPickDtTo.text);

    List<dynamic> rtnList =
        await transaction(context, "out/OUT0005/searchContainerList.do", param);

    if (CommonUtil.isEmpty(rtnList))
      _carList = [];
    else
      _carList = rtnList;

    setState(() {});
  }

  Future<dynamic> callNavi(BuildContext context, [dynamic param]) async {
    print("[callNavi]********** selected rowdata : \n${param}");
    param['custList'] = _searchCustOutList;
    _gridFocusIdx = param["INDEX"];
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0005MP05(param: param)));

    _searchCarNo();


  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "container"),
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
                  _gridFocusIdx = 0;
                  _searchCarNo();
                },
              ),
              Expanded(
                child: CustomGrid(
                  ['컨테이너 유형', 'container', 'carryingQty'],
                  ['CONTP','CNTR_NO', 'CARRYING_QTY'],
                  _carList,
                  focusIndex: _gridFocusIdx,
                  onTap: ([rowData]) {
                    callNavi(context, rowData).then((data) {});
                  },
                  onRefresh: () {
                    _searchCarNo();
                  }
                ),
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
              CommonText("outPlanDate", height: 95),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CommonDatePicker(
                    selConroller: _selPickDtFrom,
                    clearEnabled: false,
                    onEditingComplete: ([result]) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  CommonDatePicker(
                    selConroller: _selPickDtTo,
                    clearEnabled: false,
                    onEditingComplete: ([result]) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("containerNo"),
              CommonTextField(_carNo,
                  focusNode: fnOne,
                  onEditingComplete: ([result]) {
                  _searchField();
              })
            ],
          ),
        ],
      ),
    );
  }
}
