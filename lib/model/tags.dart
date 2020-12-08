import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:infwallet/view/shared.dart';
import 'package:sqflite/sqflite.dart';

import '../db.dart';

class Tag {
  int id;
  String title;
  Color color;
  Tag({this.id = 0, this.title, this.color = Colors.black});

  Tag.fromMap(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    title = map['title'];
    color = hexToColor(map['color']);
  }

  Map<String, dynamic> toMap() {
    log('$title color: $color');
    var map = <String, dynamic>{
      'title': title,
      'color': colorToHex(color),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}

final defaultTagList = [
  Tag(title: '兴趣', color: Colors.red),
  Tag(title: '工资', color: Colors.green),
  Tag(title: '销售', color: Colors.blueAccent),
  Tag(title: '食品', color: Colors.amber),
  Tag(title: '饮料', color: Colors.indigoAccent),
  Tag(title: '朋友', color: Colors.yellowAccent),
  Tag(title: '家庭', color: Colors.indigo[300]),
  Tag(title: '交通', color: Colors.brown),
];



Future<List<Tag>> getTags() async {
  Database db = await DBHelper.getDB();
  List<Map<String, dynamic>> results = await db.query('tag');
  return results.map((result) {
    Tag tag = Tag.fromMap(result);
    log('tagid: ${tag.id} title: ${tag.title}');
    return tag;
  }).toList();
}

Future upsertTagByTitle(Tag tag) async {
  Database db = await DBHelper.getDB();
  Map<String, dynamic> map = tag.toMap();
  map.remove('id');
  int changed =
      await db.update('tag', map, where: 'title=?', whereArgs: [tag.title]);
  if (changed < 1) {
    await db.insert('tag', map);
  }
}

Future upsertTagById(Tag tag) async {
  log('upsertTagById ${tag.id} ${tag.title} ${tag.color}');
  Database db = await DBHelper.getDB();
  Map<String, dynamic> map = tag.toMap();
  map.remove('id');

  if (tag.id > 0) {
    await db.update('tag', map, where: 'id=?', whereArgs: [tag.id]);
  } else {
    await db.insert('tag', map);
  }
}

Future deleteTagByTitle(Tag tag) async {
  Database db = await DBHelper.getDB();
  await db.delete('tag', where: 'title=?', whereArgs: [tag.title]);
}

Future initTags() async {
  var tagList = await getTags();
  if (tagList.isEmpty) {
    for (var tag in defaultTagList) {
      await upsertTagByTitle(tag);
    }
  }
}
