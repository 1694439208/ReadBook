import 'package:flutter/cupertino.dart';

class ReadText extends CustomPainter {

  ReadText({
    this.width,
    this.style,
    this.Title,
    this.Contont,
  }){

  } 

  String? Title = "";
  String? Contont = "";
  TextStyle? style;
  double? width;
  //late Color BackgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    TextSpan span1 = new TextSpan(
        style: TextStyle(
          color:style!.color,
          fontSize: 12,
        ),
        text: Title);
    TextPainter tp1 = new TextPainter(
        text: span1,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp1.layout();

    TextSpan span = new TextSpan(style: style, text: Contont);
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout(maxWidth: width!);
    tp1.paint(canvas, new Offset(5, 5));
    tp.paint(canvas, new Offset(0, tp1.size.height + 5));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is ReadText) {
      return oldDelegate.Contont != Contont ||
          oldDelegate.style!.color!.value != style!.color!.value||
          oldDelegate.style!.fontSize != style!.fontSize;
          //oldDelegate.BackgroundColor.value != BackgroundColor.value ||
          //oldDelegate.offset != offset;
    }
    return false;
  }
}
