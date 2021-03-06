import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

//import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Book/Paging.dart';
import 'package:flutter_application_1/BookType/Txt.dart';
import 'package:flutter_application_1/utils/GlobalConfig.dart';
import 'package:flutter_application_1/utils/screen_adaptation.dart';

//import 'package:seek_book/utils/screen_adaptation.dart';
enum Dir { left, top, right, bottom, none }

class ArgData {
  //String? Title;
  BuildContext? context;

  String? text;

  double? height;

  double? width;

  double? lineHeight;

  TextStyle? textStyle;
  ArgData(this.text, this.width, this.height, this.textStyle, this.lineHeight,
      this.context);
}

class ChapterTextPainter extends CustomPainter {
  //计算分页
  static List<int> calcPagerDat11a(text, width, height, textStyle, lineHeight) {
    List<int> result = [];

    var allChart = text.split('');

    double charHeight = lineHeight;

    double xOffset = 10.0;
    int yCharCount = 0;
    int lineCount = 0;
    for (int i = 0; i < allChart.length; i++) {
      var char = allChart[i];
      TextSpan span = new TextSpan(style: textStyle, text: char);
      TextPainter tp = new TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();

      if (char == '\n' || (xOffset + tp.size.width) > width) {
        xOffset = 0.0;
        yCharCount++;
      }
      if ((yCharCount + 1) * charHeight > height && char != '\n') {
        yCharCount = 0;
        result.add(i);
      }
      xOffset += 1 * tp.size.width;
    }
    if (result.length == 0 || result[result.length - 1] != allChart.length) {
      result.add(allChart.length);
    }
//    print("新算法算出来的分页页码, 文本长度${text.length}");
//    print(result);
    return result;
  }

