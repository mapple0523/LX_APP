import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_data_table/refresh/pull_to_refresh/src/indicator/material_indicator.dart';
import 'package:horizontal_data_table/refresh/pull_to_refresh/src/smart_refresher.dart';

// ignore: must_be_immutable
class CommonGrid extends StatelessWidget {
  final List<dynamic> header;
  final List<dynamic> bindCol;
  final List<dynamic> rowData;

  double width;
  RefreshController refreshController;
  final bool showCheckboxColumn;

  //이벤트
  final dynamic onTap;
  final dynamic onLongPress;
  final dynamic onRefresh;

  CommonGrid(this.header, this.bindCol, this.rowData,
    {
      this.width
      , this.showCheckboxColumn = false
      , this.refreshController
      , this.onTap
      , this.onRefresh
      , this.onLongPress
    }
  );

  @override
  Widget build(BuildContext context) {
    this.width = CommonUtil.nullObjectDef(this.width, MediaQuery.of(context).size.width - 10).toDouble();
    this.refreshController = CommonUtil.nullObjectDef(this.refreshController, RefreshController());

    return Container(
        width: this.width,
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: SmartRefresher(
          enablePullDown: true,
          header: MaterialClassicHeader(),
          controller: this.refreshController,
          onRefresh: (){
            this.refreshController.refreshCompleted();
            if(!CommonUtil.isEmpty(this.onRefresh))
                this.onRefresh();
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
                scrollDirection : Axis.horizontal,
                child: DataTable (
                  columnSpacing: 30.0,
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.black54),
                  showCheckboxColumn : this.showCheckboxColumn,
                  columns: this.header.map<DataColumn>((value) {
                    return DataColumn(
                        label: Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,)
                    );
                  }).toList(),
                  rows: getGridRowInfo(this.rowData, this.bindCol, this.onTap, this.onLongPress),
                )
            ),
          ),
        )
    );
  }

  List<DataRow> getGridRowInfo(List<dynamic> pRowList, List<dynamic> pBindCol, dynamic pOnTap, dynamic pOnLongPress) {
    List<DataRow> rowList = [];

    // ignore: missing_return
    pRowList.map<DataRow>((e) {
      rowList.add(DataRow(cells: getGridCellInfo(pBindCol, e, pOnTap, pOnLongPress)));
    }).toList();

    return rowList;
  }

  List<DataCell> getGridCellInfo(List<dynamic> pBindCol, dynamic pCellData, dynamic pOnTap, dynamic pOnLongPress) {
    List<DataCell> cellList = [];

    // ignore: missing_return
    pBindCol.map<DataCell>((value) {
      cellList.add(DataCell(Text(CommonUtil.findValueFromMap(pCellData, value), textAlign: TextAlign.center),
          onTap: () {
            if(!CommonUtil.isEmpty(pOnTap))
              pOnTap(pCellData, CommonUtil.findValueFromMap(pCellData, value));
          },
          onLongPress: () {
            if(!CommonUtil.isEmpty(pOnLongPress))
              pOnLongPress(pCellData);
          }
      ));
    }).toList();

    return cellList;
  }

}