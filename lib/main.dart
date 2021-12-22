// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/services.dart';
import 'books.dart';
import 'utils/GlobalConfig.dart';
import 'package:bot_toast/bot_toast.dart';

void main() => realRunApp();

void realRunApp() {
  runApp(MyApp());
}

Future<void> loadAsync() async {
  bool success = await BookConfig.getInstance();
  print("init-" + success.toString());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final wordPair = WordPair.random();
    return MaterialApp(
      title: '海绵阅读器',
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      theme: ThemeData(
        primarySwatch: Colors.brown,
        primaryColor: Colors.white,
      ), //设置App主题,
      home: FutureBuilder(
        future: loadAsync(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return RandomWords();
          } else {
            return Container(
              color: Colors.white,
              child: Center(
                child: Text("数据加载中……",
                    style: TextStyle(fontSize: 20, color: Colors.orange)),
              ),
            );
          }
        },
      ),
    );
  }
}
