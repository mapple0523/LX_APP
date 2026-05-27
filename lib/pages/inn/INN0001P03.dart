
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/restfulReq.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/common/shprItem.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'INN0001P02.dart';


class INN0001P03 extends StatefulWidget {
  const INN0001P03({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _INN0001P03 createState() => _INN0001P03();
}

class _INN0001P03 extends State<INN0001P03>  {
  final TextEditingController _barcode  = TextEditingController();
  final FocusNode _fnOne                = FocusNode();
  List<dynamic> _itemList              = [];

  @override
  void initState() {
    super.initState();

    //비동기로 flutter secure storage 정보를 불러오는 작업.
    WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_fnOne);
        _searchOrderItemInfo();
      }
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _searchOrderItemInfo() async {
    List<dynamic> rtnList = await transaction(context, "inn/INN0001/getInOrderItemInfo.do", widget.param);

    if(CommonUtil.isEmpty(rtnList))
      _itemList = [];
    else
      _itemList = rtnList;

    _barcode.selection = TextSelection(baseOffset: 0,extentOffset: _barcode.text.length,);

    setState(() {});
  }

  _callBarcodeScanInfo() async {
    bool emptyFlag = true;
    bool duplFlag = false;
    dynamic duplData = {};
    dynamic chkData = {};

    //품목 바코드 유효성 검사.
    Map<String, dynamic> schParam = ConvertUtil.copyObject(widget.param);
    schParam['ITEM_BARCODE'] = _barcode.text;
    if (!CommonUtil.isNull(_barcode.text)){
      checkItemBarcode(context, schParam).then((value) {
        if (!CommonUtil.isEmpty(value)) {
          schParam['SHPR_ITEM_CD'] = value['SHPR_ITEM_CD'];
          _itemList.map((e) {
            if (e.containsKey('SHPR_ITEM_CD') &&
                e['SHPR_ITEM_CD'] == value['SHPR_ITEM_CD'] &&
                e['SCAN_YN'] == 'N') {
              emptyFlag = false;
              chkData = ConvertUtil.copyObject(e);
            } else if (e.containsKey('SHPR_ITEM_CD') &&
                e['SHPR_ITEM_CD'] == value['SHPR_ITEM_CD'] &&
                e['SCAN_YN'] == 'Y') {
              emptyFlag = false;
              duplFlag = true;
              duplData = ConvertUtil.copyObject(e);
            }
          }).toString();

          if (duplFlag) {
            confirmDialog(context, "품목 추가", "동일 품목이 존재합니다. 추가하시겠습니까?").then((
                value) async {
              if (value == true) {
                duplData['IN_QTY'] = 0;
                duplData['PROD_DATE'] = "";
                duplData['EXPIRE_DATE'] = "";
                duplData['UPDATE_TYPE'] = "I";
                await _callNavi(duplData);
              }
            });
          }

          if (emptyFlag) {
            confirmDialog(context, "품목 추가", "입고 대상 품목이 아닙니다. 추가하시겠습니까?").then((
                value) async {
              if (value == true) {
                dynamic result = await Navigator.push(context,
                    MaterialPageRoute(fullscreenDialog: true,
                        builder: (context) =>
                            ShprItem(param: ConvertUtil.copyObject(schParam))));

                if (!CommonUtil.isEmpty(result)) {
                  result['UPDATE_TYPE'] = "I";
                  await _callNavi(result);
                }
              }
            });
          }

          if (duplFlag == false && emptyFlag == false) {
            _callNavi(chkData);
          }
        }
      });
    }
    else
      showInfoAlert(context, "바코드를 입력하세요");
  }

  Future<void> _callNavi([dynamic param]) async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => INN0001P02(param: ConvertUtil.copyObject(param))));
    if(result != null && result) {
      _searchOrderItemInfo();
    }

    _barcode.selection = TextSelection(baseOffset: 0,extentOffset: _barcode.text.length,);
  }

  _deleteItemInfo(dynamic data) async {
    await transaction(context, "inn/INN0001/deleteItemInfo.do", data, (status, data) {
      if(status == Constant.resSuccessCode) {
        showInfoAlert(context, "삭제 되었습니다.");
        _searchOrderItemInfo();
      }
    });
  }

  _saveInOrderInfo() async {
    String msg = "입고 처리 하시겠습니까?";
    bool scanFlag = false;

    _itemList.map((e) {
      if(e['SCAN_YN'] == "N") {
        scanFlag = true;
      }
    }).toList();

    if(scanFlag) {
      msg = "미처리 된 품목이 존재합니다. 입고 처리 하시겠습니까?";
    }

    confirmDialog(context, "입고", msg).then((value) async {
      if(value) {
        await transaction(context, "inn/INN0001/saveInOrderInfo.do", widget.param, (status, data) {
          if(status == Constant.resSuccessCode) {
            Navigator.pop(context, true);
            showInfoAlert(context, "입고 처리 되었습니다.");
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
          resizeToAvoidBottomInset : true,
          appBar: pageAppBar(context, "입고진행", false),
          body: FooterLayout(
            footer: CommonActionBtn("입고 마감",
              onPressed: () {
              _saveInOrderInfo();
            }),
          child :SingleChildScrollView(
            child: GestureDetector(
            onTap: (){
            CommonUtil.hideKeyboard();
            },
            child: Container(
                height: CommonUtil.pageMaxHeight(context),
              child: Column(
              children: <Widget> [
                _orderInfoContents(),
                _itemContents(),
              ],
            )),
          )
          )
          )
      );
  }

  Widget _orderInfoContents() {
    return Container (
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("입고번호"),
              CommonTextField(widget.param['IN_NO'],
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("입고(확정)일자"),
              CommonTextField(CommonUtil.getDateDashStr(widget.param['IN_CONF_DATE']),
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("화주"),
              CommonTextField(widget.param['SHPR_NM'],
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("입고유형"),
              CommonTextField(widget.param['IN_TYPE_NM'],
                  enabled : false
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("품목바코드"),
              CommonScanTextField(_barcode,
                    focusNode : _fnOne
                    , scanType: "CM"
                    , onEditingComplete : (nodeObj) {
                      _callBarcodeScanInfo();
                    }
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _itemContents() {
    return Expanded(
      child: CustomGrid([['스캔여부', '품목'], ['제조일자', '유통기한'], ['예정수량', '입고수량'],'품목바코드'], [['SCAN_YN', 'SHPR_ITEM_NM'], ['PROD_DATE', 'EXPIRE_DATE'],['IN_CONF_QTY','IN_QTY'],'ITEM_BARCODE'], _itemList,
          onTap : ([rowData, colVal]) async {
              if(CommonUtil.findValueFromMap(rowData, 'SCAN_YN') == "Y") {
                _callNavi(rowData);
              } else {
                showInfoAlert(context, "품목 바코드를 스캔하세요.");
              }
            },
            onRefresh : () {
              _searchOrderItemInfo();
            },
            onLongPress: ([rowData]) {
              confirmDialog(context, "삭제", "[품목 : " +  rowData['SHPR_ITEM_NM'] + "] 삭제하시겠습니까?").then((value) {
                if(value) {
                  _deleteItemInfo(rowData);
                }
              });
            },
      ),
    );
  }
}