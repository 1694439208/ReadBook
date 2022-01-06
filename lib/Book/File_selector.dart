import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void File_(context, void Function(Set<String>?) builder) async {
  if (await Permission.storage.request().isGranted) {}
  if (await Permission.manageExternalStorage.request().isGranted) {}
  // 在某个点击事件里
  Navigator.push(
    context,
    new MaterialPageRoute<dynamic>(
      // 新的页面
      builder: (BuildContext context) {
        var Dir_path = "/storage/emulated/0";
        var Dir_State = <bool>[];
        var selecorFile = Set<String>();
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return WillPopScope(
            onWillPop: () async {
              if (Dir_path != "/storage/emulated/0") {
                setState(() {
                  var temp_str = Dir_path.split("/");
                  temp_str.removeLast();
                  Dir_path = temp_str.join("/");
                });
                return false;
              }
              Navigator.pop(context, selecorFile);
              return true;
            },
            child: FutureBuilder(
              future: GetFileDic(Dir_path),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                Scaffold body;
                if (snapshot.connectionState == ConnectionState.done) {
                  var file_list = snapshot.data;
                  Dir_State = List.filled(file_list.length, false);
                  body = new Scaffold(
                    key: ValueKey<int>(0),
                    appBar: new AppBar(
                      title: new Text('导入书籍'),
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(Icons.check),
                          tooltip: '完成选择',
                          onPressed: () {
                            Navigator.pop(context, selecorFile);
                          },
                        ),
                        /*new Padding(
                        child: new Icon(Icons.add, color: Colors.white),
                        padding: EdgeInsets.all(10.0),
                      ),
                      new Padding(
                        child: new Icon(Icons.account_box, color: Colors.white),
                        padding: EdgeInsets.all(10.0),
                      ),
                      new PopupMenuButton(
                        itemBuilder: (BuildContext context) {
                          return <PopupMenuItem<String>>[
                            PopupMenuItem(
                              child: new Text("menu item 1"),
                              value: "第一个",
                            ),
                            PopupMenuItem(
                              child: new Text("menu item 2"),
                              value: "第二个",
                            ),
                          ];
                        },
                        icon: new Icon(Icons.ac_unit, color: Colors.white),
                        onSelected: (String selected) {
                          print("选择的：" + selected);
                        },
                      ),*/
                      ],
                    ),
                    //设置显示在右边的控件
                    body: new Center(
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: file_list.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var icon = Icons.no_encryption;
                                  var type = file_list[index]["type"];
                                  switch (type) {
                                    case "TXT":
                                      icon = Icons.text_fields;
                                      break;
                                    case "folder":
                                      icon = Icons.folder;
                                      break;
                                    default: //BackfFolder
                                  }
                                  return Container(
                                    height: 60,
                                    child: ItemDir(
                                      selected: false,
                                      FileMap: file_list[index],
                                      CallState: (selected, SelectStr) {
                                        //print(SelectStr);
                                        if (selected) {
                                          selecorFile.add(SelectStr);
                                        } else {
                                          selecorFile.remove(SelectStr);
                                        }
                                      },
                                      JmpState: (path) {
                                        setState(() {
                                          Dir_path = path;
                                        });
                                      },
                                      Dir_path: Dir_path,
                                      icon: icon,
                                    ) /*ListTile(
                                  selected: Dir_State[index],
                                  leading: Icon(icon, size: 40), //folder
                                  trailing: type == "folder"
                                      ? null
                                      : Icon(Dir_State[index]
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank),
                                  title: Text(file_list[index]["name"]!),
                                  subtitle: file_list[index]["type"] == "folder"
                                      ? null
                                      : Text(
                                          file_list[index]["state"] == "0"
                                              ? "可导入"
                                              : "已导入",
                                          //maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 9),
                                        ),
                                  onTap: () {
                                    if (file_list[index]["type"] == "folder") {
                                      if (file_list[index]["Isb"] != null) {
                                        setState(() {
                                          Dir_path = file_list[index]["state"];
                                        });
                                      } else {
                                        setState(() {
                                          Dir_path +=
                                              "/" + file_list[index]["name"];
                                        });
                                      }
                                    } else if (file_list[index]["type"] ==
                                        "TXT") {
                                      setState(() {
                                        Dir_State[index] = !Dir_State[index];
                                      });
                                    }
                                  },
                                )*/
                                    ,
                                    decoration: new BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 0.1, //宽度
                                          color: Colors.brown, //边框颜色
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  body = new Scaffold(
                    key: ValueKey<int>(1),
                    appBar: new AppBar(title: new Text('导入书籍')),
                    body: new Center(),
                  );
                }
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    //执行缩放动画
                    return FadeTransition(child: child, opacity: animation);
                  },
                  child: body,
                );
              },
            ),
          );
        });
      },
    ),
  ).then((value) {
    //BotToast.showText(text: '选择完毕');
    builder(value);
  });
  //Directory? exDir = await getExternalStorageDirectory();
  //print("外部路径$exDir");
  //GetFileDic();
}

