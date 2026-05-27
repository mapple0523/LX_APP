import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/pages/sys/Language_constants.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizontal_data_table/refresh/pull_to_refresh/src/indicator/material_indicator.dart';
import 'package:horizontal_data_table/refresh/pull_to_refresh/src/smart_refresher.dart';

// ignore: must_be_immutable
class CustomGrid extends StatefulWidget {
  @override
  _CustomGrid createState() => _CustomGrid();

  // final customGridKey  = GlobalKey<_CustomGrid>();

  final List<dynamic> header;
  final List<dynamic> bindCol;
  final List<dynamic> rowData;
  final List<dynamic> colSize;
  final List<dynamic> sortCol;

  //double width;
  //double height;
  RefreshController refreshController;
  final bool showCheckboxColumn;
  final bool multiSelected;
  List<dynamic> seletedRecords;

  //이벤트
  final dynamic onTap;
  final dynamic onLongPress;
  final dynamic onRefresh;
  final dynamic onSelectChanged;
  double colWidth = 0;
  int focusIndex = 0;

  final bool showEditIcon;
  final bool showSort;

  Color borderColor;
  final ValueChanged<Map<String, dynamic>> onFieldSubmitted;
  final ValueChanged<Map<String, dynamic>> onCellTap;

  final bool enableRefresh;
  ScrollController scrollController;
  List<GlobalKey> rowKeys = [];
  dynamic _sortVal = null;

  CustomGrid(this.header, this.bindCol, this.rowData,
      {
        //this.width,
        //this.height,
        this.showCheckboxColumn = false,
        this.refreshController,
        this.onTap,
        this.onRefresh,
        this.onLongPress,
        this.onSelectChanged,
        this.multiSelected = true,
        this.seletedRecords = const [],
        this.colSize = const [],
        this.showEditIcon = false,
        this.onFieldSubmitted,
        this.onCellTap,
        this.borderColor = Colors.orange,
        this.enableRefresh = true,
        this.scrollController,
        this.focusIndex = 0,
        this.showSort = false,
        this.sortCol = const [],
      });
}

class _CustomGrid extends State<CustomGrid> {
  @override
  void initState() {
    widget.rowKeys = List.generate(widget.rowData.length, (_) => GlobalKey());
    // 그리드의 모든 rowdata에 index 부여
    for(int i=0; i< widget.rowData.length; i++){
      widget.rowData[i]["INDEX"] = i;
    }
    super.initState();
  }

  @override
  void dispose() {
    widget.refreshController.dispose();
    widget.scrollController.dispose();

    super.dispose();
  }

  _onSeletedRow(bool selected, dynamic document) {
    setState(() {
      if (widget.multiSelected) {
        if (selected) {
          widget.seletedRecords.add(document);
        } else {
          widget.seletedRecords.remove(document);
        }
      } else {
        widget.seletedRecords.clear();
        if (selected) {
          widget.seletedRecords.add(document);
        }
      }
    });
  }

  List<DataRow> _getRows() {
    List<DataRow> rowList = [];

    // ignore: missing_return
    widget.rowData.map((e) {
      rowList.add(DataRow(
          cells: _getCells(e),
          color: e.containsKey("ROW_COLOR")
              ? MaterialStateColor.resolveWith((states) => e["ROW_COLOR"])
              : null,
          selected: widget.seletedRecords.contains(e),
          onSelectChanged: (onSelectChanged) {
            if (CommonUtil.isEmpty(widget.onSelectChanged)) {
              _onSeletedRow(onSelectChanged, e);
            } else {
              widget.onSelectChanged(onSelectChanged, e);
            }
          }));
    }).toList();

    return rowList;
  }

