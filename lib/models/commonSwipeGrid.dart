import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_data_table/refresh/pull_to_refresh/src/smart_refresher.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'commonDataSource.dart';

// ignore: must_be_immutable
class CommonSwipeGrid extends StatelessWidget {
  final List<dynamic> header;
  final List<dynamic> bindCol;
  final List<dynamic> rowData;
  final DataGridController _controller = DataGridController();

  double width;
  RefreshController refreshController;
  final bool showCheckboxColumn;

  //이벤트
  final dynamic onTap;
  final dynamic onRefresh;

  CommonSwipeGrid(this.header, this.bindCol, this.rowData,
    {
      this.width
      , this.showCheckboxColumn = false
      , this.refreshController
      , this.onTap
      , this.onRefresh
    }
  );

  @override
  Widget build(BuildContext context) {
    this.width = CommonUtil.nullObjectDef(this.width, MediaQuery.of(context).size.width - 10).toDouble();
    this.refreshController = CommonUtil.nullObjectDef(this.refreshController, RefreshController());
    EmployeeDataSource _employeeDataSource = EmployeeDataSource(this.rowData, this.bindCol);

    _controller.selectedIndex = 0;
    return Container(
        width: this.width,
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: SfDataGrid(
            controller: _controller,
            allowPullToRefresh : true,
            allowSwiping: true,
            swipeMaxOffset: 100.0,
            refreshIndicatorStrokeWidth: 3.0,
            refreshIndicatorDisplacement: 60.0,
            selectionMode: SelectionMode.single,
            source: _employeeDataSource,
            columnWidthMode: ColumnWidthMode.fill,
            columns: this.bindCol.map<GridColumn>((value) {
              return GridTextColumn(
                columnName: value,
                label: Container(
                    padding: EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    color: Colors.black54,
                    child: Text(
                      this.header[this.bindCol.indexOf(value)],
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,
                    )
                )
              );
            }).toList(),
            // ignore: non_constant_identifier_names
            onCellTap: (DataGridCellTapDetails) {
              print(_controller.selectedIndex);
            },
        )
    );
  }


}

