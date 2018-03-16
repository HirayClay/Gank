import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CategoryPage extends StatefulWidget {
  final String title;

  CategoryPage({Key key, this.title}) :super(key: key);


  @override
  CategoryState createState() {
    return new CategoryState();
  }
}

class CategoryState extends State<CategoryPage> {
  GlobalKey<CategoryState> _key = new GlobalKey<CategoryState>();
  List data = [];
  int pageIndex = 1;

  ScrollController scrollController = new ScrollController(
      initialScrollOffset: 0.0, keepScrollOffset: true);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [ const Color.fromARGB(255, 253, 72, 72),
                    const Color.fromARGB(255, 87, 97, 249),
                    ],
                    stops: [0.0, 1.0])
            ),
          ),
          new ListView.builder(
              key: _key,
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                if (widget.title == '福利')
                  return getBeautyRow(index);
                else
                  return getIndexRow(index);
              })
        ],
      ),);
  }

  Widget getIndexRow(int index) {
    var d = data[index];
    return new ItemView(
        d['desc'],
        d['createdAt'],
        d['who'],
        "Trapadelic lobo",
        index.hashCode % 2 == 0,
        index % (index % 3 + 1),
        d['type'],
        d['url']);
  }

  void loadData() async {
    var response = await http.get(
        'http://gank.io/api/data/${widget.title}/40/$pageIndex');
    var body = JSON.decode(response.body);
    if (mounted)
      setState(() {
        data = body['results'];
//      data.forEach((dynamic t) {
//        print("${t['who'] == null} ${t['desc']}");
//      });
      });
  }

  String format(timeString) {
    String ts = timeString as String;
    int s = ts.indexOf('T');
    if (s > 0)
      return ts.substring(0, s);
    else
      return ts;
  }

  Widget getBeautyRow(int index) {
    return new Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: new BoxDecoration(
        color: Colors.grey.shade200.withOpacity(0.3),
        borderRadius: new BorderRadius.circular(5.0),
      ),
      child: getImage(index),
    );
  }

  getImage(int index){
    print('${data[index]['url']}');
    return new Image.network(data[index]['url'], scale: 2.0,);
  }
}

class ItemView extends StatefulWidget {

  final String url;
  final String desc;
  final String time;
  final String author;
  final String image;
  final bool like;
  final int likeCount;
  final String type;

  @override
  State<StatefulWidget> createState() {
    return new ItemViewState();
  }

  ItemView(this.desc, this.time, this.author, this.image, this.like,
      this.likeCount, this.type, this.url);

}

class ItemViewState extends State<ItemView> {

  int likeCount = 0;
  Dialog dialog;

  Future dialogDismissRef;

  var imgHolder='http://iconfont.alicdn.com/t/1516429577407.png@200h_200w.jpg';


  @override
  void initState() {
    super.initState();
    likeCount = widget.likeCount;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme
        .of(context)
        .textTheme;
    return
      new Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        decoration: new BoxDecoration(
          color: Colors.grey.shade200.withOpacity(0.3),
          borderRadius: new BorderRadius.circular(5.0),
        ),
        child: new IntrinsicHeight(
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              //image
              new Container(
                margin: const EdgeInsets.only(
                    top: 4.0, bottom: 4.0, right: 10.0),
                child: new InkWell(
                  child: new CircleAvatar(
                    backgroundImage: new NetworkImage(
                        '${widget.type == '福利' ? widget.url : imgHolder}', scale: 1.2
                    ),
                    radius: 20.0,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                        new MaterialPageRoute(builder: (BuildContext context) {
                          return new WebviewScaffold(url: widget.url,
                            withJavascript: true,);
                        },));
                  },
                ),
              ),
              //desc
              new Expanded(
                  child: new Container(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text(widget.desc,
                            maxLines: 3,
                            style: textTheme.subhead),
                        new Text('by  ' +
                            (widget.author == null ? "unknown" : widget.author),
                            style: textTheme.caption)
                      ],
                    ),
                  )),
              //like
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 5.0),
                child: new InkWell(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Icon(Icons.favorite, size: 25.0,
                        color: likeCount > 0 ? Colors.purple : Colors.white,),
                      new Text('${likeCount > 0 ? likeCount : ''}'),
                    ],
                  ),
                  onTap: _incrementLikeCount,
                ),
              )
            ],
          ),
        ),
      );
  }

  saveToFile(String url, [BuildContext ctx]) async {
//    var client = new http.Client();
//    var req = new http.StreamedRequest('GET', Uri.parse(url));
//    var res = await client.send(req);
    String dir = (await getExternalStorageDirectory()).path;
    File f;
    http.get(url).then((http.Response res) {
      res.headers.forEach((String k, String v) {
        if (k == 'content-type') {
          f = new File('$dir/${v.substring(v.indexOf('/'))}');
        }
      });
      f.writeAsBytes(res.bodyBytes).whenComplete(() {});
//      Scaffold.of(ctx).showSnackBar(
//          new SnackBar(content: new Text("photo saved to ${f.absolute}"),
//            action: new SnackBarAction(label: "close",
//                onPressed: () {
//                  Scaffold
//                      .of(ctx)
//                      .hideCurrentSnackBar(
//                      reason: SnackBarClosedReason.swipe);
//                }),)
//      );
    });
  }


  void _incrementLikeCount() {
    print('click============');
    setState(() {
      likeCount++;
    });
  }
}

class Model {
/*  _id: "5a967b41421aa91071b838f7",
  createdAt: "2018-02-28T17:49:53.265Z",
  desc: "MusicLibrary-一个丰富的音频播放SDK",
  publishedAt: "2018-03-12T08:44:50.326Z",
  source: "web",
  type: "Android",
  url: "https://github.com/lizixian18/MusicLibrary",
  used: true,
  who: "lizixian"*/
  String _id;
  String createTime;
  String desc;
  String publishTime;
  String source;
  String plat;
  String url;
  String isUsed;
  String author;
  List<String> images;


  Model.fromJson(Map<String, dynamic> json)
      : _id = json['_id'],
        createTime = json['createdAt'],
        desc=json['desc'],
        publishTime=json['publishedAt'],
        source =json['source'],
        plat =json['type'],
        url=json['url'],
        isUsed = json['used'],
        author = json['who'],
        images = json['images'];

}