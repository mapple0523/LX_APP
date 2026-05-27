import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dtwms_app/models/restfulReq.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/pages/stk/STK0002MP01.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'STK0002MP01.dart';

class STK0002M extends StatefulWidget {
  @override
  _STK0002M createState() => _STK0002M();
}

class _STK0002M extends State<STK0002M> {
  List<dynamic> _plantList = [];
  List<dynamic> _slocList = [];
  dynamic _plantValue  = null;
  dynamic _selLocVal = null;

  final TextEditingController _binValue = TextEditingController();
  final TextEditingController _materialValue = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _scanFocus = FocusNode();
  final TextEditingController _scanValue = TextEditingController();

  int maxPage = 1;
  int _page = 1;
  int _limit = 50;
  int _offset = 0;

  bool _hasNextPage = false;
  bool _hasPrevPage = false;

  List<dynamic> _searchHeaderList = [['itemCd','packId'], 'qty',['MEHQ','AO30'], 'bin', 'lotNo'];
  List<dynamic> _searchHeaderList2 = [
    ['SHPR_ITEM_NM','PACK_ID'],
    'STOCK_QTY',
    ['MEHQ','AO30'],
    'LOCATION_NM',
    'LOT_NO',
  ];
  List<dynamic> _searchList = [];

  Future<void> _search(bool flag) async {
    if(flag){
      maxPage = 1;
      _page = 1;
      _offset = 0;
      setState(() {});
    }
    _initLoad();
  }

  void _initLoad() async {
    _offset = _limit * (_page - 1);

    Map<String, dynamic> param = {};
    param['PLANT_VALUE'] = _plantValue;
    param['S_LOC'] = _selLocVal;
    param['BIN_VALUE'] = _binValue.text;
    param['MATERIAL_VALUE'] = _materialValue.text;
    param['LIMIT'] = _limit;
    param['OFFSET'] = _offset;

    dynamic rtnData = await transaction(context, "/stk0001/search.do", param);

    if (CommonUtil.isEmpty(rtnData)) {
      _searchList = [];
      setState(() {
        _hasPrevPage = false;
        _hasNextPage = false;
      });
    } else {
      if (CommonUtil.isEmpty(rtnData["dataList"])) {
        _searchList = [];
        setState(() {
          _hasPrevPage = false;
          _hasNextPage = false;
        });
      } else {
        _searchList = rtnData["dataList"];

        maxPage = rtnData["MAX_OFFSET"] ~/ _limit;
        if (rtnData["MAX_OFFSET"] % _limit != 0) {
          maxPage++;
        }

        if (_offset != 0) {
          setState(() {
            _hasPrevPage = true;
          });
        } else {
          setState(() {
            _hasPrevPage = false;
          });
        }

        if (maxPage > _page) {
          setState(() {
            _hasNextPage = true;
          });
        } else {
          setState(() {
            _hasNextPage = false;
          });
        }
      }
      if (_offset != 0 && _searchList.length < _limit)
        setState(() {
          _hasNextPage = false;
        });
    }
  }

