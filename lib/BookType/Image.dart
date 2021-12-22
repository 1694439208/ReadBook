import 'PageAbs.dart';

enum image {
  http,
  path,
  none,
}

class BImage  extends BookPage{
  BImage({required this.type,required this.src});
  image type = image.none;
  String src = ""; //默认图片
}
