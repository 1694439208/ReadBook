import 'PageAbs.dart';

enum TXT {
  http,
  path,
}

class BTXT extends BookPage{
  BTXT({required this.type,required this.src,required this.chapterpage,this.chapter_index = 0,this.backimage=""}) : super();

  TXT type = TXT.path;//电子书类型，网络或者本地
  String src = ""; //本地或网络地址
  String backimage = "封面";
  int chapterpage = 0;//第几章的 已经读到第几页
  int chapter_index;//第几章

  

}