  static List<int> CreatePagerData(ArgData argData) {
    /*final _pageKey = GlobalKey();
    width!-10,
          height!-25,
    final pageSize =
        (_pageKey.currentContext.findRenderObject() as RenderBox).size; */

    var width = argData.width! - 10;
    var height = argData.height! - 50;
    log("width:${width},height${height}");

    List<int> result = [];
    var tempStr = argData.text!;
    int star = 0;
    TextPainter textPainter = new TextPainter(
        locale: Localizations.localeOf(argData.context!),
        text: TextSpan(text: tempStr, style: argData.textStyle),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    textPainter.layout(maxWidth: width); //用于左右各5空隙

    //TextSelection selection =
    //    TextSelection(baseOffset: 0, extentOffset: tempStr.length);

    // get a list of TextBoxes (Rects)  computeLineMetrics
    //List<TextBox> boxes = textPainter.getBoxesForSelection(selection);
    //var LineList = textPainter.computeLineMetrics();

    // https://medium.com/swlh/flutter-line-metrics-fd98ab180a64
    List<LineMetrics> lines = textPainter.computeLineMetrics();
    double currentPageBottom = height;
    int currentPageStartIndex = 0;
    int currentPageEndIndex = 0;

    var bottom_top = 0.0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      final left = line.left;
      final top = line.baseline - line.ascent;
      final bottom = line.baseline + line.descent;
      // Current line overflow page
      if (currentPageBottom < bottom) {
        // https://stackoverflow.com/questions/56943994/how-to-get-the-raw-text-from-a-flutter-textbox/56943995#56943995
        currentPageEndIndex =
            textPainter.getPositionForOffset(Offset(left, top)).offset;
        //final pageText =
        //    tempStr.substring(currentPageStartIndex, currentPageEndIndex);
        result.add(currentPageEndIndex);

        currentPageStartIndex = currentPageEndIndex;
        currentPageBottom = top + height;
        //log("argData.height:${height}");
      }
    }

    //final lastPageText = widget.text.substring(currentPageStartIndex);
    result.add(tempStr.length);
/*int index = 0;
    while (true) {
      height += argData.height!;
      var end = textPainter
          .getPositionForOffset(Offset(argData.width!, height))
          .offset;
      
      log("txt:${tempStr.substring(index,end).length}");
      if (end == tempStr.length) {
        result.add(end);
        break;
      }
      result.add(end);
      index = end;
    }*/

    var a = 0;
    /*TextSpan span = new TextSpan(style: argData.textStyle, text: "国");
    TextPainter tpt = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tpt.layout();

    var font_size = tpt.size;

    var allChart = argData.text!; //.split('');

    double charHeight = font_size.height; //argData.lineHeight!;

    double xOffset = 0.0;
    double yOffset = 0.0;

    int yCharCount = 0;
    int lineCount = 0;
    for (int i = 0; i < allChart.length; i++) {
      var char = argData.text![i];

      //如果碰到换行符 或者字符数量超过屏幕宽度 就跳到下一行 y +1
      if (char == '\n' || (xOffset + font_size.width) > argData.width!) {
        xOffset = 0.0;
        yCharCount++;
      }
      /*
      if (((yCharCount + 1) * charHeight) - yOffset > argData.height! && char != '\n') {
        yCharCount = 0;
        result.add(i);
      }
      */
      if (((yCharCount + 1) * charHeight) > argData.height!) {
        log("yCharCount:${yCharCount}");
        yCharCount = 0;
        result.add(i);
      }
      xOffset += 1 * font_size.width;
    }
    if (result.length == 0 || result[result.length - 1] != allChart.length) {
      result.add(allChart.length);
    }*/
//    print("新算法算出来的分页页码, 文本长度${text.length}");
//    print(result);
    return result;
  }

  final String? Title1;
  final String? text;
  final String? Next_text;
  final String? Back_text;

  String? text_title;
  String? Next_text_title;
  String? Back_text_title;

  double? width;
  double? lineHeight;
  double? offset;
  TextStyle? style;
  Dir dir;

  ChapterTextPainter({
    this.text_title,
    this.Next_text_title,
    this.Back_text_title,
    this.text,
    this.Title1,
    this.Next_text,
    this.Back_text,
    this.width,
    this.lineHeight,
    this.style,
    this.offset = 0.0,
    this.dir = Dir.none,
    this.BackgroundColor,
  }) {
    /*text_title = text!.substring(0,text!.indexOf('\n'));
    Next_text_title = Next_text!.substring(0,Next_text!.indexOf('\n'));
    Back_text_title = Back_text!.substring(0,Back_text!.indexOf('\n'));*/
    BackgroundColor ?? (BackgroundColor = Color.fromARGB(255, 255, 236, 228));
    paint_Back = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill
      ..color = BackgroundColor!
      ..invertColors = false;
    paint_Line = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..invertColors = false
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, convertRadiusToSigma(3));
  }
  Color? BackgroundColor;
  late Paint paint_Back;
  late Paint paint_Line;
  //final Animation<double> factor = 0.0;

  /*Dir _dir = Dir.none;
  void SetDir(Dir dir, double offset) {
    _dir = dir;
    _offset = offset;
  }*/
  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  /**
   * offset 绘制偏移
   * MaxWdith最大宽度
   * width绘制宽度
   */
  void DrawText(
      Canvas canvas, String text, double offset, double MixWdith, double width,
      {bool isd = false, String title = "默认标题"}) {
    if (isd) {
      //canvas.drawLine(Offset(offset, 0), Offset(offset, ScreenAdaptation.screenHeight), paint_Line);
      Rect rect = Rect.fromLTWH(
          offset, 0, MixWdith + 10, ScreenAdaptation.screenHeight + 20);
      //Rect.fromCircle(center: Offset(cx, cy), radius: radius);
      canvas.drawRect(rect, paint_Line);
      //canvas.drawColor(Color.fromARGB(255, 255, 236, 228),BlendMode.clear);
    }

    Rect rect = Rect.fromLTWH(
        offset, 0, MixWdith + 10, ScreenAdaptation.screenHeight + 20);
    //Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    canvas.drawRect(rect, paint_Back);

    TextSpan span1 = new TextSpan(
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
        text: title);
    TextPainter tp1 = new TextPainter(
        text: span1,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp1.layout();

    TextSpan span = new TextSpan(style: style, text: text);
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout(maxWidth: width);

    var end = tp
        .getPositionForOffset(
            Offset(ScreenAdaptation.screenWidth, ScreenAdaptation.screenHeight))
        .offset;

    double x = 10;
    double y = 20;
    if (dir == Dir.right) {
      x += offset;
    } else if (dir == Dir.left) {
      x += offset;
    } else if (dir == Dir.top) {
      y -= offset;
    } else if (dir == Dir.bottom) {
      y += offset;
    }
    tp1.paint(canvas, new Offset(x + 10, 0)); //5
    tp.paint(canvas, new Offset(x, y + 5));

    /*var ChartList = text.split('');
    double xOffset = 0.0;
    int xCharCount = 0;
    int yCharCount = 0;
    int lineCount = 0;
    for (int i = 0; i < ChartList.length; i++) {
      var char = ChartList[i];
      TextSpan span = new TextSpan(style: style, text: char);
      TextPainter tp = new TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();
      log("tp.size:${tp.size}");

      if (char == '\n' || (xOffset + tp.size.width) > width) {
        xOffset = 0.0;
        xCharCount = 0;
        yCharCount++;
      }

      var yOffset =
          yCharCount * lineHeight! + (lineHeight! - tp.size.height) / 2;

      double x = xOffset + 10;
      double y = yOffset + 20;
      if (dir == Dir.right) {
        x += offset;
      } else if (dir == Dir.left) {
        x += offset;
      } else if (dir == Dir.top) {
        y -= offset;
      } else if (dir == Dir.bottom) {
        y += offset;
      }
      if (xOffset + 1 * tp.size.width <= MixWdith) {
        tp.paint(canvas, new Offset(x, y));
        //log("new Offset(x, y):${new Offset(x, y)}");
      }

      xCharCount++;
      xOffset += 1 * tp.size.width;
    }*/
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (dir == Dir.none) {
      //方向往右就是往前翻页
      //首先绘制上一页
      DrawText(canvas, text!, offset!, width!, width!, title: text_title!);
    }
    if (dir == Dir.right) {
      //方向往右就是往前翻页
      //首先绘制上一页
      //log("message:${offset!}");
      DrawText(canvas, Back_text!, 0.0, offset! + 10, width!,
          title: Back_text_title!);
      DrawText(canvas, text!, offset!, width! - offset! + 20, width!,
          isd: true, title: text_title!);
    }
    if (dir == Dir.left) {
      //首先绘制下一页
      //log("message:${offset!}");
      //下一页覆盖
      //DrawText(canvas, Next_text!, offset!, width! - offset! + 20, width!);
      //DrawText(canvas, text!, 0.0,offset! + 20, width!);
      //下一页连接
      //DrawText(canvas, Next_text!, offset!, width! - offset! + 20, width!);
      //DrawText(canvas, text!,-(width!-offset!),width!-10, width!);

      //上一页覆盖划走
      DrawText(canvas, Next_text!, 0.0, width!, width!,
          title: Next_text_title!);
      DrawText(canvas, text!, -(width! - offset!), width!, width!,
          isd: true, title: text_title!);
    }

    /*Offset a = Offset(0, 0);
    Offset b = Offset(0, 0);
    if (dir == Dir.right || dir == Dir.left) {
      a = Offset(offset!, 0);
      b = Offset(offset!, ScreenAdaptation.screenHeight);
    } else if (dir == Dir.top) {
    } else if (dir == Dir.bottom) {}
    var paint = Paint()
      ..isAntiAlias = false
      ..strokeWidth = 1.0
      ..color = Colors.red;
    canvas.drawLine(a, b, paint..strokeCap);*/
    //canvas.drawRect(rect, paint)
  }

//  charWidth(char) {
//    var indexOf = littleChars.indexOf(char);
////    print("$indexOf\t$char");
//    return indexOf >= 0 ? 13.0 : 18.0;
//  }

//  charTopOffset(char) {
//    var indexOf = numbers.indexOf(char);
//    return indexOf >= 0 ? 3.0 : 0;
//  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is ChapterTextPainter) {
      var a = oldDelegate.text != text;
      //log("oldDelegate:${oldDelegate.text} ,text:${text}");
      return oldDelegate.text != text ||
          oldDelegate.style!.color!.value != style!.color!.value ||
          oldDelegate.BackgroundColor!.value != BackgroundColor!.value ||
          oldDelegate.offset != offset;
    }
    return false;
  }
}

