import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/BookType/Epub.dart';
import 'package:flutter_application_1/BookType/Group.dart';
import 'package:flutter_application_1/BookType/Image.dart';
import 'package:flutter_application_1/BookType/PageAbs.dart';
import 'package:flutter_application_1/BookType/Txt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' show json;
import 'package:flutter/material.dart' as m;

class BookConfig {
  static late SharedPreferences preferences;
  static Future<bool> getInstance() async {
    preferences = await SharedPreferences.getInstance();
    return true;
  }

  static Color GlobalBolor = Colors.brown;

  static List<dynamic> BookGroup = [];

  static List<BookPage> ParseBook(List<dynamic> list) {
    var bp = <BookPage>[];
    for (var item in list) {
      switch (item["type"]) {
        case "book":
          if (item["Type"] == Book.TXT.name) {
            bp.add(BTXT(
                type: item["book_type"] == "path" ? TXT.path : TXT.http,
                src: item["source"] ?? "",
                name: item["name"] ?? "",
                chapterpage: item["chapterpage"] ?? 0,
                backimage_txt: item["backimage"] ?? "",
                chapter_index: item["chapter_index"] ?? 0));
          } else if (item["Type"] == Book.EPUB.name) {
            /*test1(item["source"]).then((value) {
              //var aaa = Image.memory(value!.getBytes());
              bp.add(BTXT(
                type: item["book_type"] == "path" ? TXT.path : TXT.http,
                src: item["source"] ?? "",
                name: item["name"] ?? "",
                chapterpage: item["chapterpage"] ?? 0,
                backimage_txt: item["backimage"] ?? "",
                chapter_index: item["chapter_index"] ?? 0,
                backimage_epub: new Image.network(pair.backimage_txt, fit: BoxFit.fill),,
              ));
            });*/
            bp.add(BTXT(
                type: item["book_type"] == "path" ? TXT.path : TXT.http,
                src: item["source"] ?? "",
                name: item["name"] ?? "",
                chapterpage: item["chapterpage"] ?? 0,
                backimage_txt: item["backimage"] ?? "",
                chapter_index: item["chapter_index"] ?? 0,
                backimage_epub: test1(item["source"],item["name"]),
                Book_Type: Book.EPUB));
          }

          break;
        case "image": //BImage(type: image.http, src: src_img),
          bp.add(BImage(
            type: item["image_type"] == "path" ? image.path : image.http,
            src: item["source"] ?? "",
          ));
          break;
        case "group": //BImage(type: image.http, src: src_img),
          bp.add(BGroup(
            name: item["Group_name"],
            pages: ParseBook(item["pages"]),
          ));
          break;
        default:
      }
    }
    return bp;
  }

  static void save() {
    preferences.setString("BookGroup", json.encode(BookGroup));
  }

  //BookGroup 添加本地书籍
  static void AddBookPathGroup(
      String name, String Group_name, TXT type, String src, Book BookType) {
    if (Group_name == "") {
      BookGroup.add({
        "type": "book",
        "name": name,
        "book_type": "path",
        "source": src,
        "backimage": "",
        "chapterpage": 0,
        "chapter_index": 0,
        "Type": BookType.name,
      });
    } else {
      //如果需要创建分组的话
      var isnewgroup = false;
      for (var i = 0; i < BookGroup.length; i++) {
        var bk = BookGroup[i] as Map<String, dynamic>;
        //如果是分组
        if (bk["type"] == "group" && bk["Group_name"] == Group_name) {
          ((BookGroup[i] as Map<String, dynamic>)["pages"] as List<dynamic>)
              .add({
            "type": "book",
            "name": name,
            "book_type": "path",
            "source": src,
            "backimage": "",
            "chapterpage": 0,
            "chapter_index": 0,
            "Type": BookType.name,
          });
          isnewgroup = true;
        }
      }
      if (!isnewgroup) {
        BookGroup.add({
          "type": "group",
          "Group_name": Group_name,
          "pages": [
            {
              "type": "book",
              "name": name,
              "book_type": "path",
              "source": src,
              "backimage": "",
              "chapterpage": 0,
              "chapter_index": 0,
              "Type": BookType.name,
            }
          ]
          /*
          BGroup(
          name: Group_name,
          pages: [
            BTXT(
                type: type,
                src: src,
                name: name,
                chapterpage: 0,
                backimage: "",
                chapter_index: 0)
          ],
        )
           */
        });
      }
    }
    preferences.setString("BookGroup", json.encode(BookGroup));
  }

