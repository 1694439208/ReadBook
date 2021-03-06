import 'dart:developer';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/BookType/Group.dart';
import 'package:flutter_application_1/BookType/Image.dart';
import 'package:flutter_application_1/BookType/Txt.dart';
import 'package:flutter_application_1/search.dart';
import 'package:flutter_application_1/utils/Alert.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import 'Book/CoverChild.dart';
import 'Book/File_selector.dart';
import 'Book/text_canvas.dart';
import 'Book/text_canvas_widget.dart';
import 'BookType/Epub.dart';
import 'BookType/PageAbs.dart';
import 'Photo/Photo.dart';
import 'ReadingContainer.dart';
import 'utils/GlobalConfig.dart';
import 'utils/LibMain.dart';
import 'utils/ThemeChanger.dart';
import 'utils/screen_adaptation.dart';
import 'dart:math' as math;

//书架九宫格可点击类型
enum BookType {
  TXT, //txt电子书
  Image, //图片包括gif
  Group, //目录，里面可以放小说
}

class RandomWords extends StatefulWidget {
  RandomWords({Key? key}) : super(key: key);
//, required this.BookShelf
  static const String src_img =
      "https://bookbk.img.zhangyue01.com/idc_1/m_1,w_200,h_266/7a6e6fec/group61/M00/5E/55/CmQUOV90WHCEcMg-AAAAABv-MzM684786928.jpg";
  var BookShelf = BookConfig.GetBookGroup();
  //var BookShelf = <Widget>[];
  static var index_i = 0;

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final Set<WordPair> _saved = new Set<WordPair>(); // 新增本行
  final _biggerFont = const TextStyle(fontSize: 18.0);
  get _popDrawer => () => Navigator.pop(context);
  @override
  void initState() {
    print('-----initState-----');
    super.initState();
  }

