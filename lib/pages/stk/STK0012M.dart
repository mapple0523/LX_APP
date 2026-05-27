import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/customCard.dart';
import 'package:dtwms_app/models/restfulReq.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class STK0012M extends StatefulWidget {
  @override
  _STK0012M createState() => _STK0012M();
}

class _STK0012M extends State<STK0012M> {
  // DateTime _schReqDt = DateTime.now();
  // final TextEditingController _selReqDt = TextEditingController();

  List<dynamic> _comboItemList = [];
  dynamic _selItemCd;

  TextEditingController _barcodeNo = TextEditingController();

  TextEditingController _selLocVal = TextEditingController();
  String _selLocValCd = "";

  // 버튼 활성화/비활성화
  bool _disableStartBtn = true;
  bool _disableEndBtn = true;

  final FocusNode _fnOne = FocusNode();
  final FocusNode _fnTwo = FocusNode();

  // 조회결과 List
  List<dynamic> _requestList = [];

  // selected가 true 인 항목만 담은 List
  List<dynamic> _selectedList = [];

  @override
  void initState() {
    super.initState();

    // _selReqDt.text = formatDate(_schReqDt, [yyyy, '-', mm, '-', dd]);

    // 화면 렌더링 후 조회(데이터 삽입) - 콤보박스 로드 -> 조회
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _setItemCombo();
      //await _search();
      // FocusScope.of(context).requestFocus(_fnOne);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fnOne.requestFocus();
      });
    });

    _fnOne.addListener(() {
      print(
          '🎄 _fnOne Focus 상태 변경됨: ${_fnOne.hasFocus}, hasPrimaryFocus: ${_fnOne.hasPrimaryFocus}');
    });

    _fnTwo.addListener(() {
      print(
          '📌 _fnTwo hasFocus: ${_fnTwo.hasFocus}, hasPrimaryFocus: ${_fnTwo.hasPrimaryFocus}');
    });

    _selLocVal.addListener(() {
      print('📌 _tcTwo text: ${_selLocVal.text}');
    });

    // 화면 렌더링 후 포커스 줌 - 렌더링 전에 호출하면 생기는 오류 방지
    // WidgetsBinding.instance.addPostFrameCallback(
    //     (_) => );
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 품목명 콤보박스 조회
  Future<void> _setItemCombo() async {
    // final data = await comProdList(context, {"ALL_FLAG": "Y"});
    //
    // setState(() {
    //   _comboItemList = CommonUtil.isEmpty(data) ? [] : data;
    //   _selItemCd = CommonUtil.isEmpty(data) ? null : data[0]['CODE'];
    // });
  }

  // 조회
  Future<void> _search() async {
    Map<String, dynamic> param = {};

    // param['REQ_DT'] = CommonUtil.removeDash(_selReqDt.text);
    param['ITEM_CD'] = _selItemCd;

    List<dynamic> rtnList =
    await transaction(context, "/stk0001/search.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _requestList = [];
      bool confirmed = false;
      confirmed =
      await confirmDialog(context, 'moveNotice', 'alertNoRequestData');
      if (confirmed) {
        Navigator.of(context).pop();
      }
    } else {
      _requestList = rtnList.map((e) {
        return {
          ...e,
          'selected': false,
        };
      }).toList();
    }

    _barcodeNo.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _barcodeNo.text.length,
    );

    setState(() {});
  }

  bool isSameRequest(Map item, Map rowData) {
    return item['BIZ_CD'] == rowData['BIZ_CD'] &&
        item['STOCK_ID'] == rowData['STOCK_ID'] &&
        item['REQUEST_ID'] == rowData['REQUEST_ID'] &&
        item['ITEM_SEQ'] == rowData['ITEM_SEQ'];
  }

  _validateAndUpdateSelection(Map<String, dynamic> rowData) {
    final selected = _requestList.where((e) => e['selected'] == true).toList();
    // final isDataMoving = rowData['REQ_STATUS'] == 'R20';

    bool isMovable = true;
    String alertMsg;

    // final isMovingDataExists = selected
    //     .where((e) => !isSameRequest(e, rowData))
    //     .any((e) => e['REQ_STATUS'] == 'R20');

    final isMovingDataExists = selected.any((e) => e['REQ_STATUS'] == 'R20');

// print(isMovingDataExists);
// print(selected.length);
// print(isDataMoving);

// '이동중' 다건 가능 -> 주석처리(2025.08.11)
    // if (isMovingDataExists || (selected.length > 1 && isDataMoving)) {
    //   setState(() {
    //     final idx = _requestList.indexWhere((e) => isSameRequest(e, rowData));
    //     if (idx != -1) {
    //       _requestList[idx]['selected'] = false;
    //     }
    //   });
    //   alertMsg = 'alertMoving';
    //   isMovable = false;
    // }

    // if(isMovingDataExists) {
    //   print("Aaaa");
    // }

//     if (selected.isNotEmpty) {
//       final toLocation = selected.last['TO_LOCATION'];
//       final isMixedLocation = rowData['TO_LOCATION'] != toLocation;
// // print(rowData['TO_LOCATION']);
// // print(toLocation);
//       if (isMixedLocation) {
//         setState(() {
//           final idx = _requestList.indexWhere((e) => isSameRequest(e, rowData));
//           if (idx != -1) {
//             _requestList[idx]['selected'] = false;
//           }
//         });
//         alertMsg = 'chkToLocaForMove';
//         isMovable = false;
//       }
//     }

    setState(() {
      print("2323323232#");
      _selectedList = _requestList.where((e) => e['selected'] == true).toList();
      _disableStartBtn =
      isMovingDataExists /* || (alertMsg != 'alertMoving' && isDataMoving) */
          ? true
          : _selectedList.isEmpty;
      _disableEndBtn = _selectedList.isEmpty;
    });

    if (!isMovable && alertMsg != null) {
      showInfoAlert_pda(context, alertMsg);
    }
  }

  // 스캔한 카드 선택
  void _selectForMove(String scannedBcd) {
    print("selectedForMove");
    final rowData = _requestList.firstWhere(
          (item) => item['BCD'] == scannedBcd,
      orElse: () => null,
    );

    if (rowData == null) {
      showInfoAlert_pda(context, 'alertNoRequestMove');
      return;
    }

    final alreadySelected = _requestList.any(
            (item) => isSameRequest(item, rowData) && item['selected'] == true);

    if (alreadySelected) {
      showInfoAlert_pda(context, 'alertAlreadySelected');
      return;
    }

    for (var item in _requestList) {
      if (isSameRequest(item, rowData)) {
        item['selected'] = true;
        break;
      }
    }
    _validateAndUpdateSelection(Map<String, dynamic>.from(rowData));
  }

  // [시작]
  _startMove() async {
    final now = DateTime.now().toString();
    final formattedStartTime = CommonUtil.formatDateTime(now);
    final startTimeForServer =
    CommonUtil.formatDateTime(formattedStartTime, DateFormatType.server);

    _selectedList = _requestList.where((e) => e['selected'] == true).toList();

    for (int i = 0; i < _selectedList.length; i++) {
      _selectedList[i]["MOVE_START_DT"] = startTimeForServer;
      _selectedList[i]["PDA_MOVE_START"] = 'Y';
    }

    print(_selectedList);

    await transaction(
        context, "/stk0001/search.do", _selectedList,
            (status, data) async {
          if (status == Constant.resSuccessCode) {
            await transaction(
                context, "/stk0001/search.do", _selectedList,
                    (status, data) {
                  if (status == Constant.resSuccessCode) {
                    Navigator.pop(context, true);
                    showInfoAlert_pda(context, 'altStartMove');
                  }
                });
          } else {
            String confirmMsg = data['message'];
            bool confirmed = await confirmDialog(context, 'moveNotice', confirmMsg);
            if (!confirmed) return;

            await transaction(
                context, "/stk0001/search.do", _selectedList,
                    (status, data) {
                  if (status == Constant.resSuccessCode) {
                    Navigator.pop(context, true);
                    showInfoAlert_pda(context, 'altStartMove');
                  }
                });
          }
        });
  }

  // [완료]
  _endMove() async {
    _selectedList = _requestList.where((e) => e['selected'] == true).toList();

    if (CommonUtil.isNull(_selLocVal.text)) {
      showInfoAlert_pda(context, 'alertChkLoca');
      return;
    }
    // 컨펌으로 변경하라는 요청😢
    // if (!CommonUtil.isNull(_selLocVal.text)) {
    //   if (_selectedList[0]["TO_LOCATION"] != _selLocValCd) {
    //     showInfoAlert_pda(context, 'alertChkMoveLoca');

    //     return;
    //   }
    // }

    // TO_LOCATION이 하나라도 다른 항목이 있는지 검사
    bool hasDifferentToLocation = _selectedList.any(
          (item) => item['TO_LOCATION'] != _selLocValCd,
    );

    if (hasDifferentToLocation) {
      bool confirmed =
      await confirmDialog(context, 'moveNotice', 'alertChkMoveLocaDiff');
      if (!confirmed) return;
    }

    final now = DateTime.now().toString();
    final formattedEndTime = CommonUtil.formatDateTime(now);
    final endTimeForServer =
    CommonUtil.formatDateTime(formattedEndTime, DateFormatType.server);

    for (int i = 0; i < _selectedList.length; i++) {
      _selectedList[i]["MOVE_START_DT"] =
      CommonUtil.isEmpty(_selectedList[i]['MOVE_START_DT'])
          ? endTimeForServer
          : _selectedList[i]['MOVE_START_DT'];
      _selectedList[i]["MOVE_END_DT"] = endTimeForServer;
      _selectedList[i]["PDA_MOVE_END"] = 'Y';
      _selectedList[i]["TO_LOCATION"] = _selLocValCd;
    }

    print(_selectedList);

    await transaction(
        context, "/stk0001/search.do", _selectedList,
            (status, data) async {
          if (status == Constant.resSuccessCode) {
            await transaction(
                context, "/stk0001/search.do", _selectedList,
                    (status, data) {
                  if (status == Constant.resSuccessCode) {
                    Navigator.pop(context, true);
                    showInfoAlert_pda(context, 'altEndMove');
                  }
                });
          } else {
            print("AAaaaddda");
            print(data['message']);
            print("AAaaaa");
            String confirmMsg = data['message'];
            bool confirmed = await confirmDialog(context, 'moveNotice', confirmMsg);
            if (!confirmed) return;

            await transaction(
                context, "/stk0001/search.do", _selectedList,
                    (status, data) {
                  if (status == Constant.resSuccessCode) {
                    Navigator.pop(context, true);
                    showInfoAlert_pda(context, 'altEndMove');
                  }
                });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // ZebraDataWedgeListener.initFunc();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: pageAppBar(context, "pack"),
      body: FooterLayout(
        footer: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _scanLocaField(),
              Row(
                children: [
                  CommonActionBtn(
                    "palletPacking",
                    width: screenWidth * 0.5 - 10,
                    disabledBtn: _disableStartBtn,
                    onPressed: _disableStartBtn
                        ? null
                        : () {
                      _startMove();
                    },
                  ),
                  CommonActionBtn(
                    "palletPacking",
                    width: screenWidth * 0.5 - 10,
                    disabledBtn: _disableEndBtn,
                    onPressed: _disableEndBtn
                        ? null
                        : () {
                      _endMove();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        child: GestureDetector(
          onTap: () {
            CommonUtil.hideKeyboard();
          },
          child: Column(
            children: [
              _requestSearchField(),
              Expanded(
                child: _requestListWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scanLocaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            CommonText("palletPacking",
              width: 78,),
            CommonLocation(
              selLocVal: _selLocVal,
              focusNode: _fnTwo,
              onEditingComplete: (result, code, attr) {
                // _fnTwo.unfocus();
                print("🌹222222");
                _selLocValCd = code;
                CommonUtil.hideKeyboard();
              },
              onTap: () async {
                print("🍒22tab");
                _fnOne.unfocus();
                _barcodeNo.text = '';
                await Future.delayed(Duration(milliseconds: 10));
                _fnTwo.unfocus();
                _fnTwo.requestFocus();
              },
            )
          ],
        ),
      ],
    );
  }

  Widget _requestSearchField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Row(
          //   children: <Widget>[
          //     CommonText("requestDate"),
          //     CommonDatePicker(
          //       selController: _selReqDt,
          //     )
          //   ],
          // ),
          Row(
            children: <Widget>[
              CommonText("palletPacking",
                width: 78,),
              CommonDropdown(
                null,
                _selItemCd,
                _comboItemList,
                    (id, code, name) {
                  setState(() {
                    _selItemCd = code;
                  });
                  _search();
                },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("boxPacking",
                width: 78,),
              CommonScanTextField(
                _barcodeNo,
                focusNode: _fnOne,
                onEditingComplete: ([result]) {
                  CommonUtil.hideKeyboard();
                  print("✨111111");

                  _selectForMove(result);

                  _barcodeNo.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _barcodeNo.text.length,
                  );
                  CommonUtil.hideKeyboard();
                },
                onTap: () async {
                  print("🙏11tab");

                  await _openCamera();

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _fnTwo.unfocus();
                  });
                  if (!CommonUtil.isNull(_selLocVal.text)) {
                    _selLocVal.text = '';
                  }
                  await Future.delayed(Duration(milliseconds: 10));
                  _fnOne.unfocus();
                  _fnOne.requestFocus();
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openCamera() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile image = await picker.pickImage(  // ? 제거
        source: ImageSource.camera,
        imageQuality: 80, // 이미지 품질 (0-100)
      );

      if (image != null) {
        print("촬영된 이미지 경로: ${image.path}");
        // 여기서 촬영된 이미지를 처리하세요
        // 예: 바코드 스캔, 이미지 저장 등

        // 만약 바코드 스캔을 위한 이미지라면:
        // _processBarcodeFromImage(image.path);
      }
    } catch (e) {
      print("카메라 오류: $e");
    }
  }

  Widget _requestListWidget() {
    return customCard(
      _requestList,
      keys: [
        'REQ_DT_FM',
        'MV_STATUS',
        'MATL_NM',
        'BCD',
        'LOT_NO',
        'REQ_QTY',
        'FROM_LOCATION_NM',
        'TO_LOCATION_NM'
      ],
      types: [
        // 'subTitle',
        // 'subTitle',
        'normal',
        'normal'
      ],
      flexes: [2, 3],
      showBtn: true,
      trailingBuilder: (rowData) {
        return Icon(
          rowData['selected'] == true
              ? Icons.check_box_rounded
              : Icons.check_box_outline_blank_rounded,
          color: rowData['selected'] == true ? Colors.green : Colors.grey,
        );
      },
      onTap: (row) {
        setState(() {
          final idx = _requestList.indexWhere((e) => e['BCD'] == row['BCD']);
          if (idx != -1) {
            _requestList[idx]['selected'] =
            !(_requestList[idx]['selected'] == true);
          }

          _validateAndUpdateSelection(row);
        });
      },
    );
  }
}