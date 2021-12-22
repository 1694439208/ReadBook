



import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({ Key? key }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Scaffold(
            // 新增 6 行代码开始 ...
            appBar: new AppBar(
              title: const Text('这竟然是个标题'),
            ),
            body: new ListView(),
          ),
    );
  }
}