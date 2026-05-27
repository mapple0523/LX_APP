import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonMaterial.dart';
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
import 'package:dtwms_app/pages/out/OUT0007P01.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:dtwms_app/pages/out/OUT0002P03.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'OUT0002P03.dart';

class OUT0007M extends StatefulWidget {
  @override
  _OUT0007M createState() => _OUT0007M();
}

class _OUT0007M extends State<OUT0007M> {
  final TextEditingController _selOutNo = TextEditingController();

  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();
  final FocusNode fnThree = FocusNode();

  List<dynamic> _searchList = [];
  //배송처에 속한 출고번호 List
  List<dynamic> _searchCustOutList = [];

  DateTime _schPickDt = DateTime.now();
  final TextEditingController _selPickDtFrom = TextEditingController();

  @override
  void initState() {
    _selPickDtFrom.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);
    super.initState();
  }

  @override
  void dispose() {
    FocusScope.of(context).unfocus();

    super.dispose();
  }

  Future<void> _searchCarNo() async {
    _searchList = [];
    
    Map<String, dynamic> param = {};

    param['OUT_NO'] = _selOutNo.text;
    param['FROM_DT'] = _selPickDtFrom.text;

    List<dynamic> rtnList =
        await transaction(context, "out/OUT0007/searchOutList.do", param);

    if (CommonUtil.isEmpty(rtnList))
      _searchList = [];
    else
      _searchList = rtnList;

    setState(() {});
  }

  Future<dynamic> callNavi(BuildContext context, [dynamic param]) async {

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0007P01(param: param)));
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "불출확정"),
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
                  _searchCarNo();
                },
              ),
              Expanded(
                child: CustomGrid(['No', 'outNum',['plant','sloc'], 'outStatus'],
                  ['NUM_ID','OUT_NO',['PLANT','SLOC'], 'OUT_STATUS_NM'],
                  _searchList,
                  onTap: ([rowData]) {
                    callNavi(context, rowData).then((data) {});
                  },
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
              CommonText("outPlanDate"),
              CommonDatePicker(
                selConroller: _selPickDtFrom,
                clearEnabled: false,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("outNum"),
              CommonTextField(_selOutNo,
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
