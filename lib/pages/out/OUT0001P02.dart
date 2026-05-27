import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/textMaker.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/pages/out/OUT0001P01.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';

class OUT0001P02 extends StatefulWidget {
  const OUT0001P02({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0001P02 createState() => _OUT0001P02();
}

class _OUT0001P02 extends State<OUT0001P02> {

  List<dynamic> _targetList = [];
  dynamic _schParam;

  @override
  void initState() {
    _targetList = widget.param['LIST'];
    _schParam = widget.param['SCH_PARAM'];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<dynamic> savePage(BuildContext context, [dynamic param]) async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OUT0001P01(param: param)));

    if(!CommonUtil.isEmpty(result) && result == true) {
    }
  }

  _checkPickStatus() async {
    List<dynamic> rtnList = await transaction(context, "out/OUT0001/getPdaPickInfo.do", _schParam);

    if(CommonUtil.isEmpty(rtnList))
      _targetList = [];
    else
      _targetList = rtnList;

    setState(() {});

    var cnt = 0;
    _targetList.forEach((el) {
      if(el['PICK_STATUS'] == 'C') cnt++;
    });

    if(_targetList.length == cnt) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: pageAppBar(context, "피킹"),
        body: Container(
          child: Column(
            children: <Widget> [
              //조회 조건.
              Expanded(
                child: CustomGrid(['피킹번호',['화주', '품목'],['지시수량', '피킹수량'], '상태'],
                    ['PICK_ID', ['SHPR_NM', 'SHPR_ITEM_NM'], ['PICK_INST_QTY', 'PICK_QTY'], 'PICK_STATUS_NM'], _targetList,
                    onTap : ([rowData]) {
                      if(rowData['PICK_STATUS'] != 'C') {
                        savePage(context, rowData).then((data)  {
                          _checkPickStatus();
                        });
                      }
                    },
                    onRefresh : () {
                      _checkPickStatus();
                    }
                ),
              ),
            ],
          ),

        )
    );
  }
}