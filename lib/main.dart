import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memoapp/edit.dart';
import 'package:memoapp/memo.dart';
import 'package:memoapp/db_provider.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(primaryColor: Colors.white),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("ホーム"),
      ),
      body: FutureBuilder(
          future: _getMemo(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            List<Map<String, dynamic>> memoList = snapshot.data;
            return ListView.builder(
              itemCount: memoList.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data = memoList[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => Edit(id: data["id"], memo: data["memo"],)));
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(data["memo"]),
                    ),
                  ),
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, CupertinoPageRoute(builder: (context) => Edit()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getMemo() async {
    final db = await DBProvider.db.database;
    var res = await db.query("Memo");
    return res;
  }
}