Future<List<Map<String, String>>> GetFileDic(String path_dir) async {
  Stream<FileSystemEntity> fileList = Directory(path_dir).list();
  var file_list = [];
  var dir_list = [];
  await for (FileSystemEntity fileSystemEntity in fileList) {
    print('$fileSystemEntity');
    //file_list.add(value)
    var path = fileSystemEntity.path.split("/");
    var name = path[path.length - 1];
    if (FileSystemEntity.typeSync(fileSystemEntity.path) ==
        FileSystemEntityType.file) {
      file_list.add({
        "name": name,
        "type": "TXT",
        "state": "0", //0没导入过 1导入过
        "selected": "false",
      });
    }
    if (FileSystemEntity.typeSync(fileSystemEntity.path) ==
        FileSystemEntityType.directory) {
      dir_list.add({
        "name": name,
        "type": "folder",
        "state": "",
      });
    }
  }
  //dir_list.sort((a, b) => a["name"][0]);
  //file_list.sort((a, b) => a.length.compareTo(b.length));
  dir_list.addAll(file_list);
  if (path_dir != "/storage/emulated/0") {
    var list = path_dir.split("/");
    list.removeLast();
    dir_list.insert(0, {
      "name": "...",
      "type": "folder",
      "state": list.join("/"),
      "Isb": "666", //是否跳到上一层
    });
  }

  return dir_list.cast<Map<String, String>>();
}

class ItemDir extends StatefulWidget {
  ItemDir(
      {Key? key,
      this.FileMap,
      this.CallState,
      this.Dir_path,
      this.JmpState,
      this.selected,
      this.icon})
      : super(key: key);

  void Function(bool, String)? CallState; //选择回调
  void Function(String)? JmpState;
  bool? selected;
  IconData? icon;
  Map<String, String>? FileMap;
  String? Dir_path;
  @override
  _ItemDirState createState() => _ItemDirState();
}

class _ItemDirState extends State<ItemDir> {
  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Container(
      child: ListTile(
        leading: Icon(widget.icon, size: 40), //folder
        trailing: widget.FileMap!["type"]! == "folder"
            ? null
            : Icon(widget.selected!
                ? Icons.check_box
                : Icons.check_box_outline_blank),
        title: Text(widget.FileMap!["name"]!),
        subtitle: widget.FileMap!["type"] == "folder"
            ? null
            : Text(
                widget.FileMap!["state"]! == "0" ? "可导入" : "已导入",
                //maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 9),
              ),
        onTap: () {
          if (widget.FileMap!["type"]! == "folder") {
            if (widget.FileMap!["Isb"] != null) {
              widget.JmpState!(widget.FileMap!["state"]!);
            } else {
              widget
                  .JmpState!(widget.Dir_path! + "/" + widget.FileMap!["name"]!);
            }
          } else if (widget.FileMap!["type"]! == "TXT") {
            setState(() {
              widget.selected = !widget.selected!;
              widget.CallState!(widget.selected!,
                  widget.Dir_path! + "/" + widget.FileMap!["name"]!);
            });
          }
        },
      ),
    );
  }
}
