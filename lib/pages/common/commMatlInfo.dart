import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
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

class MatlInfoPage extends StatefulWidget {
  const MatlInfoPage({Key key, this.param}) : super(key: key);

  final dynamic param;

  @override
  _MatlInfoPage createState() => _MatlInfoPage();
}

class _MatlInfoPage extends State<MatlInfoPage>{
  List<dynamic> _searchList = [];
  List<dynamic> _searchGroupList = [];
  List<dynamic> _seletedRecords = [];

  final TextEditingController _material = TextEditingController();

  dynamic _materialGrp = null;

  Future<void> _search() async {
    Map<String, dynamic> searchParam = Map<String, dynamic>.from(widget.param ?? {});

    searchParam['ITEM_NM'] = _material.text.trim();
    searchParam['ITEM_GRP'] = _materialGrp;

    List<dynamic> rtnList = await transaction(context, "common/searchItemInfoList.do", searchParam);
    if(CommonUtil.isEmpty(rtnList))
      _searchList = [];
    else
      _searchList = rtnList;

    FocusScope.of(context).requestFocus(FocusNode());
    CommonUtil.hideKeyboard();

    setState(() {});
  }

  Future<void> _searchMatlGroup() async {
    Map<String, dynamic> searchParam = Map<String, dynamic>.from(widget.param ?? {});

    List<dynamic> rtnList = await transaction(context, "common/selectItemGroupList.do", searchParam);

    if (CommonUtil.isEmpty(rtnList)) {
      _searchGroupList = [];
      _materialGrp = null;
    } else {
      _searchGroupList = rtnList;
      if (_searchGroupList.isNotEmpty) {
        _materialGrp = _searchGroupList[0]['CODE'];
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> comboCallback(String id, dynamic code, dynamic name) async {
    if(id == 'W') {
      _materialGrp = code;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.param != null && widget.param['ITEM_NM'] != null) {
        _material.text = widget.param['ITEM_NM'].toString();
      } else {
        _material.text = "";
      }

      _materialGrp = null;

      Future.delayed(Duration.zero, () async {
        if (mounted) {
          await _searchMatlGroup();
          _search();
        }
      });
    });
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
        appBar: pageAppBar(context, "itemSearch", false),
        body: FooterLayout(
          footer: CommonActionBtn(
              "btnSelect",
              onPressed: () {
                Navigator.pop(context,
                    ConvertUtil.removeColumn(_seletedRecords, ["ROW_COLOR"]));
              }
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                height: CommonUtil.pageMaxHeight(
                    context, (55 * (_searchList.length - 7)).toDouble()),
                padding: EdgeInsets.only(left: 5),
                child: GestureDetector(
                    onTap: () {
                      CommonUtil.hideKeyboard();
                    },
                    child: Column(children: <Widget>[
                      _searchField(),
                      CommonActionBtn(
                        "btnSearch",
                        height: 50,
                        width: 337,
                        fontSize: 20,
                        onPressed: () {
                          _search();
                        },
                      ),
                      Expanded(
                        child: CustomGrid(
                          ['itemCd', 'itemDesc'],
                          ['ITEM_NM', 'ITEM_DESC'],
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
                    ]))),
          ),
        ));
  }

  Widget _searchField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("itemCd"),
              CommonTextField(_material,
                  onEditingComplete: ([result]) {
                    _search();
                  })
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("itemGrp"),
              CommonDropdown('W', _materialGrp, _searchGroupList, comboCallback, width: 225),
            ],
          ),
        ],
      ),
    );
  }
}