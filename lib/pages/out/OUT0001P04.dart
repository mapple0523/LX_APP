import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/out/OUT0001P01.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/material.dart';
import 'package:dtwms_app/pages/out/OUT0001P04.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:date_format/date_format.dart';

class OUT0001P04 extends StatefulWidget {
  const OUT0001P04({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0001P04 createState() => _OUT0001P04();
}

class _OUT0001P04 extends State<OUT0001P04>  {

  final TextEditingController _selLotVal    = TextEditingController();
  final TextEditingController _selLocVal    = TextEditingController();

  FocusNode fnOne;
  FocusNode fnTwo;
  FocusNode fnThree;
  List<dynamic> _targetList = [];
  List<dynamic> _seletedRecords = [];

  @override
  void initState() {
    fnOne = FocusNode();
    fnTwo = FocusNode();
    fnThree = FocusNode();

    super.initState();

    _selLocVal.text = widget.param["LOCATION_CD"].toString();
    _selLotVal.text = widget.param["LOT_NO"].toString();

    Future.delayed(Duration.zero, () {
      if(!CommonUtil.isEmpty(widget.param))
        _searchStockInfo();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }


  Future<void> _searchStockInfo() async {
    //FocusScope.of(context).unfocus();

    Map<String, dynamic> param = {};

    param['OUT_NO']  = widget.param['OUT_NO'];
    param['OUT_SEQ']  = widget.param['OUT_SEQ'];
    param['SHPR_ITEM_CD']  = widget.param['SHPR_ITEM_CD'];
    param['LOT_NO'] = widget.param['LOT_NO'];

    List<dynamic> rtnList = await transaction(context, "out/OUT0001/getPdaOutDetailList.do", param);

    if(CommonUtil.isEmpty(rtnList))
      _targetList = [];
    else {
      _targetList = rtnList;

      _selLotVal.text = rtnList[0]["LOT_NO"];
      _selLocVal.text = rtnList[0]["LOCATION_CD"];
    }

    setState(() {});

  }

  Future<void> _deleteOutDetail() async {
    //FocusScope.of(context).unfocus();

    List<dynamic> resultList = [];

    resultList = ConvertUtil.removeColumn(_seletedRecords, ["ROW_COLOR"]);

    resultList.forEach((item) {
      item['LOCATION_CD'] = widget.param['LOCATION_CD'];
      item['PLANT'] = widget.param['PLANT'];
      item['SLOC'] = widget.param['SLOC'];
    });

    print(resultList);

    await transaction(context, "out/OUT0001/deletePicking.do", resultList,(status, data) {
    if(status == Constant.resSuccessCode) {
      Navigator.pop(context, true);
    }
    });

    setState(() {});

  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: pageAppBar(context, "pick"),
        body: Container(
            child: GestureDetector(
              onTap: (){
                CommonUtil.hideKeyboard();
              },
              child: Column(
                children: <Widget> [
                  _searchField(),
                  Row(
                    children: <Widget>[
                      CommonActionBtn("피킹 취소"
                          , fontSize: 20
                          , onPressed: () {
                            _deleteOutDetail();
                          }
                      )
                    ],
                  ),
                  Expanded(
                    child: CustomGrid(['포장번호','재고수량'],
                        ['PACK_ID','STOCK_QTY'], _targetList,
                      onTap: (e) {
                        // ITEM_SEQ를 String으로 변환해서 비교
                        String itemSeq = e['ITEM_SEQ'].toString();

                        // 기존에 선택된 항목인지 확인
                        int existingIndex = _seletedRecords.indexWhere((item) =>
                        item['ITEM_SEQ'].toString() == itemSeq
                        );

                        if (existingIndex == -1) {
                          // 선택되지 않은 항목 - 추가
                          e["ROW_COLOR"] = Colors.orange;
                          _seletedRecords.add(e);
                        } else {
                          // 이미 선택된 항목 - 제거
                          e["ROW_COLOR"] = Colors.transparent;
                          _seletedRecords.removeAt(existingIndex);  // 인덱스로 제거
                        }

                        setState(() {});
                      },
                        showCheckboxColumn: false,
                        onRefresh : () {
                          _searchStockInfo();
                        },
                    ),
                  ),
                ],
              ),

            )
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
              CommonText("lotNo"),
              CommonTextField(_selLotVal,enabled: false)
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("bin"),
              CommonTextField(_selLocVal,enabled: false)
            ],
          ),
        ],
      ),
    );
  }
}