  Future<dynamic> callNavi(BuildContext context, [dynamic param]) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => STK0002MP01(param: param)));

    if (result != null && result) {
      _search(false);
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await _plantSearch();
    });

    super.initState();
  }

  Future<void> comboCallback(String id, dynamic code, dynamic name) async {
    if(id == Constant.LOCATION_TYPE_W) {
      _plantValue = code;

      await _sLocSearch(code);
    }
    else if(id == Constant.LOCATION_TYPE_Z) {
      _selLocVal = code;
    }

    setState(() {});
  }

  Future<void> _plantSearch() async {
    Map<String, dynamic> param = {"ALL_FLAG" : "Y"};
    _plantList = [];

    List<dynamic> rtnList = await transaction(context, "common/getCommonPlantList.do", param);
    if (CommonUtil.isEmpty(rtnList)) {
      _plantList = [];
      _plantValue = null; // 리스트가 비어있으면 null로 설정
    } else {
      _plantList = rtnList;
      // 첫 번째 항목을 기본값으로 설정
      if (_plantList.isNotEmpty) {
        _plantValue = _plantList[0]["CODE"];

        _sLocSearch(_plantValue);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _sLocSearch(String code) async {
    Map<String, dynamic> param = {};
    _slocList = [];

    param = {
      "ALL_FLAG" : "N",
      "PLANT": code,
    };

    List<dynamic> rtnList = await transaction(context, "common/getCommonSlocList.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _slocList = [];
      _selLocVal = null; // 리스트가 비어있으면 null로 설정
    } else {
      _slocList = rtnList;
      // 첫 번째 항목을 기본값으로 설정
      if (_slocList.isNotEmpty) {
        _selLocVal = _slocList[0]["CODE"];
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleCMScan(String scannedValue) async {

    print("CM 타입 스캔 처리 시작: $scannedValue");
    // BIN NO scan
    if (scannedValue.startsWith(Constant.BIN_BARCODE_DELIMIT)) {
      scannedValue = scannedValue.replaceAll(Constant.BIN_BARCODE_DELIMIT, "");
      _binValue.text = scannedValue;
      _materialValue.text = "";
    }
    else{
      _materialValue.text = scannedValue;
      _binValue.text = "";
    }

    setState(() {
      _search(true);
    });

    print("CM 타입 스캔 처리 완료");
  }

  @override
  void dispose() {
    //_scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    var color = 0xff453658;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: pageAppBar(context, "stockMove"),
      body: FooterLayout(
        footer: Row(
          children: [
            Visibility(
              visible: !(_offset == 0 && !_hasNextPage),
              child: CommonActionBtn(
                "btnPrev",
                width: 170,
                disabledBtn: !(this._hasPrevPage),
                onPressed: _offset == 0
                    ? null // _offset 값이 0인 경우 버튼 비활성화
                    : () {
                        setState(() {
                          _searchList = [];
                          _page = (_page - 1).clamp(1, _page); // 1이하 안되게
                          _search(false);
                        });
                        _scrollController.animateTo(
                          0,
                          duration: Duration(milliseconds: 700),
                          curve: Curves.easeInOut,
                        );
                      },
              ),
            ),
            Visibility(
              visible: !(_offset == 0 && !_hasNextPage),
              child: CommonActionBtn(
                "btnNext",
                width: 170,
                disabledBtn: !(this._hasNextPage),
                onPressed: _hasNextPage
                    ? () {
                        setState(() {
                          _searchList = [];
                          _page += 1;
                          _search(false);
                        });
                        _scrollController.animateTo(
                          0,
                          duration: Duration(milliseconds: 700),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
            ),
          ],
        ),
        child: Container(
          child: GestureDetector(
            onTap: () {
              CommonUtil.hideKeyboard();
              _scanFocus.requestFocus();
            },
            child: Column(
              children: <Widget>[
                _searchField(),
                CommonActionBtn(
                  "btnSearch",
                  height: 50,
                  fontSize: 20,
                  onPressed: () {
                    CommonUtil.hideKeyboard();
                    _scanFocus.requestFocus();
                    _searchList = [];
                    _search(true);
                    _scrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 700),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                Expanded(
                  child: CustomGrid(
                      _searchHeaderList, _searchHeaderList2, _searchList,
                      scrollController: _scrollController,
                      onRefresh: () {
                        _search(false);
                      },
                      onTap: ([rowData]) {
                        callNavi(context, rowData).then((data) {});
                     }
                   ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("plant", width: MediaQuery.of(context).size.width * 0.25,),
              CommonDropdown("W", _plantValue, _plantList, comboCallback, width : MediaQuery.of(context).size.width * 0.25-12.5, viewType: "CN",),
              CommonText("sloc", width: MediaQuery.of(context).size.width * 0.25,),
              CommonDropdown("Z", _selLocVal, _slocList, comboCallback, width : MediaQuery.of(context).size.width * 0.25-12.5, viewType: "CN",),

            ],
          ),
          Row(
            children: <Widget>[
              CommonText("bin", width: MediaQuery.of(context).size.width * 0.25,),
              CommonLocation(
                selLocVal: _binValue,
                width: MediaQuery.of(context).size.width * 0.75,
                onEditingComplete: (scannedValue) async {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("materialCd", width: MediaQuery.of(context).size.width * 0.25,),
              CommonTextField(
                _materialValue,
                width: MediaQuery.of(context).size.width * 0.75-15,
                onEditingComplete: (nodeObj) {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                }
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Offstage(
                offstage: true, // false로 바꾸면 다시 보임
                child: CommonScanTextField(
                  _scanValue,
                  focusNode: _scanFocus,
                  autofocus: true,
                  scanType: "CM",
                  onEditingComplete: (scannedValue) async {
                    await _handleCMScan(scannedValue);
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
