import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonCar.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonMaterial.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/commOutNo.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/out/OUT0005MP05.dart';
import 'package:dtwms_app/pages/out/OUT0005P07.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class OUT0005MP06 extends StatefulWidget {
  const OUT0005MP06({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0005MP06 createState() => _OUT0005MP06();
}

class _OUT0005MP06 extends State<OUT0005MP06> {
  final TextEditingController _selOutNoVal = TextEditingController();
  final TextEditingController _carNo = TextEditingController();
  final TextEditingController _materialVal = TextEditingController();
  final FocusNode fnOne = FocusNode();

  List<dynamic> _searchList = [];
  List<dynamic> _seletedRecords = [];

  Future<void> _search() async {
    Map<String, dynamic> param = {};
    _searchList = [];

    param = {
      "OUT_NO": widget.param["OUT_NO"],
      "DISPATCH_NO" : widget.param["DISPATCH_NO"]
    };

    List<dynamic> rtnList =
    await transaction(context, "out/OUT0005/searchPalletList.do", param);
    if (CommonUtil.isEmpty(rtnList))
      _searchList = [];
    else
      _searchList = rtnList;

    setState(() {
    });
  }

  Future<void> _insertPackId() async {
    List<dynamic> resultList =
    CommonUtil.findRegExpRtnList(_searchList, 'EDIT_QTY', '[1-9]');

    resultList = ConvertUtil.removeColumn(_searchList, ["ROW_COLOR"]);

    String ztksts = widget.param['ZTKSTS'] ?? '1';

    int ztkstNum = int.tryParse(ztksts) ?? 0;

    print("result + $ztksts");

    if(ztkstNum >= 2) {
      bool result = await confirmDialog(context, "확인", "팔레트 정보는 상차확정 시 I/F 합니다.");

      if(result) {
        await transaction(context, "out/OUT0005/insertOutDispatchPalletList.do", resultList, (status, responseData) {
          if (status == Constant.resSuccessCode) {
            showInfoAlert_pda(context, "alertBoxPack");
            _search();
          }
        });
      }
    } else {
      await transaction(context, "out/OUT0005/insertOutDispatchPalletList.do", resultList, (status, responseData) {
        if (status == Constant.resSuccessCode) {
          showInfoAlert_pda(context, "alertBoxPack");
          _search();
        }
      });
    }

    setState(() {});
  }

  Future<void> _updateDispatch() async {
    List<dynamic> resultList =
    CommonUtil.findRegExpRtnList(_seletedRecords, 'EDIT_QTY', '[1-9]');
    resultList = ConvertUtil.removeColumn(_seletedRecords, ["ROW_COLOR"]);

    await transaction(context, "out/OUT0005/updateDispatchList.do", resultList, (status, responseData) {
      if (status == Constant.resSuccessCode) {
        showInfoAlert_pda(context, "alertBoxPack");
        _search();
      }
    });

    setState(() {});
  }

  Future<dynamic> callPallet(BuildContext context, [dynamic param]) async {

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0005MP06(param: widget.param)));

    return result;
  }


  Future<dynamic> callNavi(BuildContext context, [dynamic param]) async {

    Map<String, dynamic> newParam = {
      "OUT_NO": _selOutNoVal.text,
      "VEHICLE_NO": _carNo.text,
      "palletList" : _searchList,
    };

    print("barcodeScanCallback 호출됨 - scanType: $newParam");

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0005P07(param: newParam)));

    if (result != null && result is List && result.isNotEmpty) {
      _addSelectedItems(result);
    }

  }

  void _addSelectedItems(List<dynamic> selectedItems) {
    for (var selectedItem in selectedItems) {
      bool alreadyExists = _searchList.any((item) =>
      item['PALLET_TYPE'] == selectedItem['ITEM_CD']);

      if (!alreadyExists) {
        Map<String, dynamic> newPalletItem = {
          'PALLET_TYPE': selectedItem['ITEM_CD'],
          'ITEM_DESC': selectedItem['ITEM_DESC'],
          'OUT_NO': widget.param["OUT_NO"],
          'VEHICLE_NO': widget.param["VEHICLE_NO"],
          'DISPATCH_NO': widget.param["DISPATCH_NO"],
          'OUT_QTY': 0,
        };

        _searchList.add(newPalletItem);
      }
    }

    setState(() {});

    // 성공 메시지 표시
    // showInfoAlert_pda(context, a);
  }

  @override
  void initState() {
    super.initState();

    print(widget.param);

    if (!CommonUtil.isEmpty(widget.param)) {
      if (!CommonUtil.isEmpty(widget.param["VEHICLE_NO"])) {
        _carNo.text = widget.param["VEHICLE_NO"];
      }

      if (!CommonUtil.isEmpty(widget.param["OUT_NO"])) {
        _selOutNoVal.text = widget.param["OUT_NO"];
      }
    }

    Future.delayed(Duration.zero, () {
      if(!CommonUtil.isEmpty(widget.param))
        _search();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    ZebraDataWedgeListener.initFunc();

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: pageAppBar(context, "PLT",false),
        body: FooterLayout(
          footer: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: <Widget>[
                    CommonActionBtn(
                      "btnSave",
                      onPressed: () => _insertPackId(),
                    ),
                  ],
                ),
              ],
            ),
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
                      Row(
                        children: [
                          CommonActionBtn(
                            "btnDel",
                            width: screenWidth * 0.5 - 10,
                            onPressed: () => callPallet(context),
                          ),
                          CommonActionBtn(
                            "btnAdd",
                            width: screenWidth * 0.5 - 10,
                            onPressed: () => callNavi(context),
                          ),
                        ],
                      ),
                      Expanded(
                        child: CustomGrid(['palletCd','outQty','desc'],
                         ['PALLET_TYPE', "EDIT_QTY",'ITEM_DESC'],
                          _searchList,
                          onTap: (e) {
                            if(CommonUtil.isNull(CommonUtil.findValFromList(_seletedRecords, 'PALLET_TYPE', e['PALLET_TYPE'], 'PALLET_TYPE'))) {
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

  Widget _searchField() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("outNum"),
              CommonTextField(_selOutNoVal,
                enabled: false,
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("carNo"),
              CommonTextField(
                _carNo,
                enabled: false,
              )
            ],
          ),
        ],
      ),
    );
  }
}