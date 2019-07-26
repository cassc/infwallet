import 'package:flutter/material.dart';
import 'package:openwallet/model/tags.dart';
import 'package:openwallet/view/shared.dart';

class TagWrap extends StatelessWidget {
  final List<String> selected;
  final List<Tag> tagList;
  TagWrap(this.selected, this.tagList);
  @override
  Widget build(BuildContext context) {
    List<Widget> childList = buildChips(context);

    return Container(
      padding: EdgeInsets.all(20),
      alignment: Alignment.topLeft,
      child: Wrap(
          spacing: 6.0, // gap between adjacent chips
          runSpacing: 0.0, // gap between lines
          children: childList),
    );
  }

  List<Widget> buildChips(BuildContext context) {
    List<Widget> list = [];
    selected.forEach((String title) {
      Tag tag = tagByTitle(title, tagList);
      Widget icon = CircleAvatar(
        backgroundColor: tag.color,
        child: Text(
          tag.title.substring(0, 1),
          style: TextStyle(color: Colors.white),
        ),
      );

      list.add(InkWell(
        child: Chip(
          avatar: icon,
          label: Text(tag.title),
        ),
      ));
    });
    return list;
  }
}
