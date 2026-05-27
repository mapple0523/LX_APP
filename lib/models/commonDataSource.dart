import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class EmployeeDataSource extends DataGridSource {
  final dynamic onTap;

  EmployeeDataSource(List<dynamic> pRowList, List<dynamic> pBindCol, {this.onTap} ) {
    dataGridRows = pRowList.map<DataGridRow>((dataGridRow) => DataGridRow(cells:getGridCellInfo(pBindCol, dataGridRow))).toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
          return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                dataGridCell.value.toString(),
                overflow: TextOverflow.ellipsis,
              ));
        }).toList());
  }

  List<DataGridCell> getGridCellInfo(List<dynamic> pBindCol, dynamic pCellData) {
    List<DataGridCell> cellList = [];

    // ignore: missing_return
    pBindCol.map<DataGridCell>((value) {
      cellList.add(DataGridCell(
        columnName: value,
        value: CommonUtil.findValueFromMap(pCellData, value),
      ));
    }).toList();

    return cellList;
  }
}