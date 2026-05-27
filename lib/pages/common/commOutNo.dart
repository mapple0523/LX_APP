import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

import 'commAppBar.dart';

class OutNoPage extends StatefulWidget {
  const OutNoPage({Key key, this.param}) : super(key: key);

  final dynamic param;

  @override
  _OutNoPage createState() => _OutNoPage();
}

class _OutNoPage extends State<OutNoPage>{
  List<dynamic> _searchList = [];
  List<dynamic> _seletedRecords = [];

  Future<void> _search() async {
    List<dynamic> rtnList = await transaction(context, "common/searchOutNoList.do", widget.param);
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

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "outNoPick",false),
        body: FooterLayout(
          footer: CommonActionBtn(
            "btnSelect",
            onPressed: (){
              Navigator.pop(context, ConvertUtil.removeColumn(_seletedRecords, ["ROW_COLOR"]));
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
                          ['outNo', 'deliveryLocation'],
                          ['IF_OUT_NO', 'CUST_NM'],
                          _searchList,
                          enableRefresh: false,
                          onTap: (e) {
                              if(CommonUtil.isNull(CommonUtil.findValFromList(_seletedRecords, 'OUT_NO', e['OUT_NO'], 'OUT_NO'))) {
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
                    ]))),
          ),
        ));
  }
}