class TextCanvas extends StatefulWidget {
  TextCanvas(this.bt, this.Index, {Key? key}) : super(key: key) {
    /*rootBundle.loadString('images/twyl.txt').then((data) {
      text = data;
      //TextBook = pa.This();
    });*/
  }
  List<int>? Index;

  String? text = "";
  BTXT? bt;
  /*final TextStyle? style = TextStyle(
    fontSize: BookConfig.GetFontSize(),
    color: BookConfig.GetFontColor(),
  );*/
  double Xoffset = 0.0;
  Dir dir = Dir.none;

  Paging_algorithm?
      pa; /*= Paging_algorithm(
    text,
    ScreenAdaptation.screenWidth - 20,
    ScreenAdaptation.screenHeight - 20,
    TextStyle(
      fontSize: 20,
      color: Colors.black,
    ),
  );*/
  String TextBook = "";
  int page = 0;

  ChapterTextPainter? BookView;

  bool menu = false; //菜单是否弹出

  double _sliderbrightnessValue = BookConfig.Getbrightness() ?? 0.5; //亮度
  double _sliderSizeValue = BookConfig.GetFontSize(); //字体大小

  final _controller1 = ScrollController(); //目录滚动条
  double ScrollOffset = 0.0; //滚动条位置

  var PointStart = Offset(0, 0); //拖动翻页判断起始点

