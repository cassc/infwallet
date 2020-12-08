import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:infwallet/model/tags.dart';
import 'package:infwallet/utils.dart';
import 'package:infwallet/view/tag_edit.dart';

class TagSelectPage extends StatefulWidget {
  final List<String> selected;
  TagSelectPage(this.selected);

  @override
  TagSelectState createState() => TagSelectState();
}

class TagSelectState extends State<TagSelectPage> {
  List<String> selected = [];
  List<Tag> _tagList = [];
  @override
  void initState() {
    super.initState();
    setState(() {
      selected = widget.selected;
    });

    _initData();
  }

  @override
  Widget build(BuildContext context) {
    var childList = buildChips();

    return Scaffold(
      appBar: new AppBar(
        title: Text(FlutterI18n.translate(context, 'select_tag')),
        actions: [
          new IconButton(
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TagEditPage(Tag()),
                  ));
              _initData();
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(DEFAULT_EDGE),
        child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 2.0, // gap between adjacent chips
            runSpacing: 0.0, // gap between lines
            children: childList),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  List<Widget> buildChips() {
    List<Widget> list = [];
    _tagList.forEach((tag) {
      bool checked = isChecked(tag);
      Widget icon = checked ? checkedIcon(tag) : uncheckedIcon(tag);

      list.add(InkWell(
        onTap: () => _toggleChecked(tag),
        onLongPress: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TagEditPage(tag),
              ));
          _initData();
        },
        child: Chip(
          backgroundColor: tag.color,
          avatar: icon,
          label: Text(
            tag.title,
            style: TextStyle(
              color: tag.color.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
            ),
          ),
        ),
      ));
    });
    return list;
  }

  void _initData() async {
    var tagList = await getTags();
    setState(() {
      _tagList = tagList;
    });
  }

  bool isChecked(Tag tag) => selected.contains(tag.title);

  Widget checkedIcon(tag) => CircleAvatar(
        backgroundColor: Colors.redAccent,
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      );

  Widget uncheckedIcon(tag) => CircleAvatar(
        child: Text(
          tag.title.substring(0, 1),
          style: TextStyle(color: Colors.white),
        ),
      );

  void _toggleChecked(Tag tag) {
    setState(() {
      if (!selected.remove(tag.title)) {
        selected.add(tag.title);
      }
    });
  }
}
