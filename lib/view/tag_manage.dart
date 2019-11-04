import 'package:flutter/material.dart';
import 'package:openwallet/model/tags.dart';
import 'package:openwallet/view/tag_edit.dart';
import 'shared.dart';

class TagManagePage extends StatefulWidget {
  @override
  TagManageState createState() => TagManageState();
}

class TagManageState extends State<TagManagePage> {
  List<Tag> _tagList = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: quitApp,
      child: Scaffold(
        appBar: genAppBar(title: 'Tags'),
        body: _buildTagList(),
        drawer: genSideDrawer(context),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TagEditPage(Tag()),
                ));
            _initData();
          },
        ),
      ),
    );
  }

  Widget _buildTagList() {
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
    _tagList.forEach((Tag tag) {
      Widget icon = CircleAvatar(
        backgroundColor: tag.color,
        child: Text(
          tag.title.substring(0, 1),
          style: TextStyle(
            color: tag.color.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white,
          ),
        ),
      );

      list.add(InkWell(
        onTap: () {
          // Application.router.navigateTo(context, "${value.targetRouter}",
          //     transition: TransitionType.inFromRight);
        },
        child: FlatButton(
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => TagEditPage(tag)));
            _initData();
          },
          child: Chip(
            avatar: icon,
            label: Text(tag.title),
          ),
        ),
      ));
    });
    return list;
  }

  void _initData() async {
    List<Tag> tags = await getTags();
    setState(() {
      _tagList = tags;
    });
  }
}
