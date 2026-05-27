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

class CarInfoPage extends StatefulWidget {
  const CarInfoPage({Key key, this.param}) : super(key: key);

  final dynamic param;

  @override
  _CarInfoPage createState() => _CarInfoPage();
}

class _CarInfoPage extends State<CarInfoPage>{
  List<dynamic> _searchList = [];
  List<dynamic> _seletedRecords = [];

  final TextEditingController _selCarNoVal = TextEditingController();
  final TextEditingController _selCustVal = TextEditingController();

  Future<void> _search() async {

    CommonUtil.hideKeyboard();
    FocusScope.of(context).unfocus();

    Map<String, dynamic> searchParam = Map<String, dynamic>.from(widget.param ?? {});

    searchParam['VEHICLE_NO'] = _selCarNoVal.text.trim();
    searchParam['LIFNR_SP'] = _selCustVal.text.trim();

    List<dynamic> rtnList = await transaction(context, "common/searchCarInfoList.do", searchParam);
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

      if (widget.param != null && widget.param['VEHICLE_NO'] != null) {
        _selCarNoVal.text = widget.param['VEHICLE_NO'].toString();
      } else {
        _selCarNoVal.text = "";
      }

      if (widget.param != null && widget.param['LIFNR_SP'] != null) {
        _selCustVal.text = widget.param['LIFNR_SP'].toString();
      } else {
        _selCustVal.text = "";
      }

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
        appBar: pageAppBar(context, "차량조회",false),
        body: FooterLayout(
          footer: CommonActionBtn(
              "btnSelect",
              onPressed: (){
                print("_seletedRecords : ${_seletedRecords}");
                Navigator.pop(context, ConvertUtil.removeColumn(_seletedRecords, ["ROW_COLOR"]));
              }
          ),
          child:
            Container(
                height : CommonUtil.pageMaxHeight(context,(55 * (_searchList.length - 7)).toDouble()),
                child: GestureDetector(
                    onTap: () {
                      CommonUtil.hideKeyboard();
                      FocusScope.of(context).unfocus();
                    },
                    child: Column(
                        children: <Widget>[
                          Row(children: <Widget>[_searchField()]),
                          CommonActionBtn(
                            "btnSearch",
                            width: 337,
                            onPressed: _search,
                          ),
                          Expanded(
                            child: CustomGrid(
                              ['carNo','driver','phoneNo'],
                              ['VEHICLE_NO','DRIVER_NM','TEL'],
                              _searchList,
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

                                setState(() {});
                              },
                            ),
                          ),
                      ]
                    )
                )
            ),
        )
    );
  }

  Widget _searchField() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("차량번호"),
              CommonTextField(
                _selCarNoVal,
                onEditingComplete: ([result]) {
                  _searchList = [];
                  _search();
                },
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("운송사"),
              CommonTextField(
                _selCustVal,
                enabled: false,
              )
            ],
          )
        ],
      ),
    );
  }
}