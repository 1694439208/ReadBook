import 'package:flutter/cupertino.dart';

import 'PageAbs.dart';

class BGroup extends BookPage {
  BGroup({required this.pages, this.name = "默认分组1"});
  var pages = <BookPage>[];
  var name = "";
}
