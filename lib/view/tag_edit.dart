import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/material_picker.dart';
import 'package:openwallet/model/tags.dart';

import 'shared.dart';

class TagEditPage extends StatefulWidget {
  final Tag tag;

  TagEditPage(this.tag);

  @override
  _TagEditState createState() => _TagEditState();
}

class _TagEditState extends State<TagEditPage> {
  Tag tag;
  bool isEdit = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      tag = widget.tag;
      isEdit = tag.id > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(isEdit ? '编辑标签' : '新建标签'),
        actions: _actionBtnList(),
      ),
      body: _buildTagEdit(),
      drawer: genSideDrawer(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: _saveAndReturn,
      ),
    );
  }

  Widget _buildTagEdit() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.colorize),
            dense: true,
            title: RaisedButton(
              elevation: 3.0,
              onPressed: () {
                _showColorPicker();
              },
              child: const Text('修改颜色'),
              color: tag.color,
              textColor: Colors.white,
            ),
          ),
          ListTile(
            leading: Icon(Icons.text_fields),
            dense: true,
            title: TextFormField(
              initialValue: tag.title,
              validator: (val) =>
                  (val == null || val.isEmpty) ? '请输入标签名' : null,
              decoration: InputDecoration(
                isDense: true,
                labelText: '标签名',
              ),
              onSaved: (val) {
                setState(() {
                  tag.title = val;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void changeColor(Color color) {
    setState(() => tag.color = color);
    Navigator.of(context).pop();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Change tag color'),
            content: SingleChildScrollView(
              child: MaterialPicker(
                pickerColor: tag.color,
                onColorChanged: changeColor,
                enableLabel: true, // only on portrait mode
              ),
            ),
          ),
    );
  }

  List<Widget> _actionBtnList() {
    List<Widget> actions = [];
    if (isEdit) {
      actions.add(IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => showDeleteTagDialog(context, _deleteTag),
      ));
    }
    return actions;
  }

  void _saveAndReturn() async {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      await upsertTagById(tag);
      Navigator.pop(context);
    }
  }

  void _deleteTag() async {
    await deleteTagByTitle(tag);
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
