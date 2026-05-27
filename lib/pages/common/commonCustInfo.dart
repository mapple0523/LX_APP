import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

import 'commAppBar.dart';

class CustInfoPage extends StatefulWidget {
  const CustInfoPage({Key key, this.param}) : super(key: key);

  final dynamic param;

  @override
  _CustInfoPage createState() => _CustInfoPage();
}

class _CustInfoPage extends State<CustInfoPage>{
  List<dynamic> _searchList = [];
  List<dynamic> _seletedRecords = [];

  final TextEditingController _custNm = TextEditingController();

  Future<void> _search() async {

    Map<String, dynamic> searchParam = {};
    searchParam["CUST_NM"] = _custNm.text;

    List<dynamic> rtnList = await transaction(context, "common/supplier.do", searchParam);

    if(CommonUtil.isEmpty(rtnList)) {
      _searchList = [];
    }
    else {
      _searchList = rtnList;
    }
    setState(() {

    });
  }
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _search();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "공급사 조회",false),
        body: FooterLayout(
          footer: CommonActionBtn(
              "btnSelect",
              onPressed: (){
                print("_seletedRecords : ${_seletedRecords}");
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
                      FocusScope.of(context).unfocus();
                    },
                    child: Column(children: <Widget>[
                      Row(children: <Widget>[_searchField()]),
                      CommonActionBtn(
                        "btnSearch",
                        width: 337,
                        onPressed: _search,
                      ),
                      Expanded(
                        child: CustomGrid(
                          ['공급사코드','공급사'],
                          ['CUST_CD','CUST_NM'],
                          _searchList,
                          enableRefresh: false,
                          onTap: (e) {
                            // 이전에 선택된 항목들의 색상을 모두 투명하게 변경
                            for (var item in _searchList) {
                              item["ROW_COLOR"] = Colors.transparent;
                            }

                            // 선택된 목록 초기화
                            _seletedRecords.clear();

                            // 현재 선택된 항목만 추가
                            e["ROW_COLOR"] = Colors.orange;
                            _seletedRecords.add(e);
                            print("**************** ${e}");

                            setState(() {

                            });
                          },
                        ),
                      ),
                    ]))),
          ),
        ));
  }

  Widget _searchField() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("공급사"),
              CommonTextField(
                _custNm,
                onEditingComplete: ([result]) {
                  //_searchList = [];
                  //_search();
                  CommonUtil.hideKeyboard();
                  FocusScope.of(context).unfocus();

                  _searchList.clear();
                  _search();
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}