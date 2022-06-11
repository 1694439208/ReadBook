

import 'dart:async';

import 'package:flutter/material.dart' as m;

import 'PageAbs.dart';

enum TXT {
  http,
  path,
}

enum Book {
  TXT,
  EPUB,
}


class BTXT extends BookPage{
  BTXT({required this.type,required this.src,required this.chapterpage,this.chapter_index = 0,this.backimage_txt="",this.name="",this.Book_Type=Book.TXT,this.backimage_epub}) : super();
  String name = "";
  TXT type = TXT.path;//电子书类型，网络或者本地
  String src = ""; //本地或网络地址
  String backimage_txt = "封面";
  FutureOr<m.Image?>backimage_epub;
  int chapterpage = 0;//第几章的 已经读到第几页
  int chapter_index;//第几章
  Book Book_Type;
}