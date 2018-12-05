import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/menu_screen.dart';

class ZoomScaffold extends StatefulWidget {
  final Widget menuScreen;
  final Screen contentScreen;

  ZoomScaffold({this.menuScreen, this.contentScreen});

  @override
  _ZoomScaffoldState createState() => _ZoomScaffoldState();
}

class _ZoomScaffoldState extends State<ZoomScaffold>
    with TickerProviderStateMixin {
  MenuController menuController;
  Curve scaleDownCurve = new Interval(0.0, 0.3, curve: Curves.easeOut);
  Curve scaleUpCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);
  Curve slideOutCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);
  Curve slideInCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    menuController = new MenuController(
      vsync: this,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  createContentDisplay(Screen contentScreen, MenuController controller) {
    return zoomAndSlideContent(
        Container(
          decoration: new BoxDecoration(
            image: contentScreen.background,
          ),
          child: new Scaffold(
              backgroundColor: Colors.transparent,
              appBar: new AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                title: new Text(
                  contentScreen.title,
                  style: new TextStyle(
                    fontFamily: 'bebas-neue',
                    fontSize: 25.0,
                  ),
                ),
                leading: new IconButton(
                    icon: new Icon(Icons.menu),
                    onPressed: () {
                      controller.toggle();
                    }),
              ),
              body: contentScreen.contentBuilder(context)),
        ),
        controller);
  }

  zoomAndSlideContent(Widget content, MenuController controller) {

    var slidePercent, scalePercent;
    switch (menuController.state) {
      case MenuState.closed:
        slidePercent = 0.0;
        scalePercent = 0.0;
        break;
      case MenuState.open:
        slidePercent = 1.0;
        scalePercent = 1.0;
        break;
      case MenuState.opening:
        slidePercent = slideOutCurve.transform(controller.percentOpen);
        scalePercent = scaleDownCurve.transform(controller.percentOpen);
        break;
      case MenuState.closing:
        slidePercent = slideInCurve.transform(controller.percentOpen);
        scalePercent = scaleUpCurve.transform(controller.percentOpen);
        break;
    }

    final slideAmount = 275.0 * slidePercent;
    final contentScale = 1.0 - (0.2 * scalePercent);
    final cornerRadius = 10.0 * controller.percentOpen;

    return new Transform(
      transform: new Matrix4.translationValues(slideAmount, 0, 0)
        ..scale(contentScale, contentScale),
      alignment: Alignment.centerLeft,
      child: new Container(
        decoration: new BoxDecoration(boxShadow: [
          new BoxShadow(
              color: const Color(0x44000000),
              offset: const Offset(0.0, 0.5),
              blurRadius: 20.0,
              spreadRadius: 10.0),
        ]),
        child: new ClipRRect(
            borderRadius: new BorderRadius.circular(cornerRadius),
            child: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new ZoomScaffoldWithController(
        child: new Stack(children: [
          widget.menuScreen,
          createContentDisplay(widget.contentScreen, menuController)
        ]),
        controller: menuController);
  }
}

class ZoomScaffoldWithController extends InheritedWidget {
  final MenuController controller;

  ZoomScaffoldWithController({
    Key key,
    @required Widget child,
    @required this.controller,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static ZoomScaffoldWithController of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(ZoomScaffoldWithController);
}

class MenuController extends ChangeNotifier {
  final TickerProvider vsync;
  final AnimationController _animationController;
  MenuState state = MenuState.closed;

  MenuController({
    this.vsync,
  }) : _animationController = new AnimationController(vsync: vsync) {
    _animationController
      ..duration = const Duration(milliseconds: 450)
      ..addListener(() {
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        switch (status) {
          case AnimationStatus.forward:
            state = MenuState.opening;
            break;
          case AnimationStatus.reverse:
            state = MenuState.closing;
            break;
          case AnimationStatus.completed:
            state = MenuState.open;
            break;
          case AnimationStatus.dismissed:
            state = MenuState.closed;
            break;
        }
        notifyListeners();
      });
  }

  get percentOpen {
    return _animationController.value;
  }

  open() {
    _animationController.forward();
  }

  close() {
    _animationController.reverse();
  }

  toggle() {
    if (state == MenuState.open) {
      this.close();
    } else if (state == MenuState.closed) {
      this.open();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

enum MenuState {
  closed,
  closing,
  open,
  opening,
}

class Screen {
  final String title;
  final DecorationImage background;
  final WidgetBuilder contentBuilder;

  Screen({
    this.title,
    this.background,
    this.contentBuilder,
  });
}
