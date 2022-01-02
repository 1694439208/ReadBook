import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Book/text_canvas.dart';
import 'package:flutter_application_1/utils/GlobalConfig.dart';

class Paging_algorithm {
  //String? Text;
  double? width;
  double? height;
  TextStyle? style;
  final double? lineHeight;
  static var pest = RegExp(
      r"(\s|\n)(第)([\u4e00-\u9fa5a-zA-Z0-9]{1,7})(章)(.+|\n)"); //[章节卷集部回]( )
  //替换规则
  static var washpest = RegExp(r"(PS|ps)(.)*(|\\n)");

  //本来是初始化就计算好所有分页，因为要动态调整字体大小和计算绘制尺寸，所以改成一章一章计算
  Paging_algorithm(String data_Text, this.width, this.height, this.style,
      this.Index, this.context,
      {this.lineHeight = 27.0, this.ChapterIndex = 0, this.page = 0}) {
    //Index_num = ChapterTextPainter.calcPagerData(
    //    Text, width, height, style, lineHeight);
//(\s|\n)(第)([\s\S]{1,7})(章)(.+|\n)

    //将小说内容中的PS全部替换为“”
    var data = data_Text.replaceAll(washpest, "");

    var list = pest.allMatches(data);
    Titlenum.add("开始");
    for (var item in list) {
      //log("message${item.group(0)}");
      Titlenum.add(item.group(0) ?? "");
    }

    //分章不够就分块
    if (Titlenum.length == 1 && data_Text.length > 500) {
      //如果没匹配到标题，那就把分成几块防止性能问题
      var num = (data_Text.length / 500).ceil();
      for (var i = 0; i < num; i++) {
        var offset = i * 500;
        Titlenum.add(i.toString());
        if (offset + 500 > data_Text.length) {
          ChapterList.add(data_Text.substring(offset, data_Text.length));
        } else {
          ChapterList.add(data_Text.substring(offset, offset + 500));
        }
      }
    } else {
      ChapterList = data_Text.split(pest); //分章

    }
    //计算当前阅读位置的章节
    if (ChapterIndex < ChapterList.length) {
      var ad = ChapterTextPainter.CreatePagerData(ArgData(
          ChapterList[ChapterIndex],
          width,
          height,
          style,
          lineHeight,
          context));
      ChapterPageList[ChapterIndex] = ad;
    }
    //根据屏幕宽度计算每章多少页
    /*for (var item in ChapterList) {
      var ad = ChapterTextPainter.CreatePagerData(
          ArgData(item, width, height, style, lineHeight));
      ChapterPageList.add(ad);
    }*/

    /*
    
    for (var i = 0; i < Titlenum.length; i++) {
      ChapterList[i+1] ="${Titlenum[i]}\n${ChapterList[i+1]}";
    }*/

    /*var _count = compute(
      ChapterTextPainter.CreatePagerData,
      ArgData(Text, width, height, style, lineHeight),
    );
    _count.then((value) => Index_num=value);*/
  }

  late List<int> Index;
  //章节列表
  late List<String> ChapterList = [];
  //每一章的分页列表
  late Map<int, List<int>> ChapterPageList = {};
  //章节名称
  late List<String> Titlenum = [];
  //章节索引
  int ChapterIndex = 0;
  //页索引
  int page = 0;

  BuildContext? context;

  String GetThinTitle() {
    return Titlenum[ChapterIndex];
  }

  //动态设置样式
  void SetConfig(double? width, double? height, TextStyle? style) {
    this.width = width ?? this.width;
    this.height = height ?? this.height;
    this.style = style ?? this.style;
  }

  //根据一个指定宽度高度样式来计算章节分页
  void CreateChapIndex(
      int index, double width1, double height1, TextStyle style1) {
    if (!ChapterPageList.containsKey(index)) {
      //章节已经解析过就不处理，没解析就开始解析
      if (index < ChapterList.length) {
        
        //没有到最后一章
        var ad = ChapterTextPainter.CreatePagerData(ArgData(
            ChapterList[index], width1, height1, style1, lineHeight, context));
        ChapterPageList[index] = ad;
      }
    }
  }

