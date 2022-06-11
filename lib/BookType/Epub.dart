import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as m;
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

//import 'package:flutter_application_1/BookType/Image.dart';
Future<String> Parse_EPUB(dynamic arg) async {
  String path = arg["path"];
  String name = arg["name"];
  String path1 = arg["StorageDir"];

  String path2 = p.join(path1, name + ".png");
  var file_backimg = File(path2);
  if (file_backimg.existsSync()) {
    //return m.Image.file(file_backimg);
  } else {
    var targetFile = new File(path);
    List<int> bytes = targetFile.readAsBytesSync();
    // Opens a book and reads all of its content into memory
    EpubBook epubBook = await EpubReader.readBook(bytes);
    var aa = image.encodePng(epubBook.CoverImage!);
    file_backimg.writeAsBytesSync(Uint8List.fromList(aa));
  }
  return path2;
}

Future<m.Image?> test1(String path, String name) async {
  //String fileName = 'sample.epub';
  //String fullPath = path.join(Directory.current.path, fileName);
  var path1 = await getExternalStorageDirectory();
  var file_backimg = await compute(Parse_EPUB, {
    "path": path,
    "name": name,
    "StorageDir": path1!.path,
  });
  var f = new File(file_backimg).readAsBytesSync();
  return m.Image.memory(f, errorBuilder: (context, error, stackTrace) {
    return Text("assets/images/defaultHeader.jpeg");
  });

  ///storage/emulated/0/Android/data/com.hmbb.yuyue/files/斗破苍穹.epub.png
  /*return await compute(Parse_EPUB, {
    "path": path,
    "name": name,
    "StorageDir": path1!.path,
  });*/
  //return m.Image.memory(epubBook.CoverImage!.getBytes());
}
