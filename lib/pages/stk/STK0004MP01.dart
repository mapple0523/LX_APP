import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/common/commWidget.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';


class STK0004MP01 extends StatefulWidget {

  @override
  _STK0004MP01 createState() => _STK0004MP01();
}

class _STK0004MP01 extends State<STK0004MP01>  {

  DateTime _schInDt = DateTime(
      DateTime.now().subtract(Duration(days:7)).year,
      DateTime.now().subtract(Duration(days:7)).month,
      DateTime.now().subtract(Duration(days:7)).day
      );
  final TextEditingController _selInDt    = TextEditingController();
  DateTime _schOutDt = DateTime.now();
  final TextEditingController _selOutDt    = TextEditingController();



  List<dynamic> _searchHeaderList = ['반출일시','팔렛트 ID',['반출처','팔렛트 유형']];
  List<dynamic> _searchHeaderList2 =  ['OUT_DATE_VIEW','PALLET_ID', ['COMP_NM','PALLET_TYPE_NM']];
  List<dynamic> _searchList = [];

  _search() async {

    Map<String, dynamic> paramMap = {
      "FROM_DT": CommonUtil.removeDash(_selInDt.text),
      "TO_DT": CommonUtil.removeDash(_selOutDt.text),
    };

    _searchList = await transaction(context, "/stk0004/searchPalletOutInfo.do", paramMap);

    if(CommonUtil.isEmpty(_searchList)) {
      showInfoAlert(context, "해당 반출일자 기간내에 반출팔렛트가 없습니다.");
      _searchList = [];
    }

    setState(() {});
  }

  @override
  void initState() {

    super.initState();
    _selInDt.text = formatDate(_schInDt, [yyyy, '-', mm, '-', dd]);
    _selOutDt.text = formatDate(_schOutDt, [yyyy, '-', mm, '-', dd]);

    //비동기로 flutter secure storage 정보를 불러오는 작업.
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _search().then((data) =>  setState(() {}))
    );
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
        resizeToAvoidBottomInset : false,
        appBar: pageAppBar(context, "반출내역"),
        body: Container(
          child: Column(
            children: <Widget> [
              _searchField(),
              Expanded(child: CustomGrid(_searchHeaderList,_searchHeaderList2, _searchList,
                  onRefresh : () {
                    _search();
                  }
                ),
              ),
            ],
          ),
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
              CommonText("반출일자(FROM)"),
              CommonTextField(_selInDt,
                  enabled : false,
                  width : 190),
              IconButton(padding:EdgeInsets.only(left: 5), constraints: BoxConstraints(), icon: Icon(Icons.calendar_today), onPressed: (){
                Future<DateTime> selectedDate = commonDatePicker(context, _schInDt);
                selectedDate.then((dateTime) {
                  setState(() {
                    _selInDt.text = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                    _search();
                  });
                });

              }),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("반출일자(TO)"),
              CommonTextField(_selOutDt,
                  enabled : false,
                  width : 190),
              IconButton(padding:EdgeInsets.only(left: 5), constraints: BoxConstraints(), icon: Icon(Icons.calendar_today), onPressed: (){
                Future<DateTime> selectedDate = commonDatePicker(context, _schOutDt);
                selectedDate.then((dateTime) {
                  setState(() {
                    _selOutDt.text = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                    _search();
                  });
                });
              }),
            ],
          ),
        ],
      ),
    );
  }
}
