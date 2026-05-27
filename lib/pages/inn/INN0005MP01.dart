import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
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
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class INN0005MP01 extends StatefulWidget {
  const INN0005MP01({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _INN0005MP01 createState() => _INN0005MP01();
}

class _INN0005MP01 extends State<INN0005MP01> {
  final TextEditingController _selOutNoVal = TextEditingController();
  final TextEditingController _selCustCD = TextEditingController();
  final TextEditingController _plantValue = TextEditingController();
  final TextEditingController _selLocVal = TextEditingController();
  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();
  final FocusNode fnThree = FocusNode();
  final FocusNode fnFour = FocusNode();


  DateTime _schPickDt = DateTime.now();
  final TextEditingController _selPickDtFrom = TextEditingController();
  final TextEditingController _selInDtTo = TextEditingController();

  void initStatus() {
    _selPickDtFrom.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);
    _selInDtTo.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);

    super.initState();
  }

  dynamic popUpYn = "N";

  List<dynamic> _searchList = [];
  List<dynamic> _seletedRecords = [];
  List<dynamic> _searchCustOutList = [];

  Future<void> _search() async {
    Map<String, dynamic> param = {};
    _searchList = [];
    _seletedRecords = [];
    if(!CommonUtil.isEmpty(widget.param) && popUpYn == "N"){
      if(CommonUtil.isEmpty(widget.param["_searchCustOutList"])){
        _selOutNoVal.text = widget.param["OUT_NO"];
      }
      else{
        _searchCustOutList = widget.param["_searchCustOutList"];
        _selCustCD.text = widget.param["CUST_CD"];
      }
      popUpYn = "Y";
    }
    if (CommonUtil.isNull(_selOutNoVal.text) && CommonUtil.isNull(_selCustCD.text)) {
      showInfoAlert_pda(context, "chkScanYN");
      setState(() {
        _searchList = [];
      });
      return;
    }
    param = {
      "OUT_NO": _selOutNoVal.text,
      "custList": _searchCustOutList,
      "CUST_CD" : _selCustCD.text,
      "PLANT_VALUE": _plantValue.text,
      "S_LOC": _selLocVal.text,
    };

    List<dynamic> rtnList =
    await transaction(context, "INN0005/searchPack.do", param);
    if (CommonUtil.isEmpty(rtnList))
      _searchList = [];
    else
      _searchList = rtnList;

    setState(() {
    });
  }

  Future<void> _insertPackId() async {
    List<dynamic> resultList =
    CommonUtil.findRegExpRtnList(_seletedRecords, 'EDIT_QTY', '[1-9]');
    resultList = ConvertUtil.removeColumn(_seletedRecords, ["ROW_COLOR"]);
    if (resultList.isEmpty) {
      showInfoAlert_pda(context, "chkSelectedPack");
      return;
    } else {

      await transaction(context, "INN0005/insertBoxpack.do", resultList, (status, data) {
        if (status == Constant.resSuccessCode) {
          showInfoAlert_pda(context, "alertBoxPack");
          _search();
        }
      });
    }
    setState(() {});
  }

  Future<int> _searchOutCnt() async {

    Map<String, dynamic> param = {
      "CUST_CD": _selCustCD.text
    };
    dynamic outCnt = await transaction(context, "INN0005/searchOutCnt.do", param);

    return outCnt;
  }

  Future<dynamic> _movePageSelection(BuildContext context, [dynamic param]) async {
    _searchList = [];
    _searchCustOutList = [];
    dynamic result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OutNoPage(param: param)));
    if(!CommonUtil.isEmpty(result) && result is List) {
      return result;
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if(!CommonUtil.isEmpty(widget.param))
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
        resizeToAvoidBottomInset: true,
        appBar: pageAppBar(context, "shuttleSearch",false),
        body: FooterLayout(
          footer: CommonActionBtn(
            "btnPack",
            onPressed: _insertPackId,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                height : CommonUtil.pageMaxHeight(context,(55 * (_searchList.length - 7)).toDouble()),
                child: GestureDetector(
                    onTap: () {
                      CommonUtil.hideKeyboard();
                    },
                    child: Column(children: <Widget>[
                      Row(children: <Widget>[_searchField()]),
                      Expanded(
                        child: CustomGrid(['lotNo', 'packAvailQty','carNo', 'packQty','workOrderNo',],
                         ['SHPR_ITEM_NM', 'BOX_AVAIL_QTY', "CAR_NO",'EDIT_QTY','WORK_NO'],
                          _searchList,
                          showCheckboxColumn: false,
                          onTap: ([rowData]) {
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
              CommonText("inPlanDt", height: 82,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CommonDatePicker(
                    selConroller: _selPickDtFrom,
                    clearEnabled: false,
                    onEditingComplete: ([result]) {
                      _search();
                    },
                  ),
                  CommonDatePicker(
                    selConroller: _selInDtTo,
                    clearEnabled: false,
                    onEditingComplete: ([result]) {
                      _search();
                    },
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("inNo"),
              CommonScanTextField(
                _selOutNoVal,
                focusNode: fnTwo,
                scanType: "OT",
                onEditingComplete: ([result]) {
                  _searchCustOutList = [];
                  _search();
                },
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("carNo"),
              CommonScanTextField(
                _selOutNoVal,
                focusNode: fnTwo,
                scanType: "OT",
                onEditingComplete: ([result]) {
                  _searchCustOutList = [];
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