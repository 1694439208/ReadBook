import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/screen_adaptation.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'dart:developer';

import 'Paging.dart';
import 'ReadText.dart';

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

class ChapterTextPainter extends StatefulWidget {
  static List<int> CreatePagerData(ArgData argData) {
    List<int> result = [];
    var tempStr = argData.text!;
    int star = 0;
    TextPainter textPainter = new TextPainter(
        locale: Localizations.localeOf(argData.context!),
        text: TextSpan(text: tempStr, style: argData.textStyle),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    textPainter.layout(maxWidth: argData.width!);

    TextSelection selection =
        TextSelection(baseOffset: 0, extentOffset: tempStr.length);
    // get a list of TextBoxes (Rects)  computeLineMetrics
    //List<TextBox> boxes = textPainter.getBoxesForSelection(selection);
    //var LineList = textPainter.computeLineMetrics();

    // https://medium.com/swlh/flutter-line-metrics-fd98ab180a64
    List<LineMetrics> lines = textPainter.computeLineMetrics();
    double currentPageBottom = argData.height!;
    int currentPageStartIndex = 0;
    int currentPageEndIndex = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      final left = line.left;
      final top = line.baseline - line.ascent;
      final bottom = line.baseline + line.descent;

      // Current line overflow page
      if (currentPageBottom < bottom || lines.length - 1 == i) {
        // https://stackoverflow.com/questions/56943994/how-to-get-the-raw-text-from-a-flutter-textbox/56943995#56943995
        currentPageEndIndex =
            textPainter.getPositionForOffset(Offset(left, top)).offset;
        //final pageText =
        //    widget.text.substring(currentPageStartIndex, currentPageEndIndex);
        //_pageTexts.add(pageText);

        result.add(currentPageEndIndex);
        currentPageStartIndex = currentPageEndIndex;
        currentPageBottom = top + argData.height!;
      }
    }
    var a = 0;
    return result;
  }

  ChapterTextPainter({
    Key? key,
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
    this.pa,
    this.BView,
    this.height,
  }) : super(key: key);
  RepaintBoundary? BView;
  Paging_algorithm? pa;
  String? Title1;
  String? text;
  String? Next_text;
  String? Back_text;

  String? text_title;
  String? Next_text_title;
  String? Back_text_title;

  double? width;
  double? height;
  double? lineHeight;
  double? offset;
  TextStyle? style;
  Dir dir;
  Color? BackgroundColor;

  bool IsViewList = false; //是否跳页ui

  double _sliderchapterValue = 0.0; //章节滑动进度

  int chapterindex = 0;

  @override
  ChapterTextPainterState createState() => ChapterTextPainterState();
}

class ChapterTextPainterState extends State<ChapterTextPainter> {
  //late AnimationController _controller;
  //late Animation<double> animation;
  void SetX(
    Dir dir,
    double xoffset,
  ) {
    setState(() {
      if (dir == Dir.none) {
        widget.offset = xoffset;
      }
      if (dir == Dir.right) {
        widget.offset = xoffset;
      }
      if (dir == Dir.left) {
        //上一页覆盖划走
        widget.offset = -(widget.width! - xoffset);
      }
    });
  }

  void SetOffet(
      Dir dir,
      double xoffset,
      String thistext,
      String btext,
      String ntext,
      String ThinTitle,
      String NextTitle,
      String BackTitle,
      TextStyle style,
      Color BackgroundColor) {
    setState(() {
      widget.style = style;
      widget.BackgroundColor = BackgroundColor;
      widget.text = thistext;

      widget.text_title = ThinTitle;
      widget.Back_text_title = BackTitle;
      widget.Next_text_title = NextTitle;

      if (dir == Dir.none) {
        //方向往右就是往前翻页
        //首先绘制上一页
        widget.offset = xoffset;
        //DrawText(canvas, text!, offset!, width!, width!, title: text_title!);
      }
      if (dir == Dir.right) {
        //方向往右就是往前翻页
        //首先绘制上一页
        //log("message:${offset!}");
        widget.offset = xoffset;
        widget.Back_text = btext;
        widget.Back_text_title = BackTitle;
        //DrawText(canvas, Back_text!, 0.0, offset! + 10, width!,
        //    title: Back_text_title!);
        //DrawText(canvas, text!, offset!, width! - offset! + 20, width!,
        //    isd: true, title: text_title!);
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
        widget.offset = -(widget.width! - xoffset);
        widget.Back_text = ntext;
        widget.Back_text_title = NextTitle;
        //DrawText(canvas, Next_text!, 0.0, width!, width!,
        //    title: Next_text_title!);
        //DrawText(canvas, text!, -(width! - offset!), width!, width!,
        //    isd: true, title: text_title!);
      }
      widget.chapterindex = widget.pa!.ChapterIndex;
    });
  }

