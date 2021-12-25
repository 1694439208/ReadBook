//import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/GlobalConfig.dart';

class ClipImagePage extends StatelessWidget {
  ClipImagePage(this.title, this.type, {this.widget, this.Fontsize});
  String? title;
  String? type;
  Widget? widget;
  double? Fontsize = 16;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Padding(
        padding: widget==null?EdgeInsets.all(6):EdgeInsets.zero,
        child: widget ??
            Text(
              title!,
              style: TextStyle(fontSize: Fontsize!-1),
            ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: ClipPath(
          clipper: MyClipper(),
          child: new FractionallySizedBox(
            //alignment: Alignment.topLeft,
            widthFactor: 1,
            heightFactor: 0.38,
            child: new Container(
                color: BookConfig.GlobalBolor,
                child: Align(
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        type!,
                        style: TextStyle(
                            color: Colors.white70, fontSize: Fontsize),
                      ),
                    ),
                  ),
                )),
          ),
        ),
      )
    ]);
  }
}

/*————————————————
版权声明：本文为CSDN博主「NeverSettle101」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/qq_21265915/article/details/117438699*/
class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    var y = size.height / 3 * 2;

    path.moveTo(0, y); // start point
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
    /*var radius = size.width / 3;

    path.arcToPoint(Offset(radius, radius), radius: Radius.circular(radius));

    var lineY = size.height - radius;
    var finalLineY = lineY > radius ? lineY : radius;

    path.lineTo(radius, finalLineY);

    path.arcToPoint(Offset(2 * radius, size.height),
        radius: Radius.circular(radius), clockwise: false);

    path.lineTo(0, size.height);
    path.close();

    return path;*/
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
