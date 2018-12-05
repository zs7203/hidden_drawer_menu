import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/zoom_scaffold.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  createMenuTitle(MenuController menuController) {
    final slideAmount = 250 * (1 - menuController.percentOpen) - 100;

    return new Transform(
      transform: new Matrix4.translationValues(slideAmount, 0, 0),
      child: new OverflowBox(
        maxWidth: double.infinity,
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: new Text(
            'Menu',
            style: new TextStyle(
              color: const Color(0x88444444),
              fontSize: 240.0,
              fontFamily: 'mermaid',
            ),
            textAlign: TextAlign.left,
            softWrap: false,
          ),
        ),
      ),
    );
  }

  createMenuItems(MenuController menuController) {
    return new Transform(
      transform: new Matrix4.translationValues(0, 225, 0),
      child: Column(
        children: <Widget>[
          new _MenuListItem(
            title: 'The PadLock',
            isSelected: true,
            onTap: () => menuController.close(),
          ),
          new _MenuListItem(
            title: 'Chat',
            isSelected: false,
            onTap: () => menuController.close(),
          ),
          new _MenuListItem(
            title: 'Gift',
            isSelected: false,
            onTap: () => menuController.close(),
          ),
          new _MenuListItem(
            title: 'User',
            isSelected: true,
            onTap: () => menuController.close(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MenuController menuController =
        ZoomScaffoldWithController.of(context).controller;
    return new Container(
      width: double.infinity,
      height: double.infinity,
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage('assets/dark_grunge_bk.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: new Material(
        color: Colors.transparent,
        child: new Stack(
          children: <Widget>[
            createMenuTitle(menuController),
            createMenuItems(menuController),
          ],
        ),
      ),
    );
  }
}

class _MenuListItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onTap;

  _MenuListItem({this.title, this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      splashColor: const Color(0x44000000),
      onTap: isSelected ? null : onTap,
      child: new Container(
        width: double.infinity,
        child: new Padding(
          padding: const EdgeInsets.only(left: 50.0, top: 15.0, right: 15.0),
          child: new Text(
            title,
            style: new TextStyle(
                color: isSelected ? Colors.red : Colors.white,
                fontSize: 25.0,
                fontFamily: 'bebas-neue',
                letterSpacing: 2.0),
          ),
        ),
      ),
    );
  }
}
