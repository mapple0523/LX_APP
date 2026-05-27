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
import 'package:dtwms_app/pages/out/OUT0008P01.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:dtwms_app/pages/out/OUT0002P03.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'OUT0002P03.dart';

class OUT0008M extends StatefulWidget {
  @override
  _OUT0008M createState() => _OUT0008M();
}

class _OUT0008M extends State<OUT0008M> {
  final TextEditingController _outNo = TextEditingController();
  final FocusNode fnOne = FocusNode();
  List<dynamic> _carList = [];
  //배송처에 속한 출고번호 List
  List<dynamic> _searchCustOutList = [];
  DateTime _schPickDt = DateTime.now();
  final TextEditingController _outDtFrom = TextEditingController();
  final TextEditingController _outDtTo = TextEditingController();
  int _gridFocusIdx = 0;

  @override
  void initState() {
    _outDtFrom.text = formatDate(_schPickDt.subtract(Duration(days: 7)), [yyyy, '-', mm, '-', dd]);
    _outDtTo.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _searchOutInfo() async {
    FocusScope.of(context).unfocus();

    _carList = [];

    Map<String, dynamic> param = {};
    param['OUT_NO'] = _outNo.text;
    param['OUT_DATE_FROM'] = _outDtFrom.text;
    param['OUT_DATE_TO'] = _outDtTo.text;

    List<dynamic> rtnList =
        await transaction(context, "out/OUT0008/searchOutList.do", param);

    if (CommonUtil.isEmpty(rtnList))
      _carList = [];
    else
      _carList = rtnList;

    setState(() {});
  }

  Future<dynamic> callInNavi(BuildContext context, [dynamic param]) async {

    param['custList'] = _searchCustOutList;
    _gridFocusIdx = param["INDEX"];
    param['FROM_PLANT'] = param['PLANT'];
    param['FROM_SLOC'] = param['SLOC'];
    param['TO_PLANT'] = param['TO_PLANT'];
    param['TO_SLOC'] = param['TO_SLOC'];

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0008P01(param: param)));

    _searchOutInfo();

  }


  Future<void> _handleData(String scannedValue) async {
    //_packId = scannedValue;

    _gridFocusIdx = 0;
    _outNo.text = scannedValue;
    _searchOutInfo();


    print("스캔 처리 완료");
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "자재불출"),
        body: Container(
            child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
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
                  _searchOutInfo();
                },
              ),
              Expanded(
                child: CustomGrid(
                    [['outPlanDate','outNum'], ['plant','sloc'], ['to PLANT','to S.LOC'],  'outStatus'],
                    [['OUT_CONF_DATE_NM','OUT_NO'],['PLANT','SLOC'], ['TO_PLANT','TO_SLOC'], 'OUT_STATUS_NM'],
                    _carList,
                    focusIndex: _gridFocusIdx,
                    onTap: ([rowData]) {
                      callInNavi(context, rowData).then((data) {});
                      },
                onRefresh: () {
                  _gridFocusIdx = 0;
                  _searchOutInfo();
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
          // Row(
          //   children: <Widget>[
          //     CommonText("outPlanDate"),
          //     CommonDatePicker(
          //       selConroller: _outDtFrom,
          //       clearEnabled: false,
          //       onEditingComplete: ([result]) {
          //         FocusScope.of(context).unfocus();
          //       },
          //     ),
          //   ],
          // ),
          Row(
            children: <Widget>[
              CommonText("outPlanDate", height: 82,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CommonDatePicker(
                    selConroller: _outDtFrom,
                    clearEnabled: false,
                    onEditingComplete: ([result]) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  CommonDatePicker(
                    selConroller: _outDtTo,
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
              CommonText("outNum"),
              CommonScanTextField(
                  _outNo,
                  focusNode: fnOne,
                  scanType: "CM",
                  onEditingComplete: (scannedValue) async {
                    await _handleData(scannedValue);
                  },
              )
            ],
          ),
        ],
      ),
    );
  }
}
