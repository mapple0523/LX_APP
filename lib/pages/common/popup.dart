
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
Future<dynamic> showSmallPopup(
  BuildContext context,
  List<dynamic> items,
  List<String> viewer
) async {
  dynamic rtnVal;
  //int index = 0;
  await showDialog<dynamic>(
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
            maxHeight: MediaQuery.of(context).size.height * 0.5, // 최대 높이 제한
            minWidth: MediaQuery.of(context).size.width - 10,
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
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: viewer.map<Widget>((value) {
                      return Text(
                        "${item[value]} / ",
                        style: TextStyle(fontSize: viewer.length>2?12:16),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.visible,
                        maxLines: 3,
                      );
                    }).toList(),
                  )
                ),
              );
            },
          ),
        ),
      );
    },
  ).then((val) {
    rtnVal = val;
  });

  return rtnVal;
}