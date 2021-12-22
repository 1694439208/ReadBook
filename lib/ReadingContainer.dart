import 'dart:developer';

import 'package:flutter/material.dart';

class ReadTxt extends StatefulWidget {
  const ReadTxt({Key? key}) : super(key: key);

  @override
  _ReadTxtState createState() => _ReadTxtState();
}

class _ReadTxtState extends State<ReadTxt> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: new Image.asset('images/back.png', fit: BoxFit.fill),
          ),
          Column(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Text(
                    "章节名称",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 20,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: BookControl(
                    data: """1
                末日刁民
作者：十阶浮屠

内容简介：
　　当末日席卷而至，资深屌丝陈光大却贼眉鼠眼的露出了脑袋，俏寡妇！靓人妻！美少女！还有兄弟的女朋友！究竟该带谁走，这真的是个问题……
1
1
第一卷 舌尖上的人类
第一卷 舌尖上的人类
第一卷 舌尖上的人类
第一卷 舌尖上的人类
第一卷 舌尖上的人类
第一卷 舌尖上的人类
第一卷 舌尖上的人类
第一卷 舌尖上的人类
1
1
1
1
第1章 收尸人
　　七月中旬正是太阳最毒辣的时候，正午时分更是把人给烤的外焦里嫩，不过陈光大却是一身喜气，直接顶着大太阳就出门了，虽然他马上要去参加的是一场葬礼，但这对他来说也是件值得高兴的事，因为一旦死了人他的生意也就来了，即使……死的是他的老同学！
　　跨上他的九手桑塔纳3000，陈光大习惯性的看了一眼车后的殡葬用品，确定没少什么之后他便颠颠的开往葬礼现场，而略带嘈杂的音箱中，很快就响起了他梦中情人苏瞳的声音，温柔而又甜美的为大家播报着新闻。
                """,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Text(
                    "底部",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReadBook {
  /**
   *
   */
  ReadBook(BuildContext this.context, String this.data, TextStyle this.style,
      double this.maxWidth, double this.height) {
    PageLine = data.split("\n"); //.map((e) => "\n${e}").toList();
    PageCount = PageLine.length;
    //print(PageLine[0]);

    var size = GetTextSize(context, "1", style, maxWidth: maxWidth);
    LineIndex = (height ~/ size.height);
  }
  int LineIndex = 0; //最大渲染行

  BuildContext context; //环境
  TextStyle style; //样式
  late List<String> PageLine; //每一行
  String data; //当前文档
  int index = 0; //当前页数 //逻辑页数，用户不可见，不可写
  int OffsetIndex = 0; //当前页数几行,偏移字符数

  int PageCount = 0; //总行数
  double maxWidth = 0; //实际渲染宽度
  double height = 0; //实际渲染高度
  double thisheight = 0; //当前实际渲染高度

//设置当前逻辑页
  void SetPage(int page) {}
//读取上一页
  String GetBackPage() {
    var StrList = <String>[];
    /*int Offset = index;
    while (++Offset >= 0) {
      var str_temp = data[Offset];
      StrList.add(str_temp);
      var isc =
          boundingTextSize(context, StrList.join(), style,maxLines: LineIndex, maxWidth: maxWidth);
      if (isc) {
        StrList.removeLast();
        return StrList.join();
      }
    }
    return StrList.join();*/

    int Offset = index;
    while (thisheight < height && Offset < PageCount - 1) {
      //计算当前一行占多少高度
      var size =
          GetTextSize(context, PageLine[Offset], style, maxWidth: maxWidth);
      
      if (thisheight + size.height > height) {
        var str_temp = PageLine[Offset];
        while (thisheight + size.height > height && str_temp != "") {
          if (str_temp != null && str_temp.length > 0) {
            str_temp = str_temp.substring(0, str_temp.length - 1);
          }
          size = GetTextSize(context, str_temp, style, maxWidth: maxWidth);
        }
        StrList.add(str_temp);
      } else {
        StrList.add(PageLine[Offset]);
      }

      thisheight += size.height;
      Offset++;
      print(
          "size.height:${size.height},,thisheight:${thisheight},height${height} |Offset:${Offset} < PageCount:${PageCount}");
    }
    return StrList.join();
  }

  //读取当前页
  String GetPage() {
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr); 
    textPainter.text = TextSpan(text: data, style: TextStyle(fontSize: 14,color: Colors.grey),);
    //textPainter.layout(maxWidth: width);
    //获取占满这个区域的String的最后一个字符的index(第几个就返回几) 
    //int end = textPainter.getPositionForOffset(Offset(width, 50.0)).offset; 
    //得到这个end也可以对字符串就行拆分 把字符串组装 list。给richtext。 这种方式还是挺不错的。不过对于大文本，还是会卡顿。
    return "";
  }

  //读取下一页
  String GetNextPage() {
    return "";
  }

  static Size GetTextSize(BuildContext context, String text, TextStyle style,
      {int maxLines = 30, double maxWidth = double.infinity}) {
    if (text == null || text.isEmpty) {
      return Size.zero;
    }
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      //locale: Localizations.localeOf(context),
      locale: WidgetsBinding.instance!.window.locale,
      textDirection: TextDirection.rtl,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      maxLines: maxLines,
      
    )..layout(maxWidth: maxWidth);
    return textPainter.size;
  }

  static bool boundingTextSize(
      BuildContext context, String text, TextStyle style,
      {int maxLines = 20, double maxWidth = double.infinity}) {
    if (text == null || text.isEmpty) {
      return false;
    }
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      //locale: Localizations.localeOf(context),
      locale: WidgetsBinding.instance!.window.locale,
      textDirection: TextDirection.rtl,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);
    //..paint(canvas, Offset(0.0, 148.0));
    //textPainter.didExceedMaxLines
    return textPainter.didExceedMaxLines;
  }
}

class BookControl extends StatefulWidget {
  BookControl(
      {Key? key, required String this.data, required TextStyle this.style})
      : super(key: key);

/*text: data,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),*/
  String data = "";
  TextStyle style;
  @override
  _BookControlState createState() => _BookControlState();
}

class _BookControlState extends State<BookControl> {
  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: RichText(
        text: TextSpan(
          text: widget.data,
          style: widget.style,
        ),
      ),
      onTap: () {
        var r = ReadBook(context, widget.data, widget.style,
            context.size!.width, context.size!.height);
        r.SetPage(0);
        log('Size is ${context.size}, ${r.GetBackPage()}, ${2 ^ 301}');
      },
    );
  }
}
