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
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:dtwms_app/pages/out/OUT0002P03.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

import 'OUT0002P03.dart';

class OUT0005P07 extends StatefulWidget {
  const OUT0005P07({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0005P07 createState() => _OUT0005P07();
}

class _OUT0005P07 extends State<OUT0005P07> {
  final TextEditingController _palletCd = TextEditingController();
  final TextEditingController _palletNm = TextEditingController();
  final FocusNode fnOne = FocusNode();

  List<dynamic> _searchList = [];
  //배송처에 속한 출고번호 List
  List<dynamic> _searchCustOutList = [];

  List<dynamic> _seletedRecords = [];

  DateTime _schPickDt = DateTime.now();

  final TextEditingController _selPickDtFrom = TextEditingController();

  @override
  void initState() {
    _selPickDtFrom.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _search();
      }
    });
  }

  @override
  void dispose() {
    fnOne.unfocus();
    super.dispose();
  }

  _search() async {
    Map<String, dynamic> searchParam = Map<String, dynamic>.from(widget.param ?? {});

    searchParam['ITEM_CD'] = _palletCd.text;
    searchParam['ITEM_NM'] = _palletNm.text;

    List<dynamic> rtnList = await transaction(context, "out/OUT0005/searchItemPalletList.do", searchParam);

    if (mounted) {
      if (CommonUtil.isEmpty(rtnList))
        _searchList = [];
      else
        _searchList = rtnList;

      setState(() {});
    }
  }

  Future<dynamic> callNavi(BuildContext context, [dynamic param]) async {

    param['custList'] = _searchCustOutList;

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0005MP03(param: param)));

  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "carDispatch"),
        body: FooterLayout(
            footer: CommonActionBtn(
                "btnSelect",
                onPressed: (){
                  if (_seletedRecords.isNotEmpty) {
                    Navigator.pop(context, _seletedRecords);
                  } else {
                    showInfoAlert_pda(context, "chkSelected");
                  }
                }
            ),
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
                  _search();
                },
              ),
              Expanded(
                child: CustomGrid(
                    ['itemNm', 'itemCd', 'itemDesc'],
                    ['ITEM_CD','ITEM_NM', 'ITEM_DESC'],
                    _searchList,
                    onRefresh: () {
                      _search();
                    },
                  onTap: (e) {
                    if(CommonUtil.isNull(CommonUtil.findValFromList(_seletedRecords, 'ITEM_CD', e['ITEM_CD'], 'ITEM_CD'))) {
                      e["ROW_COLOR"] = Colors.orange;
                      _seletedRecords.add(e);
                    }
                    else{
                      e["ROW_COLOR"] = Colors.transparent;
                      _seletedRecords.remove(e);
                    }
                    setState(() {

                    });
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
              CommonText("palletCd"),
              CommonTextField(_palletCd,
                  onEditingComplete: ([result]) {
                    _searchField();
                  })
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("palletNm"),
              CommonTextField(_palletNm,
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
