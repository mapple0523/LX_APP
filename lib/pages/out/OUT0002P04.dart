import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class OUT0002P04 extends StatefulWidget {
  const OUT0002P04({Key key, this.param}) : super(key: key);

  final dynamic param;

  @override
  _OUT0002P04 createState() => _OUT0002P04();
}

class _OUT0002P04 extends State<OUT0002P04>{
  List<dynamic> _searchList = [];
  List<dynamic> _seletedRecords = [];

  Future<void> _search() async {
    List<dynamic> rtnList = await transaction(context, "out/OUT0002/searchOutSerialList.do", widget.param);
    if(CommonUtil.isEmpty(rtnList))
      _searchList = [];
    else
      _searchList = rtnList;

    setState(() {

    });
  }
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _search();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _deleteSerials() async {
    _seletedRecords = ConvertUtil.removeColumn(_seletedRecords, ["ROW_COLOR"]);
    Map<String, dynamic> paramMap = {
      "SERIAL_LIST" : _seletedRecords
    };

    if (CommonUtil.isEmpty(_seletedRecords)) {
      showInfoAlert_pda(context, "chkSelectedSerial");
      return;
    }
    await transaction(context, "out/OUT0002/deleteSerialList.do", paramMap,(status, data) {
      if (status == Constant.resSuccessCode) {
        Navigator.pop(context, true);
        showInfoAlert_pda(context, "alertRemoveSerial");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "removeSerial",true),
        body: FooterLayout(
          footer: CommonActionBtn(
            "btnSelect",
            onPressed: (){
              _deleteSerials();
            }
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                height : CommonUtil.pageMaxHeight(context,(55 * (_searchList.length - 7)).toDouble()),
                padding: EdgeInsets.only(left: 5),
                child: GestureDetector(
                    onTap: () {
                      CommonUtil.hideKeyboard();
                    },
                    child: Column(children: <Widget>[
                      Expanded(
                        child: CustomGrid(
                          ['outNo', 'serialNo'],
                          ['IF_OUT_NO', 'SERIAL_NO'],
                          _searchList,
                          enableRefresh: false,
                          onTap: (e) {
                              if(CommonUtil.isNull(CommonUtil.findValFromList(_seletedRecords, 'SERIAL_NO', e['SERIAL_NO'], 'SERIAL_NO'))) {
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
                          onLongPress: (rowData){
                              confirmDialog(context, "전체 선택", "전체선택 하시겠습니까?").then((value) async {
                                if(value){
                                  if(_searchList.length == _seletedRecords.length){
                                    _searchList.forEach((e) {
                                        e["ROW_COLOR"] = Colors.transparent;
                                        _seletedRecords.remove(e);
                                      setState(() {
                                      });
                                    });
                                  }
                                  else {
                                    _searchList.forEach((e) {
                                      if(CommonUtil.isNull(CommonUtil.findValFromList(_seletedRecords, 'SERIAL_NO', e['SERIAL_NO'], 'SERIAL_NO'))) {
                                        e["ROW_COLOR"] = Colors.orange;
                                        _seletedRecords.add(e);
                                      }
                                      setState(() {
                                      });
                                    });
                                  }
                                }
                              });
                          },
                        ),
                      ),
                    ]))),
          ),
        ));
  }
}