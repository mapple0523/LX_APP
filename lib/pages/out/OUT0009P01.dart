import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonCar.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonLocation.dart';
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

class OUT0009P01 extends StatefulWidget {
  const OUT0009P01({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0009P01 createState() => _OUT0009P01();
}

class _OUT0009P01 extends State<OUT0009P01> {
  final TextEditingController _movingQty = TextEditingController();
  final TextEditingController _rmkValue = TextEditingController();
  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();

  List<dynamic> _rmkList = [{}];
  List<dynamic> _orderList = [{}];

  Future<void> _rmkSearch() async {
    Map<String, dynamic> param = {};

    List<dynamic> rtnList =
    await transaction(context, "out/OUT0009/searchRmkList.do", param);

    _rmkList = rtnList;
    _rmkValue.text = _rmkList[0]['CODE'];

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _insertPackId() async {
    Map<String, dynamic> sourceData = widget.param;

    double stockQty = double.tryParse(sourceData['STOCK_QTY']?.toString() ?? '0') ?? 0;
    double moveQty = double.tryParse(_movingQty.text) ?? 0;

    if (moveQty > stockQty) {
      showInfoAlert_pda(context, "이동수량이 재고수량을 초과할 수 없습니다");
      return;
    }

    if(CommonUtil.isNull(_movingQty.text)) {
      showInfoAlert_pda(context, "이동수량을 입력해주십시오");
      return;
    }

    Map<String, dynamic> resultData = Map<String, dynamic>.from(sourceData);
    resultData['OUT_CONF_QTY'] = _movingQty.text;
    resultData['RMK'] = _rmkValue.text;
    resultData['rmk'] = _rmkValue.text;
    resultData['fromPlant'] = widget.param['PLANT'];
    resultData['fromSloc'] = widget.param['SLOC'];

    print("반환할 데이터: $resultData");

    Navigator.pop(context, resultData);

    setState(() {});
  }

  Future<dynamic> showSmallPopup({BuildContext context, List<dynamic> items}) {
    return showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
              minWidth: 200,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final item = items[i];
                return InkWell(
                  onTap: () {
                    Navigator.pop(context, item);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                    alignment: Alignment.center,
                    child: Text(
                      item['NAME'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    print(widget.param);

    Future.delayed(Duration.zero, () async {
      if (mounted) {
        _rmkSearch();
      }
    });

    setState(() {
      _orderList = [widget.param ?? {}];
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
        resizeToAvoidBottomInset: true,
        appBar: pageAppBar(context, "stockInfoDetail"),
        body: FooterLayout(
            footer: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CommonActionBtn(
                        "선출고",
                        onPressed: () async {
                          _insertPackId();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ✅ Container 고정 높이 제거, SingleChildScrollView 유지
            child: SingleChildScrollView(
                child: GestureDetector(
                  onTap: () {
                    CommonUtil.hideKeyboard();
                  },
                  child: _itemPutContents(_orderList), // ✅ Column 제거, 바로 호출
                )
            )
        )
    );
  }

  Widget _itemPutContents(List<dynamic> list) {

    String itemDesc = list[0]['ITEM_DESC'] ?? '';
    String trimmedItemDesc = '';
    if(!CommonUtil.isNull(itemDesc)){
      trimmedItemDesc = itemDesc.length > 20 ? itemDesc.substring(0, 20) + '...' : itemDesc;
    }

    // ✅ Expanded 제거 → Column으로 변경
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            CommonText("storageNm"),
            CommonTextField(list[0]['LOCATION_CD'] ?? '', enabled: false),
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("inDt"),
            CommonTextField(list[0]['IN_DATE'] ?? '', enabled: false),
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("itemNm"),
            CommonTextField(list[0]['SHPR_ITEM_CD'] ?? '', enabled: false),
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("lotNo"),
            CommonTextField(list[0]['LOT_NO'] ?? '', enabled: false),
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("bin"),
            CommonTextField(list[0]['LOCATION_CD'] ?? '', enabled: false),
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("qty"),
            CommonTextField(list[0]['STOCK_QTY'] ?? '', enabled: false),
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("unit"),
            CommonTextField(list[0]['ITEM_UNIT'] ?? '', enabled: false),
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("fromPlant", width: MediaQuery.of(context).size.width * 0.2),
            CommonTextField(list[0]['PLANT'] ?? '', width: MediaQuery.of(context).size.width * 0.3-12.5, enabled: false),
            CommonText("fromSloc", width: MediaQuery.of(context).size.width * 0.2),
            CommonTextField(list[0]['SLOC'] ?? '', width: MediaQuery.of(context).size.width * 0.3-12.5, enabled: false),
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("moveQty"),
            CommonTextField(
              _movingQty,
              enabled: true,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            )
          ],
        ),
        Row(
          children: <Widget>[
            CommonText("비고"),
            GestureDetector(
              onTap: () async {
                final result = await showSmallPopup(
                  context: context,
                  items: _rmkList,
                );
                if (result != null) {
                  setState(() {
                    _rmkValue.text = result['NAME'];
                  });
                }
              },
              child: CommonTextField(
                _rmkValue,
                enabled: false,
              ),
            )
          ],
        ),
      ],
    );
  }
}