  String GetNextTitle() {
    //如果页数超出当前章节页数
    if (page + 1 >= ChapterPageList[ChapterIndex]!.length) {
      if (ChapterIndex + 1 < ChapterList.length) {
        //如果有下一章直接返回下一章第一页
        return Titlenum[ChapterIndex + 1];
      }
      return "已经是最后一页了";
    } else {
      //page++;
      return Titlenum[ChapterIndex];
    }
  }

  String GetBackTitle() {
    if (page - 1 < 0) {
      //上一页到底
      if (ChapterIndex - 1 >= 0) {
        //上一章存在就返回上一章最后一页
        return Titlenum[ChapterIndex - 1];
      }
      return "已经是第一页了";
    } else {
      //page--;//正常就返回当前章节页数内容
      return Titlenum[ChapterIndex];
    }
  }

  //设置章节
  void SetChapterIndex(int index) {
    if (index < ChapterList.length && index >= 0) {
      CreateChapIndex(index, width!, height!, style!); //返回下一章之前先判断计算一下分页
      ChapterIndex = index;
    }
  }

  String GetText(int p, int chap) {
    CreateChapIndex(chap, width!, height!, style!); //返回下一章之前先判断计算一下分页
    if (p == 0) {
      return ChapterList[chap].substring(0, ChapterPageList[chap]![0]);
    } else {
      if (p < ChapterPageList[chap]!.length) {
        int a = ChapterPageList[chap]![p];
        int b = ChapterPageList[chap]![p - 1];
        var ret = ChapterList[chap].substring(b, a);
        return ret;
      }
      page = ChapterPageList[chap]!.length - 1;
      return GetText(page, chap);
    }
  }

  String Back() {
    if (page - 1 < 0) {
      //上一页到底
      if (ChapterIndex - 1 >= 0) {
        //上一章存在就返回上一章最后一页
        CreateChapIndex(
            ChapterIndex - 1, width!, height!, style!); //返回下一章之前先判断计算一下分页
        var page1 = ChapterPageList[ChapterIndex - 1]!.length - 1;
        return GetText(page1, ChapterIndex - 1);
      }
      return "已经是第一页了";
    } else {
      //page--;//正常就返回当前章节页数内容
      return GetText(page - 1, ChapterIndex);
    }
  }

  String This() {
    //设置阅读进度
    BookConfig.SetBookGroup(Index, ChapterIndex, page);
    return GetText(page, ChapterIndex);
  }

  String Next() {
    //如果页数超出当前章节页数

    if (page + 1 >= ChapterPageList[ChapterIndex]!.length) {
      if (ChapterIndex + 1 < ChapterList.length) {
        //如果有下一章直接返回下一章第一页
        CreateChapIndex(
            ChapterIndex + 1, width!, height!, style!); //返回下一章之前先判断计算一下分页
        return GetText(0, ChapterIndex + 1);
      }
      return "已经是最后一页了";
    } else {
      //page++;
      return GetText(page + 1, ChapterIndex);
    }
  }

  void add_page() {
    if (page + 1 < ChapterPageList[ChapterIndex]!.length) {
      page++;
    } else {
      //如果一章页数到底，则检测是否有下一章
      if (ChapterIndex + 1 < ChapterList.length) {
        //如果有下一章直接跳转到下一章
        ChapterIndex++;
        SetChapterIndex(ChapterIndex);
        //跳到下一章第一页
        page = 0;
      }
      //ChapterIndex
    }
  }

  void sub_page() {
    if (page - 1 >= 0) {
      page--;
    } else {
      if (ChapterIndex - 1 >= 0) {
        //如果有下一章直接跳转到下一章
        ChapterIndex--;
        SetChapterIndex(ChapterIndex);
        //跳到下一章第一页
        page = ChapterPageList[ChapterIndex]!.length - 1;
      }
    }
  }
}
