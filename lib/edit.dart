import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:memoapp/db_provider.dart';

class Edit extends StatefulWidget {
  Edit({this.id, this.memo});
  final int id;
  final String memo;

  @override
  _EditState createState() => new _EditState();
}

class _EditState extends State<Edit> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Widget> _tabs = [
    const Tab(
      child: Text("preview"),
    ),
    const Tab(
      child: Text("editing"),
    )
  ];

  String editText = "";
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: _tabs.length);
    editText = widget.memo == null? "": widget.memo;
    _textEditingController.text = widget.memo == null ? "": widget.memo;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("編集"),
        actions: <Widget>[
          FlatButton(
            onPressed: (){
              _saveText(editText).then((doc) {
                Navigator.pop(context);
              }).catchError((err) {
                print(err);
              });
            },
            child: const Text("保存"),
          ),
        ],
        bottom: TabBar(controller: _tabController, tabs: _tabs),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _previewToWidget(),
          _editTabWidget(),
        ],
      ),
    );
  }

  Widget _previewToWidget() {
    return Container(
        margin: EdgeInsets.all(20), child: Markdown(data: editText));
  }

  Widget _editTabWidget() {
    return Container(
      margin: EdgeInsets.all(20),
      child: TextField(
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration:
        InputDecoration(border: InputBorder.none, hintText: '入力してください'),
        onChanged: (String text) {
          setState(() {
            this.editText = text;
          });
        },
        controller: _textEditingController,
      ),
    );
  }

  Future<void> _saveText(String text) async {
    final db = await DBProvider.db.database;

    var res;
    if (widget.id == null) {
      res = await db.rawInsert(
          "INSERT Into Memo (memo)"
              " VALUES ('$text')");
    } else {
      Map<String, dynamic> memo = Map();
      memo["memo"] = text;
      memo["id"] = widget.id;

      res = await db.update("Memo", memo,
          where: "id = ?", whereArgs: [widget.id]);
    }

    return res;
  }
}