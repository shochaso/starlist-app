import 'package:flutter/material.dart';

/// アプリケーションのルートウィジェット
class App extends StatelessWidget {
  /// コンストラクタ
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StarList',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('StarListアプリが正常に起動しました！'),
        ),
      ),
    );
  }
}