  var ColorFont = [
    Color.fromARGB(255, 255, 255, 253),
    Color.fromARGB(255, 192, 192, 192),
    Color.fromARGB(255, 140, 140, 140),
    Color.fromARGB(255, 102, 102, 102),
    Color.fromARGB(255, 50, 50, 50),
    Color.fromARGB(255, 1, 1, 1),
    Color.fromARGB(255, 226, 219, 209),
    Color.fromARGB(255, 210, 224, 207),
    Color.fromARGB(255, 183, 208, 205),
    Color.fromARGB(255, 221, 204, 205),
    Color.fromARGB(255, 216, 202, 193),
    Color.fromARGB(255, 69, 64, 61),
    Color.fromARGB(255, 55, 67, 53),
    Color.fromARGB(255, 61, 76, 79),
    Color.fromARGB(255, 92, 83, 78),
  ];
  var ColorBackound = [
    Color.fromARGB(255, 128, 103, 106),
    Color.fromARGB(255, 124, 115, 100),
    Color.fromARGB(255, 89, 99, 118),
    Color.fromARGB(255, 106, 124, 100),
    Color.fromARGB(255, 50, 14, 16),
    Color.fromARGB(255, 108, 115, 146),
    Color.fromARGB(255, 197, 188, 173),
    Color.fromARGB(255, 203, 207, 184),
    Color.fromARGB(255, 180, 185, 153),
    Color.fromARGB(255, 185, 202, 191),
    Color.fromARGB(255, 32, 49, 26),
    Color.fromARGB(255, 216, 210, 194),
    Color.fromARGB(255, 255, 249, 249),
    Color.fromARGB(255, 192, 192, 192),
    Color.fromARGB(255, 94, 94, 92),
    Color.fromARGB(255, 50, 50, 50),
  ];
  var ThisFontColor = BookConfig.GetFontColor();
  var ThisColorBackound = BookConfig.GetBackgroundColor();

  @override
  _TextCanvasState createState() => _TextCanvasState();
}