  //ScreenAdaptation.init(context);
  @override
  Widget build(BuildContext context) {
    ScreenAdaptation.init(context);
    return Scaffold(
      //extendBodyBehindAppBar: true,
      //主ui
      appBar: AppBar(
        //toolbarHeight: 0,
        title: const Text('书架'),
        actions: <Widget>[
          // 新增代码开始 ...
          new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      drawer: SizedBox(
          width: MediaQuery.of(context).size.width * 0.56,
          child: new Drawer(
            //New added
            child: new ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  // drawer的头部控件
                  decoration: BoxDecoration(
                    color: Colors.brown,
                  ),
                  child: UnconstrainedBox(
                    // 解除父级的大小限制
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.transparent,
                      backgroundImage: ExactAssetImage('images/back.png'),
                    ),
                  ),
                ),
                SwitchListTile(
                  value: Theme.of(context).brightness != Brightness.dark,
                  title: Text("切换主题"),
                  onChanged: (state) {
                    setState(() {
                      state
                          ? Provider.of<AppInfoProvider>(context, listen: false)
                              .setTheme(Brightness.light)
                          : Provider.of<AppInfoProvider>(context, listen: false)
                              .setTheme(Brightness.dark);
                    });
                  },
                ),
                new ListTile(
                  title: new Text("书架"),
                  trailing: new Icon(Icons.book_online),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                new ListTile(
                  title: new Text("搜索"),
                  trailing: new Icon(Icons.search),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) => new SearchPage()));
                  },
                ),
                new Divider(),
                new ListTile(
                  title: new Text("设置"),
                  trailing: new Icon(Icons.settings),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) => new SearchPage()));
                  },
                ),
              ],
            ),
          )),
      body: _buildSuggestions(),
      floatingActionButton: SpeedDial(
          buttonSize: const Size(50.0, 50.0),
          child: Icon(Icons.add),
          children: [
            SpeedDialChild(
                child: Icon(Icons.devices_other),
                backgroundColor: Colors.red,
                label: '本地导入',
                labelStyle: TextStyle(fontSize: 16.0),
                onTap: () {
                  //BotToast.showText(text: '本地导入');
                  File_(context, (result) {
                    if (result != null && result.length > 0) {
                      showAlertDialog("是否导入目录信息", BackButtonBehavior.none,
                          cancel: () {
                        BotToast.showText(text: '不导入目录');
                        Import_books(result, false);
                        /*for (var item in result) {
                          var name = item.split("/");
                          if (name.last.endsWith(".txt")) {
                            BookConfig.AddBookPathGroup(
                                name.last, "", TXT.path, item, Book.TXT);
                          } else if (name.last.endsWith(".epub")) {
                            BookConfig.AddBookPathGroup(
                                name.last, "", TXT.path, item, Book.EPUB);
                          }
                        }
                        setState(() {
                          widget.BookShelf = BookConfig.GetBookGroup();
                        });*/
                      }, confirm: () {
                        BotToast.showText(text: '导入');
                        Import_books(result, true);
                        /*for (var item in result) {
                          //var path = Uri.decodeComponent(item.identifier!);
                          var temp_list = item.split("/");
                          var name = temp_list.removeLast();
                          //temp_list = temp_list.last.split("/");
                          //log("path:${temp_list}");
                          if (name.endsWith(".txt")) {
                            BookConfig.AddBookPathGroup(
                                name, temp_list.last, TXT.path, item, Book.TXT);
                          } else if (name.endsWith(".epub")) {
                            BookConfig.AddBookPathGroup(name, temp_list.last,
                                TXT.path, item, Book.EPUB);
                          }
                        }
                        setState(() {
                          widget.BookShelf = BookConfig.GetBookGroup();
                        });*/
                      }, backgroundReturn: () {
                        BotToast.showText(text: '不导入');
                      });
                    }
                  });
                  /*FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'pdf', 'txt'],
                  );
                  var a = 1;*/
                }),
            SpeedDialChild(
              child: Icon(Icons.input),
              backgroundColor: Colors.orange,
              label: '规则导入',
              labelStyle: TextStyle(fontSize: 16.0),
              onTap: () {
                BotToast.showText(text: '阅读规则没实现！！！');
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.keyboard_voice),
              backgroundColor: Colors.green,
              label: '占位符',
              labelStyle: TextStyle(fontSize: 16.0),
              onTap: () => BotToast.showText(text: '占位符'),
            ),
          ]),
    );
  }

  void Import_books(Set<String> result, bool IsImport) async {
    BotToast.showText(text: '导入');
    for (var item in result) {
      var temp_list = item.split("/");
      var name = temp_list.removeLast();
      var catalogue = IsImport ? temp_list.last : "";
      if (name.endsWith(".txt")) {
        BookConfig.AddBookPathGroup(name, catalogue, TXT.path, item, Book.TXT);
      } else if (name.endsWith(".epub")) {
        BookConfig.AddBookPathGroup(name, catalogue, TXT.path, item, Book.EPUB);
      }
    }
    Future func = new Future(()async {
      widget.BookShelf = BookConfig.GetBookGroup();
    });
    func.then((value) {
      setState(() {});
    });
  }

  void _pushSaved() {
    Navigator.of(context).push(
      //CupertinoPageRoute
      new MaterialPageRoute<void>(
        // 新增如下20行代码 ...
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (WordPair pair) {
              return new ListTile(
                title: new Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return new Scaffold(
            // 新增 6 行代码开始 ...
            appBar: new AppBar(
              title: const Text('这竟然是个标题'),
            ),
            body: new ListView(children: divided),
          );
        },
      ), // ... 新增代码结束
    );
  }

  Widget _buildSuggestions() {
    return GridView.builder(
      itemCount: widget.BookShelf.length,
      padding:
          EdgeInsets.fromLTRB(10, 10, 10, 10), //const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        //if (i.isOdd) return const Divider(); /*2*/
        var item = CreateView(widget.BookShelf[i], context, [i]);
        return item;
        /*final index = i ~/ 2; /*3*/
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10)); /*4*/
        }
        return CreateView<BTXT>(BTXT()); //_suggestions[index]*/
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, //列数
        mainAxisSpacing: 10, //列向上单元格之间距离
        crossAxisSpacing: 10, //横向上单元格之间的距离
        childAspectRatio: 0.7, //单元格宽高比
      ),
    );
    /*return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return const Divider(); /*2*/

          final index = i ~/ 2; /*3*/
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10)); /*4*/
          }
          return _buildRow(_suggestions[index]);
        });*/
  }

  Widget CreateView<T>(T pair, BuildContext context, List<int> Index,
      {double fontsize = 13, void Function()? builder}) {
    Widget body = Text("data");
    log(pair.runtimeType.toString());
    if (pair is BImage) {
      //FittedBox
      if (pair.type == image.http) {
        body = new Image.network(pair.src, fit: BoxFit.fill);
        //body = new Image.network(pair.src, fit: BoxFit.fill);
      } else {
        body = Stack(
          children: [
            new Image.file(File(pair.src), fit: BoxFit.fill),
            Positioned(
                right: -25,
                top: 10,
                child: Transform.rotate(
                  //RotatedBox //Transform.rotate
                  angle: math.pi / 4,
                  child: Text(
                    "       Image     ",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      backgroundColor: Colors.red,
                    ),
                  ),
                ))
          ],
        );
        //Transform.rotate(angle: - math.pi / 4, child: Text("Text"),);
      }
      body = ClipImagePage("", "Image", widget: body, Fontsize: fontsize);
    }
    if (pair is BTXT) {
      switch (pair.Book_Type) {
        case Book.TXT:
          if (pair.backimage_txt == "") {
            body = ClipImagePage(pair.name, "TXT", Fontsize: fontsize);
          } else {
            body = ClipImagePage(pair.name, "TXT",
                widget: new Image.network(pair.backimage_txt, fit: BoxFit.fill),
                Fontsize: fontsize);
          }
          break;
        case Book.EPUB:
          if (pair.backimage_epub == null) {
            body = ClipImagePage(pair.name, "EPUB", Fontsize: fontsize);
          } else {
            body = ClipImagePage(pair.name, "EPUB",
                widget: FutureBuilder<Image?>(
                  builder:
                      (BuildContext context, AsyncSnapshot<Image?> snapshot) {
                    //snapshot就是_calculation在时间轴上执行过程的状态快照
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return new Text('start'); //如果_calculation未执行则提示：请点击开始
                      case ConnectionState.waiting:
                        return new Text('解析中...'); //如果_calculation正在执行则提示：加载中
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return new Text('无封面...');
                        } else {
                          return snapshot.data!;
                        }
                      default: //如果_calculation执行完毕
                        return new Text('解析中...');
                    }
                  },
                  future: pair.backimage_epub as Future<
                      Image?>, // 用户定义的需要异步执行的代码，类型为Future<String>或者null的变量或函数
                ), // new Image.network(, fit: BoxFit.fill),
                Fontsize: fontsize);
          }
          break;
        default:
      }

      /*body = Center(
        child: Text(
          "123",
          textAlign: TextAlign.center,
        ),
      );*/
    }
    if (pair is BGroup) {
      var obj_temp = pair as BGroup;
      var temp_widget = <Widget>[];
      for (var i = 0; i < obj_temp.pages.length; i++) {
        temp_widget
            .add(CreateView(obj_temp.pages[i], context, [0, 0], fontsize: 6.0));
      }
      body = IgnorePointer(
          child: Stack(
        alignment: AlignmentDirectional.center, // const Alignment(0.0, 0.8),
        children: [
          GridView(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, //列数
                mainAxisSpacing: 1, //列向上单元格之间距离
                crossAxisSpacing: 1, //横向上单元格之间的距离
                childAspectRatio: 0.7, //单元格宽高比
              ),
              children: temp_widget),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: new Container(
              //Positioned
              //分析 4
              decoration: new BoxDecoration(
                color: Color.fromARGB(200, 78, 52, 48),
              ),
              child: new Text(
                obj_temp.name,
                textAlign: TextAlign.center,
                style: new TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ));
    }
    return SwipeActionCell(
      // Specify a key if the Slidable is dismissible.
      key: ValueKey(++RandomWords.index_i),
      trailingActions: [
        SwipeAction(
            title: "删掉",
            widthSpace: 60,
            onTap: (CompletionHandler handler) async {
              showAlertDialog("是否要删除,删除后不可恢复", BackButtonBehavior.none,
                  cancel: () {
                BotToast.showText(text: '不删除');
              }, confirm: () {
                BotToast.showText(text: '删除');
                if (Index.length == 1) {
                  BookConfig.BookGroup.removeAt(Index[0]);
                  widget.BookShelf.removeAt(Index[0]);
                } else {
                  ((BookConfig.BookGroup[Index[0]]
                          as Map<String, dynamic>)["pages"] as List<dynamic>)
                      .removeAt(Index[1]);
                  (widget.BookShelf[Index[0]] as BGroup)
                      .pages
                      .removeAt(Index[1]);
                  if ((widget.BookShelf[Index[0]] as BGroup).pages.length ==
                      0) {
                    BookConfig.BookGroup.removeAt(Index[0]);
                    widget.BookShelf.removeAt(Index[0]);
                  }
                }
                BookConfig.save();
                if (builder != null) {
                  builder();
                }
                setState(() {});
              }, backgroundReturn: () {
                BotToast.showText(text: '不导入');
              });
            },
            color: Colors.brown),
      ],
      // The child of the Slidable is what the user sees when the
      // component is not dragged.
      child: LongPressDraggable(
        //用户拖动item时，那个给用户看起来被拖动的widget，（就是会跟着用户走的那个widget）
        feedback: SizedBox(
          child: Center(
            child: Icon(Icons.menu_book),
          ),
        ),
        child: InkWell(
          onTap: () {
            _CardClick(pair, context, Index);
          },
          child: Card(
            color: Color.fromARGB(
                //夜间模式
                255,
                243,
                240,
                255), //Color.fromARGB(255, 239, 244, 255),
            //z轴的高度，设置card的阴影
            elevation: 8.0,
            //设置shape，这里设置成了R角
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(3.0)),
            ),
            //对Widget截取的行为，比如这里 Clip.antiAlias 指抗锯齿
            clipBehavior: Clip.antiAlias,
            semanticContainer: false,
            child: ConstrainedBox(
              child: body,
              constraints: new BoxConstraints.expand(),
            ),
          ),
        ),
      ),
    );
  }

  void _CardClick<T>(T temp_obj, BuildContext context, List<int> Index) {
    dynamic pair;
    if (Index.length == 1) {
      pair = BookConfig.ParseBook([BookConfig.BookGroup[Index[0]]])[0];
    } else {
      //2
      var aa =
          BookConfig.ParseBook([BookConfig.BookGroup[Index[0]]])[0] as BGroup;
      pair = aa.pages[Index[1]];
    }
    if (pair is BImage) {
      var temp_image = pair as BImage;
      log("BImage被点击");

      Navigator.of(context).push(
        //CupertinoPageRoute
        new MaterialPageRoute<void>(
          // 新增如下20行代码 ...
          builder: (BuildContext context) {
            return Container(
              height: 400.0,
              width: 400,
              child: Center(
                child: Hero(
                  tag: 1,
                  child: PhotoView(
                      imageProvider: NetworkImage(
                          temp_image.src)), //NetworkImage AssetImage
                ),
              ),
            );
          },
        ), // ... 新增代码结束
      );
    }
    if (pair is BTXT) {
      log("BTXT被点击");
      switch (pair.Book_Type) {
        case Book.TXT:
          Navigator.of(context).push(
            //根据txt类型打开不同的
            //CupertinoPageRoute
            new MaterialPageRoute<void>(
              // 新增如下20行代码 ...
              builder: (BuildContext context) {
                return SafeArea(
                  child: TextCanvas1(pair as BTXT, Index),
                );
              },
            ), // ... 新增代码结束
          );
          break;
        case Book.EPUB:
          BotToast.showText(text: 'nonononono！！');
          break;
        default:
      }
    }
    if (pair is BGroup) {
      log("BGroup被点击");
      //用于在底部打开弹框的效果
      showModalBottomSheet(
          builder: (BuildContext context) {
            //构建弹框中的内容
            return StatefulBuilder(builder: (context1, state) {
              return buildBottomSheetWidget(
                  context, pair as BGroup, Index, state);
            });
          },
          backgroundColor: Colors.transparent, //重要
          context: context);
    }
  }

  ///底部弹出框的内容
  Widget buildBottomSheetWidget(BuildContext context, BGroup gp,
      List<int> Index, void Function(void Function())? builder) {
    return FractionallySizedBox(
      heightFactor: 1.3,
      child: Container(
          decoration: new BoxDecoration(
              color: Colors.white, //夜间模式
              borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(5.0),
                  topRight: const Radius.circular(5.0))),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${gp.name}-${widget.BookShelf.length}",
                style: TextStyle(
                  color: Color(0xFF36393D),
                  fontSize: 18,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: gp.pages.length,
                  padding: EdgeInsets.fromLTRB(
                      10, 10, 10, 120), //const EdgeInsets.all(16.0),
                  itemBuilder: (context, i) {
                    //if (i.isOdd) return const Divider(); /*2*/
                    var item = CreateView(
                      gp.pages[i],
                      context,
                      [Index[0], i],
                      builder: () {
                        gp.pages.removeAt(i);
                        if (builder != null) {
                          builder(() {});
                        }
                        if (gp.pages.length == 0) {
                          Navigator.of(context).pop();
                        }
                      },
                    );
                    return item;
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, //列数
                    mainAxisSpacing: 10, //列向上单元格之间距离
                    crossAxisSpacing: 10, //横向上单元格之间的距离
                    childAspectRatio: 0.7, //单元格宽高比
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
