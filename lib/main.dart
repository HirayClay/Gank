import 'package:flutter/material.dart';
import 'package:flutter_gank/page/catpage.dart';
import 'package:flutter_gank/widget/overscroll_demo.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin<HomePage> {

  List pageTitle = ['Android', 'iOS', '福利', '休息视频'];

  TabController tabController;
  TabBar tabBar;

  @override
  Widget build(BuildContext context) {
    tabController = new TabController(length: 4, vsync: this);
    tabBar = new TabBar(
      isScrollable: false,
      controller: tabController,
      tabs: pageTitle.map((dynamic title) {
        return new Tab(text: title, icon: null);
      }).toList(),
    );
    return new DefaultTabController(
        length: pageTitle.length,
        child: new Scaffold(
          drawer: new SizedBox(
            width: 290.0,
            height: 1900.0,
            child:
            new Stack(
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
                new ListView(
                  padding: new EdgeInsets.only(
                      left: 30.0, right: 0.0, top: 55.0),
                  children: <Widget>[
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Padding(padding: new EdgeInsets.only(
                            top: 25.0, left: 19.0),
                          child: new Icon(Icons.toys, size: 40.0,
                            color: Colors.white,
                            textDirection: TextDirection.ltr,),)
                      ],
                    ),
                    new DrawerItem(name: "Android", icon: Icons.android,
                        onTap: () {
                          tabController.animateTo(0);
                        }),
                    new DrawerItem(name: "iOS", icon: Icons.apps,
                      onTap: () {
                        tabController.animateTo(1);
                      }
                      ,),
                    new DrawerItem(name: "福利", icon: Icons.favorite,
                      onTap: () {
                        tabController.animateTo(2);
                      }
                      ,),
                    new DrawerItem(name: "休息视频", icon: Icons.free_breakfast,
                      onTap: () {
                        tabController.animateTo(3);
                      }
                      ,),
                    new DrawerItem(
                        name: "Scroll", icon: Icons.slideshow, onTap: () {
                      Navigator.of(context).push(new MaterialPageRoute(
                          builder: (BuildContext context) {
                            return new OverscrollDemo();
                          }));
                    }),
                  ],
                )
              ],
            )
            ,),
          appBar: new AppBar(
            leading: null,
            automaticallyImplyLeading: true,
            title: new Text('Gank.io'),
            bottom: tabBar,
          ),
          body: new TabBarView(children: [
            new CategoryPage(title: 'Android'),
            new CategoryPage(title: 'iOS'),
            new CategoryPage(title: '福利'),
            new CategoryPage(title: '休息视频',)
          ], controller: tabController,),
        )

    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}


class DrawerItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Function onTap;


  DrawerItem({this.name, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return new InkWell(child:
    new Padding(padding: new EdgeInsets.only(
        left: 10.0, top: 25.0, right: 0.0, bottom: 0.0),
      child: new Row(mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Icon(icon),
          new Text(name, style: new TextStyle(
              color: Colors.white,
              fontSize: 18.0
          ))
        ],),),
      onTap: this.onTap,);
  }
}
