import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

//import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Book/Paging.dart';
import 'package:flutter_application_1/BookType/Txt.dart';
import 'package:flutter_application_1/utils/GlobalConfig.dart';
import 'package:flutter_application_1/utils/ThemeChanger.dart';
import 'package:flutter_application_1/utils/screen_adaptation.dart';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'ChapterTextPainter.dart';
import '../utils/LibMain.dart';

//import 'package:seek_book/utils/screen_adaptation.dart';

class TextCanvas1 extends StatefulWidget {
  TextCanvas1(this.bt, this.Index, {Key? key}) : super(key: key) {
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

   /*= Paging_algorithm(
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

  GlobalKey<ChapterTextPainterState>? textKey;

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

  FutureBuilder ?TextView;

  @override
  _TextCanvas1State createState() => _TextCanvas1State();
}

class _TextCanvas1State extends State<TextCanvas1>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;
  late Animation<double> animation1;
  late Future GetBookFile;
  Paging_algorithm?
      pa;
  //final _pageKey = GlobalKey();//我也不知道这做啥的
  

  late AutoScrollController controller;
  final scrollDirection = Axis.vertical;
  // 获取知乎每天的新闻，数据获取成功后 setState来刷新数据
  Future getPathBook(List<int> Index, BuildContext context) async {
    widget.text = "";
    var str = "";
    pa = null;
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

        ///List<String> charsets = await CharsetConverter.availableCharsets();
        try {
          ///Uint8List byte = f.readAsBytesSync();
          var stream = f.openRead();
          str = await stream.transform(utf8.decoder).join();

          ///libReadUtils.getInstance();
          ///str = libReadUtils.LoadFile(widget.bt!.src);
          //////str = String.fromCharCodes(byte);
          //////libReadUtils.getInstance();
          //////var aa = libReadUtils.Split(byte, r"(\s|\n)(第)([\u4e00-\u9fa5a-zA-Z0-9]{1,7})(章)(.+|\n)");
          //////BotToast.showText(text: 'aaa:${aa}');
          /*var result = await CharsetDetector.autoDecode(byte.sublist(0,byte.length>500?500:byte.length));
          if (charsets.contains(result.charset)) {
            str = await CharsetConverter.decode(result.charset, byte)??"编码转换失败:${result.charset}";
          } else {
            str = "TXT只支持utf8编码";
          }*/
          //String s = new String.fromCharCodes(inputAsUint8List);
          //str = await f.readAsString();
        } catch (e) {
          try {
            var stream = f.openRead();
            str = await stream.transform(gbk.decoder).join();
          } catch (e) {
            str = "TXT只支持utf8,gbk编码";
          }
        }
        //str = String.fromCharCodes(byte);
        //print("object:${str.length},widget.bt!.src:${widget.bt!.src}");
      }

      setState(() {
        widget.text = str;
        pa = Paging_algorithm(
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
      /*setState(() {
        widget.text = "加载网络图书没实现！！！";
        widget.pa = Paging_algorithm(
          widget.text!,
          ScreenAdaptation.screenWidth,
          ScreenAdaptation.screenHeight - 50,
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
      });*/
    }
  }

  @override
  void initState() {
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //    statusBarColor: Colors.transparent,
    //    statusBarIconBrightness: Brightness.dark));
/*controller.scrollToIndex(index)
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000)); //时长);*/

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
    //var mediaQueryData = MediaQuery.of(context);
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
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: [SystemUiOverlay.bottom]);
    //SystemChrome.setEnabledSystemUIOverlays([]);
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

  Widget _wrapScrollTag({required int index, required Widget child}) =>
      AutoScrollTag(
        key: ValueKey(index),
        controller: controller,
        index: index,
        child: child,
        highlightColor: Colors.black.withOpacity(0.1),
      );

  void SetAdimn(double begin, double end, Dir DD, double pixelsPerSecond,
      void Function() addListener, void Function(AnimationStatus) listener) {
    //_controller.clearListeners();
    _controller.clearStatusListeners();
    animation = Tween<double>(begin: begin, end: end).animate(_controller)
      ..addListener(addListener)
      ..addStatusListener(listener);
    _controller.forward(from: 0.0);
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
    //var mediaQueryData = MediaQuery.of(context);
    bool isMove = false; //是否移动
    bool isDown = false; //是否按下
    var lastPopTime = DateTime.now();

    var Size = MediaQuery.of(context).size;
    log("渲染一次:${widget.dir}");
    //final pageSize =
    //    (context.findRenderObject() as RenderBox).size;
        

    widget.TextView = FutureBuilder(
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
            print('done:${pa == null}');
            if (snapshot.hasError || pa == null) {
              return Center(
                child: Text('加载失败!!!'),
              );
            }
            log("请求成功");
            widget.TextBook = pa!.This();

            var BView = RepaintBoundary(
              child: Listener(
                /*onPointerDown:(detail){
                  isDown = true;
                },*/
                /*onPointerMove: (detail) {
                  if (detail.delta != Offset.zero) {//如果移动
                    isMove = true;
                  }
                  log("detail.delta:${detail.delta}");
                },
                onPointerUp: (detail) {
                  if (!isMove) {
                    
                  }
                  isMove = false;
                  //isDown = false;
                },*/
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    alignment: Alignment(0.5, 0.5),
                    color: Colors.transparent,
                  ),
                  onDoubleTap: () {
                    //双击弹出百分比进度选择

                    print('双击: ');
                  },
                  onLongPressStart: (detail) {
                    //长按
                    //长按会触发下一页，所以这里跳转到上一页
                    var x = ScreenAdaptation.screenWidth / 3;
                    var y = ScreenAdaptation.screenHeight / 3;
                    if (detail.localPosition.dy > y &&
                        detail.localPosition.dy < y * 2 &&
                        detail.localPosition.dx > x &&
                        detail.localPosition.dx < x * 2) {
                      //var aa = Scaffold.of(context);
                      //Scaffold.of(context).openDrawer();
                    } else {
                      widget.textKey!.currentState!.SetSwitchView(true);
                      pa!.sub_page();
                    }
                  },
                  onPanDown: (detail) {
                    widget.PointStart = detail.globalPosition;
                  },
                  onPanCancel: () {
                    //kPrimaryButton.
                    //按压回调
                    //Scaffold.of(context).openDrawer();
                    //单击页面任何内容下一页
                    print('单击：${lastPopTime}');
                    var detail = widget.PointStart;
                    //lastPopTime = DateTime.now();
                    //模拟单击屏幕中间唤出菜单
                    //detail.localPosition
                    var x = ScreenAdaptation.screenWidth / 3;
                    var y = ScreenAdaptation.screenHeight / 3;
                    if (detail.dy > y &&
                        detail.dy < y * 2 &&
                        detail.dx > x &&
                        detail.dx < x * 2) {
                      //var aa = Scaffold.of(context);
                      Scaffold.of(context).openDrawer();
                    } else {
                      print('SetAdimn1${detail}');
                      SetAdimn(ScreenAdaptation.screenWidth, 0.0, Dir.left, 0.0,
                          () {
                        //widget.textKey!.currentState!
                        //    .SetX(Dir.left, animation.value);
                        //log("animation.value:${animation.value}");
                        setState(() {
                          widget.dir = Dir.left;
                          widget.Xoffset = animation.value;
                        });
                      }, (state) {
                        //当动画结束时执行动画反转
                        if (state == AnimationStatus.completed) {
                          if (Dir.left == Dir.left) {
                            log("messaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaage");
                            //下一页
                            pa!.add_page();
                          }
                          widget.dir = Dir.none;
                          widget.Xoffset = 0.0;
                          //controller.reverse();
                          //当动画在开始处停止再次从头开始执行动画
                        } else if (state == AnimationStatus.dismissed) {
                          //controller.forward();
                        }
                      });
                    }
                    print('手指单击');
                  },
                  onPanStart: (detail) {
                    //按压拖动开始回调
                    //按压开始，不能与 onScale ，onVerticalDrag，onHorizontalDrag，同时使用
                    widget.PointStart = detail.globalPosition;
                  },
                  onPanUpdate: (detail) {
                    //按压拖动回调
                    if (widget.textKey!.currentState!.widget.IsViewList) {
                      return;
                    }
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
                  onPanEnd: (detail) {
                    //按压拖动结束回调
                    if (widget.textKey!.currentState!.widget.IsViewList) {
                      return;
                    }
                    //拖动结束
                    log("拖动结束:${widget.dir}");
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
                    log("拖动结束1:${widget.dir}");

                    SetAdimn(begin, end, DD, detail.velocity.pixelsPerSecond.dx,
                        () {
                      setState(() {
                        widget.dir = DD;
                        widget.Xoffset = animation.value;
                        //log("animation.value:${animation.value},widget.dir:${widget.dir}");
                      });
                    }, (state) {
                      //当动画结束时执行动画反转
                      if (state == AnimationStatus.completed) {
                        log("动画结束:${widget.dir}");
                        if (DD == Dir.left) {
                          if (detail.velocity.pixelsPerSecond.dx >
                                  500 || //detail.velocity.pixelsPerSecond.dx
                              widget.Xoffset <=
                                  ScreenAdaptation.screenWidth / 2) {
                            //ScreenAdaptation.screenWidth / 2
                            //下一页
                            pa!.add_page();
                          }
                        }
                        if (DD == Dir.right) {
                          if (detail.velocity.pixelsPerSecond.dx > 500 ||
                              widget.Xoffset >=
                                  ScreenAdaptation.screenWidth / 2) {
                            //上一页
                            pa!.sub_page();
                          }
                        }
                        DD = Dir.none;
                        widget.dir = Dir.none;
                        widget.Xoffset = 0.0;
                        //controller.reverse();
                        //当动画在开始处停止再次从头开始执行动画
                      } else if (state == AnimationStatus.dismissed) {
                        //controller.forward();
                      }
                    });
                    log("2message:${widget.dir}");
                    print('停止拖动: ${detail}');
                  },
                  //x
                  /*onHorizontalDragStart: (detail) {
                    widget.PointStart = detail.globalPosition;
                  },
                  onHorizontalDragUpdate: (detail) {
                    if (widget.textKey!.currentState!.widget.IsViewList) {
                      return;
                    }
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
                    log("正在拖动:${widget.dir}");
                  },
                  onHorizontalDragEnd: (detail) {
                    if (widget.textKey!.currentState!.widget.IsViewList) {
                      return;
                    }
                    //拖动结束
                    log("拖动结束:${widget.dir}");
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
                    log("拖动结束1:${widget.dir}");

                    SetAdimn(begin, end, DD, detail.velocity.pixelsPerSecond.dx,
                        () {
                      setState(() {
                        widget.dir = DD;
                        widget.Xoffset = animation.value;
                        //log("animation.value:${animation.value},widget.dir:${widget.dir}");
                      });
                    }, (state) {
                      //当动画结束时执行动画反转
                      if (state == AnimationStatus.completed) {
                        log("动画结束:${widget.dir}");
                        if (DD == Dir.left) {
                          if (detail.velocity.pixelsPerSecond.dx >
                                  500 || //detail.velocity.pixelsPerSecond.dx
                              widget.Xoffset <=
                                  ScreenAdaptation.screenWidth / 2) {
                            //ScreenAdaptation.screenWidth / 2
                            //下一页
                            widget.pa!.add_page();
                          }
                        }
                        if (DD == Dir.right) {
                          if (detail.velocity.pixelsPerSecond.dx > 500 ||
                              widget.Xoffset >=
                                  ScreenAdaptation.screenWidth / 2) {
                            //上一页
                            widget.pa!.sub_page();
                          }
                        }
                        DD = Dir.none;
                        widget.dir = Dir.none;
                        widget.Xoffset = 0.0;
                        //controller.reverse();
                        //当动画在开始处停止再次从头开始执行动画
                      } else if (state == AnimationStatus.dismissed) {
                        //controller.forward();
                      }
                    });
                    log("2message:${widget.dir}");
                    print('停止拖动: ${detail}');
                  },*/
                ),
              ),
            );
            if (widget.BookView == null) {
              widget.textKey = GlobalKey();
              widget.BookView = ChapterTextPainter(
                key: widget.textKey,
                text: widget.TextBook,
                Back_text: pa!.Back(),
                Next_text: pa!.Next(),
                text_title: pa!.GetThinTitle(),
                Next_text_title: pa!.GetNextTitle(),
                Back_text_title: pa!.GetBackTitle(),
                lineHeight: 27.0,
                style: TextStyle(
                  fontSize: BookConfig.GetFontSize(),
                  color: BookConfig.GetFontColor(),
                  //backgroundColor: BookConfig.GetBackgroundColor(),
                ),
                width: ScreenAdaptation.screenWidth,
                offset: widget.Xoffset,
                dir: widget.dir,
                BackgroundColor: BookConfig.GetBackgroundColor(),
                pa: pa,
                BView: BView,
                height: ScreenAdaptation.screenHeight,
              );
            } else {
              //widget.textKey.currentState.SetOffet(dir, xoffset, btext, ntext)
              widget.textKey!.currentState!.SetOffet(
                  widget.dir,
                  widget.Xoffset,
                  widget.TextBook,
                  pa!.Back(),
                  pa!.Next(),
                  pa!.GetThinTitle(),
                  pa!.GetNextTitle(),
                  pa!.GetBackTitle(),
                  TextStyle(
                    fontSize: BookConfig.GetFontSize(),
                    color: BookConfig.GetFontColor(),
                    //backgroundColor: BookConfig.GetBackgroundColor(),
                  ),
                  BookConfig.GetBackgroundColor());
            }
            return Stack(
              children: [
                widget.BookView!,
                //BView,
              ],
            );
        }
      },
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      onDrawerChanged: (isDrawerOpen) {
        widget.menu = isDrawerOpen;
        if (isDrawerOpen) {
          /*SystemChrome.setEnabledSystemUIOverlays(
              [SystemUiOverlay.bottom]);*/
          //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual);
          /*Future.delayed(const Duration(milliseconds: 1000), () {
            //延时执行的代码
            controller.scrollToIndex(widget.pa!.ChapterIndex,
            preferPosition: AutoScrollPosition.begin);
            /*if (widget._controller1.hasClients) {
              widget._controller1.animateTo(50.0 * widget.pa!.ChapterIndex,
                  duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
            }*/
          });*/
          /*Future.delayed(const Duration(milliseconds: 1000), () {
            //延时执行的代码
            widget._controller1.jumpTo(widget.pa!.ChapterIndex * 50);
          });*/

          controller.scrollToIndex(
            pa!.ChapterIndex,
            preferPosition: AutoScrollPosition.begin,
          );
        } else {
          //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          //SystemChrome.setEnabledSystemUIOverlays([]);
        }
      },
      drawerEnableOpenDragGesture: false,
      body: GestureDetector(
        //阅读页面
        behavior: HitTestBehavior.opaque,
        child: WillPopScope(
            child: widget.TextView!,
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
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
                  controller: controller,
                  itemCount: pa == null ? 0 : pa!.Titlenum.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _wrapScrollTag(
                        index: index,
                        child: GestureDetector(
                          onTap: () {
                            pa!.SetChapterIndex(index);
                            pa!.page = 0;

                            setState(() {
                              //widget.ScrollOffset = widget._controller1.offset;
                              widget.dir = Dir.none;
                              widget.Xoffset = 0.0;
                              //log("animation.value:${animation.value},widget.dir:${widget.dir}");
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            // 下边框
                            //decoration: BoxDecoration(
                            ////    border: Border(
                            //        bottom: BorderSide(
                            //            width: 0.5, color: Colors.grey))),
                            height: 50,
                            child: ListTile(
                              selected: pa!.ChapterIndex == index,
                              dense: true,
                              title: Text(
                                pa!.Titlenum[index].trim(),
                                style: TextStyle(fontSize: 12),
                              ),
                              subtitle: Text(
                                "字数:${pa!.ChapterList[index].length}",
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
                            ),
                          ),
                        ));
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
                                  if (pa != null) {
                                    pa!.ChapterPageList.clear();
                                    pa!.SetConfig(null, null, aa);
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
                            SwitchListTile(
                              value: Theme.of(context).brightness !=
                                  Brightness.dark,
                              title: Text("切换主题"),
                              onChanged: (state) {
                                
                                setState(() {
                                  //GetBookFile = getPathBook(widget.Index!, context);
                                  state
                                      ? Provider.of<AppInfoProvider>(context,
                                              listen: false)
                                          .setTheme(Brightness.light)
                                      : Provider.of<AppInfoProvider>(context,
                                              listen: false)
                                          .setTheme(Brightness.dark);
                                });
                                
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
  }
}