  //设置阅读进度书架信息 章节和页
  static void SetBookGroup(List<int> Index, int chapter, int page) {
    if (Index.length == 1) {
      //只有一个就是书
      //var Temp_map = BookGroup[Index[0]];
      (BookGroup[Index[0]] as Map<String, dynamic>)["chapterpage"] = page;
      (BookGroup[Index[0]] as Map<String, dynamic>)["chapter_index"] = chapter;
    } else {
      var temp_ = BookGroup[Index[0]] as Map<String, dynamic>;
      var temp_1 = temp_["pages"] as List<dynamic>;

      (temp_1[Index[1]] as Map<String, dynamic>)["chapterpage"] = page;
      (temp_1[Index[1]] as Map<String, dynamic>)["chapter_index"] = chapter;
    }
    log("${page}");
    preferences.setString("BookGroup", json.encode(BookGroup));
  }

  //获取书架信息
  static List<BookPage> GetBookGroup() {
    var BookGroupText = preferences.getString("BookGroup");
    var text = BookGroupText ?? "[]";
    """
    [
      {
        "type":"book",
        "name":"书籍名称",
        "book_type":"path",
        "source":"",
        "backimage":"http://bookcover.yuewen.com/qdbimg/349573/1031728889/180",
        "chapterpage":0,
        "chapter_index":0,
        "Type":"TXT",
      },
      {
        "type":"image",
        "image_type":"http",
        "source":"https://bookbk.img.zhangyue01.com/idc_1/m_1,w_200,h_266/7a6e6fec/group61/M00/5E/55/CmQUOV90WHCEcMg-AAAAABv-MzM684786928.jpg"
      },
      {
        "type":"image",
        "image_type":"http",
        "source":"http://bookcover.yuewen.com/qdbimg/349573/1031728889/180"
      },
      {
        "type":"group",
        "Group_name":"默认分组",
        "pages":[
          {
            "type":"book",
            "name":"书籍名称",
            "book_type":"path",
            "source":"",
            "backimage":"http://bookcover.yuewen.com/qdbimg/349573/1031275083/180",
            "chapterpage":0,
            "chapter_index":0,
            "Type":"TXT",
          },
          {
            "type":"book",
            "name":"书籍名称",
            "book_type":"path",
            "source":"",
            "backimage":"http://bookcover.yuewen.com/qdbimg/349573/1031396457/180",
            "chapterpage":0,
            "chapter_index":0,
            "Type":"TXT",
          }
        ]
      }
    ]
    """; //preferences.getString("BookGroup");
    BookGroup = json.decode(text);
    //var obj = bb.cast<Map<String, String>>();
    var bookg = ParseBook(BookGroup);
    return bookg;
    //var aa = obj.cast<String,String>();
    //new Map<String, dynamic>.from(obj);
  }

  //阅读配置
  //获取字体大小
  static double GetFontSize() {
    var size = preferences.getDouble("FontSize");
    if (size == null) {
      return 13.0;
    } else {
      return size;
    }
  }

  //设置字体大小
  static void SetFontSize(double size) {
    preferences.setDouble("FontSize", size);
  }

  //获取字体颜色
  static Color GetFontColor() {
    var color = preferences.getInt("FontColor");
    if (color == null) {
      return Colors.black;
    } else {
      return Color(color);
    }
  }

  //设置字体颜色
  static void SetFontColor(Color color) {
    //var hex = '#${color.value.toRadixString(16)}';//转十六进制
    preferences.setInt("FontColor", color.value);
  }

  //获取背景颜色
  static Color GetBackgroundColor() {
    var color = preferences.getInt("BackgroundColor");
    if (color == null) {
      return Colors.white;
    } else {
      return Color(color);
    }
  }

  static void Setbrightness(double data) {
    preferences.setDouble("brightness", data);
  }

  static double? Getbrightness() {
    return preferences.getDouble("brightness");
  }

  //设置背景颜色
  static void SetBackgroundColor(Color color) {
    //var hex = '#${color.value.toRadixString(16)}';//转十六进制
    preferences.setInt("BackgroundColor", color.value);
  }
}