  List<DataCell> _getCells(dynamic pCellData) {
    TextEditingController controller = TextEditingController();

    List<DataCell> cellList = [];
    int cellIndex = 0;
    int rowIndex = pCellData["INDEX"];
    // ignore: missing_return
    widget.bindCol.map((e) {
      List<dynamic> cells = [];

      if (e is List) {
        cells = e;
      } else {
        cells.add(e);
      }

      controller.selection =
          TextSelection(baseOffset: 0, extentOffset: controller.text.length);

      if (cells.contains('EDIT_QTY')) {
        cellList.add(DataCell(
          Container(
            margin: EdgeInsets.symmetric(vertical: 7.0),
            child: GestureDetector(
              child: TextFormField(
                // key: widget.customGridKey,
                /*controller: TextEditingController(
                    text: pCellData['EDIT_QTY'].toString()
                ),*/
                initialValue: CommonUtil.findDoubleValueFromMap(pCellData, 'EDIT_QTY'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                ],
                cursorColor: Colors.white,
                textAlign: TextAlign.left,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 15.0,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.borderColor = Colors.white,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                ),
                onChanged: (editQty) {
                  setState(() {
                    pCellData['EDIT_QTY'] = editQty.toString();
                    if (widget.onFieldSubmitted != null) {
                      widget.onFieldSubmitted(pCellData);
                    }
                  });
                },
              ),
            ),
          ),
        ));
      } else {
        if(cellIndex == 0){

          cellList.add(DataCell(
              Container(
                key: widget.rowKeys[rowIndex],
                constraints: BoxConstraints(
                  // minWidth: widget.colWidth == 0 ? 20 : widget.colWidth,
                  // maxWidth: widget.colWidth == 0 ? 250 : widget.colWidth,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cells.map<Widget>((value) {
                      return Text(
                        CommonUtil.findValueFromMap(pCellData, value),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.visible,
                        maxLines: 2,
                      );
                    }).toList(),
                  ),
                ),
              ), onTap: () {
            if (!CommonUtil.isEmpty(widget.onTap)) widget.onTap(pCellData);

            if (widget.onCellTap != null) {
              widget.onCellTap({
                ...pCellData,
                'TAP_COL': cells.first,
              });
            }
          }, onLongPress: () {
            if (!CommonUtil.isEmpty(widget.onLongPress))
              widget.onLongPress(pCellData);
          }));
        }else{
          cellList.add(DataCell(
              Container(
                constraints: BoxConstraints(
                  // minWidth: widget.colWidth == 0 ? 20 : widget.colWidth,
                  // maxWidth: widget.colWidth == 0 ? 250 : widget.colWidth,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cells.map<Widget>((value) {
                      return Text(
                        CommonUtil.findValueFromMap(pCellData, value),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.visible,
                        maxLines: 2,
                      );
                    }).toList(),
                  ),
                ),
              ), onTap: () {
            if (!CommonUtil.isEmpty(widget.onTap)) widget.onTap(pCellData);

            if (widget.onCellTap != null) {
              widget.onCellTap({
                ...pCellData,
                'TAP_COL': cells.first,
              });
            }
          }, onLongPress: () {
            if (!CommonUtil.isEmpty(widget.onLongPress))
              widget.onLongPress(pCellData);
          }));
        }
      }

      cellIndex++;
    }).toList();

    return cellList;
  }

  Future<void> comboCallback(String id, String code, String name) async {
    widget._sortVal = code;


    if(code == "PACK_ID"){
      widget.rowData.sort((a, b) {
        int aNum = int.tryParse(a['PACK_ID'].toString().split('-').last) ?? 0;
        int bNum = int.tryParse(b['PACK_ID'].toString().split('-').last) ?? 0;
        return aNum.compareTo(bNum);
      });
    }
    else{
      widget.rowData.sort((a, b) => a[code].compareTo(b[code]));
    }

    for (int i = 0; i < widget.rowData.length; i++) {
      widget.rowData[i]['NUM'] = i + 1;
    }

    setState(() {});
  }

  List<DataColumn> _getColumns() {
    List<DataColumn> rtnList = [];

    widget.header.map((e) {
      List<dynamic> columns = [];

      if (e is List) {
        columns = e;
      } else {
        columns.add(e);
      }

      rtnList.add(DataColumn(
          label: Container(
              width: widget.colWidth == 0 ? (widget.rowData.length == 0 ? 110 : 60) : widget.colWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: columns.map<Widget>((value) {
                    return Text(
                      getTranslated(context, value),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.clip,
                    );
                  }).toList(),
                ),
              ))));
    }).toList();

    return rtnList;
  }

  @override
  Widget build(BuildContext context) {
    widget.rowKeys.clear();
    widget.rowKeys = List.generate(widget.rowData.length, (_) => GlobalKey());
    // 그리드의 모든 rowdata에 index 부여
    for(int i=0; i< widget.rowData.length; i++){
      widget.rowData[i]["INDEX"] = i;
    }

    //widget.width = CommonUtil.nullObjectDef(widget.width, MediaQuery.of(context).size.width - 10).toDouble();

    //widget.height = CommonUtil.nullObjectDef(widget.height, MediaQuery.of(context).size.height - 320).toDouble();

    widget.refreshController = CommonUtil.nullObjectDef(widget.refreshController, RefreshController());

    widget.scrollController = CommonUtil.nullObjectDef(widget.scrollController, ScrollController());

    if (widget.header.length == 3) {
      widget.colWidth = ((MediaQuery.of(context).size.width - 62) / 3).toDouble();
    } else if (widget.header.length == 2) {
      widget.colWidth = ((MediaQuery.of(context).size.width - 62) / 2).toDouble();
    } else if (widget.header.length == 1) {
      widget.colWidth = (MediaQuery.of(context).size.width - 60);
    }

    // build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(widget.rowData.length > 0 && widget.focusIndex >= 0){
        final keyContext = widget.rowKeys[widget.focusIndex].currentContext;

        Scrollable.ensureVisible(
          keyContext,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: 0.5, // 화면 중앙
        );
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return widget.enableRefresh
          ? Column(
          children: [
            Visibility(
                visible: widget.showSort,
                child: Row(
                  children: [
                    Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width * 0.6 - 5,
                      height: 30,
                      padding: EdgeInsets.only(right: 15, bottom: 5),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text("정 렬",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    CommonDropdown("SORT",
                      widget._sortVal,
                      widget.sortCol,
                      comboCallback,
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 30,
                    ),
                  ],
                )
            ),
            Container(
                width: constraints.maxWidth,
                height: widget.showSort?constraints.maxHeight-30 : constraints.maxHeight,
                padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
                child:
                SmartRefresher(
                  enablePullDown: true,
                  header: MaterialClassicHeader(),
                  controller: widget.refreshController,
                  onRefresh: () {
                    widget.refreshController.refreshCompleted();
                    if (!CommonUtil.isEmpty(widget.onRefresh)) widget
                        .onRefresh();
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: widget.scrollController,
                        child: DataTable(
                          headingRowHeight: 54,
                          dataRowHeight: 64,
                          columnSpacing: 13.0,
                          headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Color.fromRGBO(117, 117, 117, 1),
                          ),
                          showCheckboxColumn: widget.showCheckboxColumn,
                          showBottomBorder: true,
                          columns: _getColumns(),
                          rows: _getRows(),
                        )
                    ),
                  ),
                )
            )
          ]
      )
          : Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
          child: Column(
              children: [
                Visibility(
                  visible: widget.showSort,
                  child: CommonDropdown("SORT",
                    widget._sortVal,
                    widget.sortCol,
                    comboCallback,
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 45,
                    viewType: "CN",
                  ),
                ),
                DataTable(
                  headingRowHeight: 54,
                  dataRowHeight: 64,
                  columnSpacing: 13.0,
                  headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Color.fromRGBO(117, 117, 117, 1),
                  ),
                  showCheckboxColumn: widget.showCheckboxColumn,
                  showBottomBorder: true,
                  columns: _getColumns(),
                  rows: _getRows(),
                ),
              ]
          )
      );
      }
    );
  }
}