  void SetSwitchView(bool isview) {
    //切换视图，阅读ui和跳页ui
    setState(() {
      widget.IsViewList = isview;
    });
  }

  late AutoScrollController controller;
  final scrollDirection = Axis.vertical;
  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    widget._sliderchapterValue = widget.pa!.ChapterIndex.toDouble();
    widget.chapterindex = widget.pa!.ChapterIndex;
  }

  Widget _wrapScrollTag({required int index, required Widget child}) =>
      AutoScrollTag(
        key: ValueKey(index),
        controller: controller,
        index: index,
        child: child,
        highlightColor: Colors.black.withOpacity(0.1),
      );

  @override
  Widget build(BuildContext context) {
    //widget._sliderchapterValue = widget.pa!.ChapterIndex.toDouble();
    Widget WidgetView;
    if (widget.IsViewList) {
      WidgetView = GestureDetector(
        //阅读页面
        behavior: HitTestBehavior.opaque,
        child: WillPopScope(
            child: Container(
              key: ValueKey<int>(0),
              //height: 500,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    flex: 20,
                    child: Scrollbar(
                      radius: Radius.circular(5),
                      thickness: 1,
                      child: GridView.builder(
                          shrinkWrap: true,
                          scrollDirection: scrollDirection,
                          controller: controller,
                          //scrollDirection: Axis.vertical,
                          itemCount: widget.pa!
                              .ChapterPageList[widget.pa!.ChapterIndex]!.length,
                          //SliverGridDelegateWithFixedCrossAxisCount 构建一个横轴固定数量Widget
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  //横轴元素个数
                                  crossAxisCount: 3,
                                  //纵轴间距
                                  mainAxisSpacing: 10.0,
                                  //横轴间距
                                  crossAxisSpacing: 10.0,
                                  //子组件宽高长度比例
                                  childAspectRatio: 0.7),
                          itemBuilder: (BuildContext context, int index) {
                            //Widget Function(BuildContext context, int index)
                            log("index:${index},widget.pa!.page:${widget.pa!.page}");
                            Color Border_Color = index == widget.pa!.page &&
                                    widget.chapterindex ==
                                        widget.pa!.ChapterIndex
                                ? Colors.brown.withOpacity(0.8)
                                : Colors.black.withOpacity(0.1);
                            return _wrapScrollTag(
                                index: index,
                                child: GestureDetector(
                                  onTap: () {
                                    log("跳转到指定页");

                                    setState(() {
                                      widget.chapterindex =
                                          widget.pa!.ChapterIndex;
                                      widget.IsViewList = false;
                                      widget.pa!.SetChapterIndex(
                                          widget._sliderchapterValue.toInt());
                                      widget.pa!.page = index;
                                      widget.text = widget.pa!.This();
                                      widget.text_title =
                                          widget.pa!.GetThinTitle();
                                      //log("animation.value:${animation.value},widget.dir:${widget.dir}");
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.topCenter,
                                    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: Container(
                                        width: widget.width,
                                        height: widget.height,
                                        child: CustomPaint(
                                          painter: ReadText(
                                            Title: "${widget.Back_text_title}",
                                            Contont: widget.pa!.GetText(
                                                index, widget.pa!.ChapterIndex),
                                            width: widget.width! - 10,
                                            style: widget.style,
                                          ),
                                        ) /*Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                  text:
                                                      "${widget.Back_text_title}\n"),
                                              TextSpan(
                                                  text: widget.pa!.GetText(
                                                      index,
                                                      widget.pa!
                                                          .ChapterIndex), // widget.Back_text!,
                                                  style: widget.style),
                                            ],
                                          ),
                                        )*/
                                        ,
                                      ),
                                    ),
                                    decoration: new BoxDecoration(
                                        color: widget.BackgroundColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3)),
                                        border: Border.all(
                                            color: Border_Color, width: 0.5),
                                        boxShadow: [
                                          //refer to :https://ninghao.net/video/6443
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              offset:
                                                  Offset(-1.0, 1.0), //阴影x轴偏移量
                                              blurRadius: 3, //阴影模糊程度
                                              spreadRadius: 0.2),
                                        ]),
                                  ),
                                ));
                          }),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Text(
                            '${(widget._sliderchapterValue.toInt() / (widget.pa!.Titlenum.length - 1) * 100).toInt()}%'),
                        Expanded(
                            child: Slider(
                          value: widget._sliderchapterValue,
                          onChanged: (data) {
                            print('change:$data');
                            setState(() {
                              widget._sliderchapterValue = data;
                            });
                          },
                          onChangeStart: (data) {
                            print('start:$data');
                          },
                          onChangeEnd: (data) {
                            setState(() {
                              //先记录当前章节
                              widget.chapterindex = widget.pa!.ChapterIndex;
                              //设置章节
                              widget.pa!.SetChapterIndex(data.toInt());
                              print('end:$data');
                            });
                          },
                          min: 0.0,
                          max: widget.pa!.Titlenum.length - 1,
                          divisions: widget.pa!.Titlenum.length - 1,
                          //label: '第${widget._sliderchapterValue.toInt()}章',
                          activeColor: Colors.green,
                          inactiveColor: Colors.grey,
                          semanticFormatterCallback: (double newValue) {
                            return '${newValue.round()} dollars}';
                          },
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            onWillPop: () async {
              setState(() {
                //设置章节
                widget.pa!.SetChapterIndex(widget.chapterindex);
                widget._sliderchapterValue = widget.chapterindex.toDouble();
                widget.IsViewList = false;
              });
              return false;
            }),
      );
      if (widget._sliderchapterValue.toInt() == widget.chapterindex) {
        controller.scrollToIndex(widget.pa!.page,
            preferPosition: AutoScrollPosition.begin);
      }else{
        controller.scrollToIndex(0,
            preferPosition: AutoScrollPosition.begin);
      }
    } else {
      WidgetView = Container(
        //width: widget.width,
        //height: ScreenAdaptation.screenHeight,
        key: ValueKey<int>(1),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: CustomPaint(
                  painter: ReadText(
                    Title: "${widget.Back_text_title}",
                    Contont: widget.Back_text!,
                    width: widget.width! - 10,
                    style: widget.style,
                  ),
                ) /*Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                          text: "${widget.Back_text_title}\n",
                          style: TextStyle(
                              fontSize: 10, color: widget.style!.color)),
                      TextSpan(text: widget.Back_text!, style: widget.style),
                    ],
                  ),
                )*/
                ,
                decoration: new BoxDecoration(
                    color: widget.BackgroundColor,
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    border: Border.all(color: widget.BackgroundColor!),
                    boxShadow: [
                      //refer to :https://ninghao.net/video/6443
                      BoxShadow(
                          color: Colors.black,
                          offset: Offset(0.0, 2.0),
                          blurRadius: 2.0,
                          spreadRadius: 1.0),
                    ]),
              ),
            ),
            Positioned(
              width: widget.width,
              top: 0,
              bottom: 0,
              left: widget.offset,
              child: Container(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: CustomPaint(
                  painter: ReadText(
                    Title: "${widget.text_title}",
                    Contont: widget.text!,
                    width: widget.width! - 10,
                    style: widget.style,
                  ),
                ) /*Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: "${widget.text_title}\n",
                            style: TextStyle(
                                fontSize: 10, color: widget.style!.color)),
                        TextSpan(text: widget.text!, style: widget.style),
                      ],
                    ),
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr,
                  )*/
                ,
                decoration: new BoxDecoration(
                    color: widget.BackgroundColor,
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    border: Border.all(color: widget.BackgroundColor!),
                    boxShadow: [
                      //refer to :https://ninghao.net/video/6443
                      BoxShadow(
                          color:  Colors.black.withAlpha(50),
                          offset: Offset(0.0, 2.0),
                          blurRadius: 2.0,
                          spreadRadius: 1.0),
                    ]),
              ),
            ),
            widget.BView!,
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        //执行缩放动画
        return FadeTransition(child: child, opacity: animation);
      },
      child: WidgetView,
    );
  }
}
