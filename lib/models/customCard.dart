import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';

/// 공통 카드 위젯 생성 함수
Widget customCard(
  List<dynamic> dataList, {
  @required List<String> keys,
  List<String> types,
  List<String> labels,
  List<String> aligns,
  List<int> flexes,
  bool isMerge = false,
  bool showBtn = false,
  IconData customIconStyle,
  Function(dynamic row) onTap,
  Function(dynamic row) onDelete,
  Widget Function(Map<String, dynamic> rowData) trailingBuilder,
}) {
  return CustomCardList(
      dataList: dataList,
      keys: keys,
      types: types,
      labels: labels,
      aligns: aligns,
      flexes: flexes,
      isMerge: isMerge,
      showBtn: showBtn,
      customIconStyle: customIconStyle,
      onTap: onTap,
      onDelete: onDelete,
      trailingBuilder: trailingBuilder);
}

TextAlign _parseTextAlign(String align) {
  switch (align.toLowerCase()) {
    case 'center':
      return TextAlign.center;
    case 'right':
      return TextAlign.right;
    case 'start':
      return TextAlign.start;
    case 'end':
      return TextAlign.end;
    case 'justify':
      return TextAlign.justify;
    case 'left':
    default:
      return TextAlign.left;
  }
}

Color _parseColor(String color) {
  switch (color.toUpperCase()) {
    case 'YELLOW':
    case '대기':
      return Colors.yellow;
    case 'GREEN':
    case '진행중':
      return Colors.green;
    case 'BLUE':
    case '완료':
      return Colors.blue;
    default:
      return Colors.grey.shade300;
  }
}

class CustomCardList extends StatelessWidget {
  final List<dynamic> dataList;
  final List<String> keys;
  final List<String> types;
  final List<String> labels;
  final List<String> aligns;
  final List<int> flexes;
  final bool isMerge;
  final bool showBtn;
  final IconData customIconStyle;
  final Function(dynamic row) onTap;
  final void Function(dynamic row) onDelete;
  final Widget Function(Map<String, dynamic> rowData) trailingBuilder;

  CustomCardList({
    @required this.dataList,
    @required this.keys,
    this.types,
    this.labels,
    this.aligns,
    this.flexes,
    this.isMerge = false,
    this.showBtn = false,
    this.customIconStyle,
    this.onTap,
    this.onDelete,
    this.trailingBuilder,
  });

  List<Map<String, dynamic>> _makeContents() {
    List<Map<String, dynamic>> contents = [];
    int labelIndex = 0;
    for (int i = 0; i < keys.length; i++) {
      int flex = (CommonUtil.isEmpty(flexes)) ? 1 : flexes[i % flexes.length];

      String type = (types != null && i < types.length) ? types[i] : 'normal';

      Map<String, dynamic> item = {
        'key': keys[i],
        'type': type,
        'align': (aligns != null && i < aligns.length)
            ? _parseTextAlign(aligns[i])
            : TextAlign.left,
        'flex': flex,
      };

      if (type == 'label' && labels != null && labelIndex < labels.length) {
        item['label'] = labels[labelIndex];
        labelIndex++;
      }

      contents.add(item);
    }
    return contents;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dataList.length,
      itemBuilder: (_, index) {
        return CustomCardItem(
          data: Map<String, dynamic>.from(dataList[index]),
          contents: _makeContents(),
          isMerge: isMerge,
          showBtn: showBtn,
          customIconStyle: customIconStyle,
          onTap: onTap,
          onDelete: onDelete,
          trailingBuilder: trailingBuilder,
        );
      },
    );
  }
}

class CustomCardItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> contents;
  final bool isMerge;
  final bool showBtn;
  final IconData customIconStyle;
  final Function(dynamic row) onTap;
  final Function(dynamic row) onDelete;
  final Widget Function(Map<String, dynamic> rowData) trailingBuilder;

  CustomCardItem(
      {@required this.data,
      @required this.contents,
      this.isMerge = false,
      this.showBtn = false,
      this.customIconStyle,
      this.onTap,
      this.onDelete,
      this.trailingBuilder});

  List<List<Map<String, dynamic>>> _chunkContents(
      List<Map<String, dynamic>> contents) {
    List<List<Map<String, dynamic>>> grouped = [];
    for (int i = 0; i < contents.length; i++) {
      final current = contents[i];

      if (current['key'] == null ||
          (current['type'] != 'label' &&
              current['key'].toString().trim().isEmpty)) continue;

      final bool isBigTitle = current['type'] == 'bigTitle';

      if (isBigTitle) {
        grouped.add([current]);
        continue;
      }

      final bool hasNext = (i + 1 < contents.length);
      final next = hasNext ? contents[i + 1] : null;
      final bool nextIsValid = hasNext &&
          next['type'] != 'bigTitle' &&
          next['key'] != null &&
          next['key'].toString().trim().isNotEmpty;

      if (nextIsValid) {
        grouped.add([current, next]);
        i++;
      } else {
        grouped.add([current]);
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = data['TRACK_STATUS_NM'] == '완료';

    return Card(
      color: isCompleted ? Colors.grey : Colors.white,
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(7),
      ),
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: InkWell(
        onTap: () => onTap?.call(data),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0, right: showBtn ? 5 : 0),
                child: !isMerge
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _chunkContents(contents).map((rowConfigs) {
                          return Row(
                            children: rowConfigs.map((cfg) {
                              int flex = cfg['flex'] ?? 1;
                              return Expanded(
                                flex: flex,
                                child: CardItemFactory.build(data, cfg,
                                    isCompleted: isCompleted),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _chunkContents(contents).map((columnConfigs) {
                          // print(columnConfigs);
                          // int flex = columnConfigs.length;
                          int flex = (!CommonUtil.isEmpty(columnConfigs) &&
                                  columnConfigs[0]['flex'] != null)
                              ? columnConfigs[0]['flex']
                              : 10;
                          // print(flex);
                          return Expanded(
                            flex: flex,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: columnConfigs.map((cfg) {
                                return CardItemFactory.build(data, cfg,
                                    isCompleted: isCompleted);
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      ),
              ),
              if (showBtn)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: trailingBuilder != null
                          ? trailingBuilder(data)
                          : IconButton(
                              // icon: Icon(customIconStyle ?? Icons.delete, color: Colors.red),
                              icon: Icon(customIconStyle ?? Icons.delete,
                                  color: Colors.red),
                              onPressed: () => onDelete?.call(data),
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardItemFactory {
  static Widget build(Map<String, dynamic> data, Map<String, dynamic> config,
      {bool isCompleted = false}) {
    final String key = config['key'];
    final String type = config['type'] ?? 'normal';
    final dynamic value = data[key] ?? '';
    final String label = config['label'] ?? key;
    final TextAlign align = config['align'] ?? TextAlign.left;

    Color bgColor = config['bgColor'] ??
        (type == 'status' && data['TRACK_STATUS_NM'] != null
            ? _parseColor(data['TRACK_STATUS_NM'])
            : Colors.transparent);

    Color textColor = config['textColor'] ??
        (isCompleted || bgColor == Colors.green ? Colors.white : Colors.black);

    TextStyle textStyle = TextStyle(
      fontSize: (type == 'title' || type == 'bigTitle')
          ? 20
          : type == 'status'
              ? 17
              : type == 'subTitle'
                  ? 16
                  : 14,
      fontWeight: (type == 'title' || type == 'status')
          ? FontWeight.bold
          : type == 'subTitle'
              ? FontWeight.w500
              : FontWeight.normal,
      color: textColor,
    );

    Widget content;
    switch (type) {
      case 'bigTitle':
      case 'title':
        content = Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(4)),
          child: Text(value.toString(), style: textStyle, textAlign: align),
        );
        break;
      case 'status':
        content = Container(
          padding: EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(4)),
          child: Text(value.toString() /* CommonUtil.formatValue(value) */,
              style: textStyle, textAlign: align),
        );
        break;
      case 'label':
        content = Row(
          children: [
            // Text('$label : ', style: textStyle),
            Text('$label ', style: textStyle),
            Expanded(
                child:
                    Text(value.toString(), style: textStyle, textAlign: align)),
          ],
        );
        break;
      case 'labelText':
      case 'subTitle':
      case 'normal':
      default:
        String displayValue = CommonUtil.formatValue(value);
        // if (value is num || double.tryParse(value.toString()) != null) {
        //   displayValue = CommonUtil.formatDecimalWithComma(value);
        // } else {
        //   displayValue = value.toString();
        // }
        List<String> ellipsisKeys = ['BCD'];
        bool useMiddleEllipsis = ellipsisKeys.contains(key) ||
            key.contains('BARCODE') ||
            key.contains('BCD');
        String finalValue = useMiddleEllipsis
            ? CommonUtil.middleEllipsis(displayValue)
            : displayValue;
        if (type == 'labelText') {
          finalValue = ': $finalValue';
        }
        content = Container(
          padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          child: Text(
            finalValue,
            style: textStyle,
            textAlign: align,
            // overflow: TextOverflow.ellipsis,
            overflow: TextOverflow.visible,
            softWrap: false,
            maxLines: 1,
          ),
        );
        break;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),

      //디버깅용
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: Colors.grey.shade300,
      //     width: 1,
      //   ),
      //   borderRadius: BorderRadius.circular(4),
      // ),

      child: content,
    );
  }
}