class _TextCanvasState extends State<TextCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;
  late Future GetBookFile;
  // 获取知乎每天的新闻，数据获取成功后 setState来刷新数据
  Future getPathBook(List<int> Index, BuildContext context) async {
    widget.text = "";
    var str = "";
    widget.pa = null;
    if (widget.bt!.type == TXT.path) {
      print("读取一次txt");
      if (widget.bt!.src == "") {
        await rootBundle.loadString('images/twyl.txt').then((data1) {
          str = data1;
        });
      } else {
        /*File gbkFile = File("gbkFile.txt");
        var stream = gbkFile.openRead();
        stream
            .transform(gbk.decoder)
            .transform(const LineSplitter())
            .listen((line) {
          stdout.writeln(line);
        });*/

        var f = File(widget.bt!.src);
        try {
          str = await f.readAsString();
        } catch (e) {
          str = "TXT只支持utf8编码";
          var stream = f.openRead();
          str = await stream.transform(gbk.decoder).join();
        }
        //str = String.fromCharCodes(byte);
        //print("object:${str.length},widget.bt!.src:${widget.bt!.src}");
      }

      setState(() {
        widget.text = str;
        widget.pa = Paging_algorithm(
          str,
          ScreenAdaptation.screenWidth,
          ScreenAdaptation.screenHeight,
          TextStyle(
            //height: 1.0,
            //fontFamily: 'Piazzolla',
            fontFeatures: [
              FontFeature.tabularFigures(),
              //FontFeature.proportionalFigures(),
            ],
            fontSize: BookConfig.GetFontSize(),
            color: BookConfig.GetFontColor(),
          ),
          Index,
          context,
          ChapterIndex: widget.bt!.chapter_index,
          page: widget.bt!.chapterpage,
        );
      });

      /*return rootBundle.loadString('images/twyl.txt').then((data1) {
        //var aa = MediaQuery.of(context);

        //TextBook = pa.This();
      });*/
    } else {
      setState(() {
        widget.text = "加载网络图书没实现！！！";
        widget.pa = Paging_algorithm(
          widget.text!,
          ScreenAdaptation.screenWidth,
          ScreenAdaptation.screenHeight - 10,
          TextStyle(
            //height: 1.0,
            //fontFamily: 'Piazzolla',
            fontFeatures: [
              FontFeature.tabularFigures(),
              //FontFeature.proportionalFigures(),
            ],
            fontSize: BookConfig.GetFontSize(),
            color: BookConfig.GetFontColor(),
          ),
          Index,
          context,
          ChapterIndex: widget.bt!.chapter_index,
          page: widget.bt!.chapterpage,
        );
      });
    }
  }

  @override
  void initState() {
    //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //    statusBarColor: Colors.transparent,
    //    statusBarIconBrightness: Brightness.dark));

    //_controller = AnimationController(
    //    vsync: this, duration: const Duration(milliseconds: 2000)); //时长);

    ScreenAdaptation.setBrightness(widget._sliderbrightnessValue);
    //DeviceDisplayBrightness.keepOn(enabled: true);

    _controller = AnimationController(
        duration: const Duration(milliseconds: 280), vsync: this);
    /*animation = Tween<double>(begin: 100, end: 0).animate(_controller)
      ..addListener(() {
        //print(animation.value);
      });
    _controller.forward(from: 0.0);*/
    GetBookFile = getPathBook(widget.Index!, context);
    super.initState();
    /*SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.red)
    );*/
    //延时500毫秒执行

    /*Future.delayed(const Duration(milliseconds: 1500), () {
      //延时执行的代码
      isDrawerOpen
      
    });*/
    //隐藏状态栏
    //SystemChrome.setEnabledSystemUIMode(
    //             SystemUiMode.edgeToEdge);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    //WidgetsBinding.instance!.addObserver(this);
  }

  /*Navigator.of(context).push(
          //CupertinoPageRoute
          new MaterialPageRoute<void>(
            // 新增如下20行代码 ...
            builder: (BuildContext context) {
              return Container(
                height: 400.0,
                width: 400,
                decoration: BoxDecoration(
                  color: (Color.fromRGBO(225, 225, 225, 1)).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ), // ... 新增代码结束
        );*/

  @override
  void dispose() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //    overlays: [SystemUiOverlay.top]);
    //DeviceDisplayBrightness.keepOn(enabled: false);
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*var Index_num = ChapterTextPainter.calcPagerData(
        TextCanvas.text,
        MediaQuery.of(context).size.width - 20,
        MediaQuery.of(context).size.height - 20,
        widget.style,
        27.0);*/
    //BookConfig.GetBookGroup();

    var Size = MediaQuery.of(context).size;
    log("渲染一次");

    var TextView = FutureBuilder(
      future: GetBookFile,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            print('waiting');
            return Center(
              child: Text('加载中...'),
            );
          case ConnectionState.done:
            print('done:${widget.pa == null}');
            if (snapshot.hasError || widget.pa == null) {
              return Center(
                child: Text('加载失败!!!'),
              );
            }
            log("请求成功");
            widget.TextBook = widget.pa!.This();
            widget.BookView = new ChapterTextPainter(
              text: widget.TextBook,
              Back_text: widget.pa!.Back(),
              Next_text: widget.pa!.Next(),
              text_title: widget.pa!.GetThinTitle(),
              Next_text_title: widget.pa!.GetNextTitle(),
              Back_text_title: widget.pa!.GetBackTitle(),
              lineHeight: 27.0,
              style: TextStyle(
                fontSize: BookConfig.GetFontSize(),
                color: BookConfig.GetFontColor(),
              ),
              width: ScreenAdaptation.screenWidth,
              offset: widget.Xoffset,
              dir: widget.dir,
              BackgroundColor: BookConfig.GetBackgroundColor(),
            );

            var BView = CustomPaint(
              painter: widget.BookView,
              child: RepaintBoundary(
                  child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                  alignment: Alignment(0.5, 0.5),
                  color: Colors.transparent,
                ),
                onDoubleTap: () {
                  //双击弹出菜单
                  Scaffold.of(context).openDrawer();
                  print('双击: ');
                },
                onTapDown: (detail) {
                  //按下弹出章节菜单
                  //判断屏幕三分之一中间可点击弹出
                  /*var x = ScreenAdaptation.screenWidth / 3;
                  var y = ScreenAdaptation.screenHeight / 3;
                  if (detail.globalPosition.dy > y &&
                      detail.globalPosition.dy < y * 2 &&
                      detail.globalPosition.dx > x &&
                      detail.globalPosition.dx < x * 2) {
                    var aa = Scaffold.of(context);
                    Scaffold.of(context).openDrawer();
                  }*/
                  print(
                      '手指按下:${detail.globalPosition}, ${detail.localPosition}');
                },
                onTapUp: (detail) {
                  print('手指离开屏幕 ${detail.globalPosition}');
                }, //y
                onVerticalDragStart: (detail) {
                  //PointStart = detail.globalPosition;
                },
                onVerticalDragUpdate: (detail) {
                  /*var offset = 0.0; //拖动偏移
                  if (widget.dir == Dir.none) {
                    if (detail.globalPosition.dy > PointStart.dy) {
                      widget.dir = Dir.bottom;
                    } else if (detail.globalPosition.dy < PointStart.dy) {
                      widget.dir = Dir.top;
                    }
                  } else {
                    if (widget.dir == Dir.bottom) {
                      offset = detail.globalPosition.dy;
                    } else if (widget.dir == Dir.top) {
                      offset = Size.height - detail.globalPosition.dy;
                    }
                    //print(
                    //    'offset:${offset},x: ${detail.globalPosition},widget.dir:${widget.dir}');
                    setState(() {
                      widget.Xoffset = offset;
                    });
                  }*/
                },
                onVerticalDragEnd: (detail) {
                  /*setState(() {
                    widget.dir = Dir.none;
                    widget.Xoffset = 0;
                  });*/
                  //print('停止拖动: ${detail}');
                },
                //x
                onHorizontalDragStart: (detail) {
                  widget.PointStart = detail.globalPosition;
                },
                onHorizontalDragUpdate: (detail) {
                  //正在拖动
                  var offset = 0.0; //拖动偏移
                  if (widget.dir == Dir.none) {
                    if (detail.globalPosition.dx < widget.PointStart.dx) {
                      widget.dir = Dir.left;
                    } else if (detail.globalPosition.dx >
                        widget.PointStart.dx) {
                      widget.dir = Dir.right;
                    }
                  } else {
                    if (widget.dir == Dir.left) {
                      offset = detail.globalPosition.dx; //Size.width
                      //log("PointStart:${widget.PointStart.dx - offset},detail:${offset}");
                      offset =
                          Size.width - 10 - (widget.PointStart.dx - offset);
                    } else if (widget.dir == Dir.right) {
                      //offset = (widget.PointStart.dx - offset);
                      offset = detail.globalPosition.dx;
                      offset = offset - widget.PointStart.dx;
                      //log("PointStart:${offset - widget.PointStart.dx},detail:${offset}");
                    }
                    //print(
                    //    'offset:${offset},x: ${detail.globalPosition},widget.dir:${widget.dir}');
                    setState(() {
                      widget.Xoffset = offset;
                    });
                  }
                },
                onHorizontalDragEnd: (detail) {
                  //拖动结束
                  if (widget.dir == Dir.left) {
                    if (detail.velocity.pixelsPerSecond.dx < 350 &&
                        widget.Xoffset > ScreenAdaptation.screenWidth - 6) {
                      setState(() {
                        widget.dir = Dir.none;
                        widget.Xoffset = 0.0;
                        //log("animation.value:${animation.value},widget.dir:${widget.dir}");
                      });
                      return;
                    }
                  }
                  if (widget.dir == Dir.right) {
                    if (detail.velocity.pixelsPerSecond.dx < 350 &&
                        widget.Xoffset < 6) {
                      setState(() {
                        widget.dir = Dir.none;
                        widget.Xoffset = 0.0;
                        //log("animation.value:${animation.value},widget.dir:${widget.dir}");
                      });
                      return;
                      //widget.dir = Dir.left;
                    }
                  }

                  var begin = 0.0;
                  var end = 0.0;
                  Dir DD = Dir.none;
                  if (widget.dir == Dir.left) {
                    begin = widget.Xoffset;
                    end = 0.0;
                    DD = Dir.left;
                  } else if (widget.dir == Dir.right) {
                    begin = widget.Xoffset;
                    end = ScreenAdaptation.screenWidth;
                    DD = Dir.right;
                  }

                  animation =
                      Tween<double>(begin: begin, end: end).animate(_controller)
                        ..addListener(() {
                          setState(() {
                            widget.dir = DD;
                            widget.Xoffset = animation.value;
                            //log("animation.value:${animation.value},widget.dir:${widget.dir}");
                          });
                        })
                        ..addStatusListener((state) {
                          //当动画结束时执行动画反转
                          if (state == AnimationStatus.completed) {
                            if (widget.dir == Dir.left) {
                              if (detail.velocity.pixelsPerSecond.dx > 500 ||
                                  widget.Xoffset <=
                                      ScreenAdaptation.screenWidth / 2) {
                                //ScreenAdaptation.screenWidth / 2
                                //下一页
                                widget.pa!.add_page();
                              }
                            }
                            if (widget.dir == Dir.right) {
                              if (detail.velocity.pixelsPerSecond.dx > 500 ||
                                  widget.Xoffset >=
                                      ScreenAdaptation.screenWidth / 2) {
                                //上一页
                                widget.pa!.sub_page();
                              }
                            }
                            widget.dir = Dir.none;
                            widget.Xoffset = 0.0;
                            //controller.reverse();
                            //当动画在开始处停止再次从头开始执行动画
                          } else if (state == AnimationStatus.dismissed) {
                            //controller.forward();
                          }
                        });
                  _controller.forward(from: 0.0);
                  log("2message:${widget.dir}");
                  print('停止拖动: ${detail}');
                },
              )),
            );
            return BView;
        }
      },
    );
    return Scaffold(
      onDrawerChanged: (isDrawerOpen) {
        widget.menu = isDrawerOpen;
        if (isDrawerOpen) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            //延时执行的代码
            if (widget._controller1.hasClients) {
              widget._controller1.animateTo(50.0 * widget.pa!.ChapterIndex,
                  duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
            }
          });
        }
      },
      drawerEnableOpenDragGesture: false,
      body: GestureDetector(
        //阅读页面
        behavior: HitTestBehavior.opaque,
        child: WillPopScope(
            child: TextView,
            onWillPop: () async {
              //_animateToIndex(i) => _controller1.animateTo(100,
              //    duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);
              //if (Scaffold.of(context).isDrawerOpen) {}
              if (widget.menu) {
                //var aaa = _controller1;//!.position.pixels;
                return true;
              }
              //await SystemChrome.setEnabledSystemUIMode(
              //    SystemUiMode.immersiveSticky);
              return true;
            }),
      ),
      drawer: SizedBox(
        //侧滑菜单
        width: MediaQuery.of(context).size.width * 0.56,
        child: Drawer(
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text('阅读'),
                bottom: TabBar(tabs: [
                  Tab(
                    icon: Icon(Icons.list_alt),
                    //text: "目录",
                  ),
                  Tab(
                    icon: Icon(Icons.settings),
                    //text: '阅读设置',
                  ),
                ]),
              ),
              body: TabBarView(children: [
                Center(
                    child: ListView.builder(
                  controller: widget._controller1,
                  itemCount: widget.pa == null ? 0 : widget.pa!.Titlenum.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      // 下边框
                      //decoration: BoxDecoration(
                      ////    border: Border(
                      //        bottom: BorderSide(
                      //            width: 0.5, color: Colors.grey))),
                      height: 50,
                      child: ListTile(
                        selected: widget.pa!.ChapterIndex == index,
                        dense: true,
                        title: Text(
                          widget.pa!.Titlenum[index].trim(),
                          style: TextStyle(fontSize: 12),
                        ),
                        subtitle: Text(
                          "字数:${widget.pa!.ChapterList[index].length}",
                          //maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 9),
                        ),
                        /*leading: CircleAvatar(
                          child: Text(index.toString()),
                          backgroundColor: widget.pa!.ChapterIndex == index
                              ? Colors.red
                              : Color.fromARGB(255, 250, 250, 250),
                        ),*/
                        onTap: () {
                          widget.pa!.SetChapterIndex(index);
                          widget.pa!.page = 0;

                          setState(() {
                            widget.ScrollOffset = widget._controller1.offset;
                            widget.dir = Dir.none;
                            widget.Xoffset = 0.0;
                            //log("animation.value:${animation.value},widget.dir:${widget.dir}");
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                )),
                Container(
                  //padding: EdgeInsets.all(5),
                  child: ListView(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                        //height: 60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('字体大小:${widget._sliderSizeValue}',
                                textAlign: TextAlign.center),
                            Slider(
                              value: widget._sliderSizeValue,
                              onChanged: (data) {
                                setState(() {
                                  widget._sliderSizeValue = data;
                                });
                                print('change:$data');
                              },
                              onChangeStart: (data) {
                                print('start:$data');
                              },
                              onChangeEnd: (data) {
                                print('.............end:$data');
                                setState(() {
                                  widget._sliderSizeValue = data;
                                  BookConfig.SetFontSize(data);
                                  var aa = TextStyle(
                                    //height: 1.0,
                                    //fontFamily: 'Piazzolla',
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                      //FontFeature.proportionalFigures(),
                                    ],
                                    fontSize: BookConfig.GetFontSize(),
                                    color: BookConfig.GetFontColor(),
                                  );
                                  if (widget.pa != null) {
                                    widget.pa!.ChapterPageList.clear();
                                    widget.pa!.SetConfig(null, null, aa);
                                  }
                                });
                              },
                              min: 10.0,
                              max: 30.0,
                              divisions: 20,
                              label: '${widget._sliderSizeValue}',
                              activeColor: Colors.green,
                              inactiveColor: Colors.grey,
                              semanticFormatterCallback: (double newValue) {
                                return '${newValue.round()} dollars}';
                              },
                            ),
                          ],
                        ),
                      ),
                      new Divider(),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        //height: 60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('亮度:${widget._sliderbrightnessValue}',
                                textAlign: TextAlign.center),
                            Slider(
                              value: widget._sliderbrightnessValue,
                              onChanged: (data) {
                                print('change:$data');
                                setState(() {
                                  widget._sliderbrightnessValue = data;
                                });
                              },
                              onChangeStart: (data) {
                                print('start:$data');
                              },
                              onChangeEnd: (data) {
                                ScreenAdaptation.setBrightness(data);
                                BookConfig.Setbrightness(data);
                                print('end:$data');
                              },
                              min: 0.0,
                              max: 1.0,
                              divisions: 20,
                              label: '${widget._sliderbrightnessValue}',
                              activeColor: Colors.green,
                              inactiveColor: Colors.grey,
                              semanticFormatterCallback: (double newValue) {
                                return '${newValue.round()} dollars}';
                              },
                            ),
                          ],
                        ),
                      ),
                      new Divider(),
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '字体颜色',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: widget.ThisFontColor),
                            ),
                            SizedBox(height: 10),
                            Container(
                              //height: 35,
                              child: Wrap(
                                children: widget.ColorFont.map(
                                    (item) => GestureDetector(
                                          onTap: () {
                                            BookConfig.SetFontColor(item);
                                            setState(() {
                                              widget.ThisFontColor = item;
                                            });
                                          },
                                          child: Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: item,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey, width: 1),
                                            ),
                                          ),
                                        )).toList().cast<Widget>(),
                              ) /* ListView.builder(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.ColorFont.length,
                                  itemBuilder: (context, index) {
                                    return ;
                                  })*/
                              ,
                            ),
                          ],
                        ),
                      ),
                      new Divider(),
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '背景颜色',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: widget.ThisColorBackound),
                            ),
                            SizedBox(height: 10),
                            Container(
                              //height: 35,
                              child: Wrap(
                                children: widget.ColorBackound.map(
                                    (item) => GestureDetector(
                                          onTap: () {
                                            BookConfig.SetBackgroundColor(item);
                                            setState(() {
                                              widget.ThisColorBackound = item;
                                            });
                                          },
                                          child: Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: item,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey, width: 1),
                                            ),
                                          ),
                                        )).toList().cast<Widget>(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
    ;
  }
}
/*
class TextCanvas1 extends StatelessWidget {
  TextCanvas1({
    Key? key,
  }) : super(key: key);
  final String? text = """1
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
                """;
  final TextStyle? style = TextStyle(
    fontSize: 20,
    color: Colors.black,
  );

  //MediaQuery.of(context).size
  @override
  Widget build(BuildContext context) {
    var Index_num = ChapterTextPainter.calcPagerData(
        text,
        MediaQuery.of(context).size.width - 20,
        MediaQuery.of(context).size.height - 20,
        style,
        27.0);

    double Xoffset = 0.0;
    var BookView = new ChapterTextPainter(
      text: text!.substring(0, Index_num[0]),
      lineHeight: 27.0,
      style: style!,
      width: MediaQuery.of(context).size.width - 20,
      offset: Xoffset,
    );
    return CustomPaint(
      painter: BookView,
      child: RepaintBoundary(
          child: GestureDetector(
        child: Container(
          alignment: Alignment(0.5, 0.5),
          color: Colors.transparent,
        ),
        onDoubleTap: () {
          print('双击: ');
        },
        onTapDown: (detail) {
          print('手指按下: ${detail.globalPosition}, ${detail.localPosition}');
        },
        onTapUp: (detail) {
          print('手指离开屏幕 ${detail.globalPosition}');
        },
        onPanStart: (detail) {
          print('开始拖动: ${detail.globalPosition}');
        },
        onPanUpdate: (detail) {
          setState(() {
            count++; // 放在这里也可以
          });
          Xoffset = detail.globalPosition.dx;
          //BookView.SetDir(Dir.left,detail.globalPosition.dx);
          print('正在拖动: ${detail.globalPosition}');
        },
        onPanEnd: (detail) {
          print('停止拖动: ${detail}');
        },
      )),
    );
  }
}
*/
