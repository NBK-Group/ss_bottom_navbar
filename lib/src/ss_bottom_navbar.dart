library ss_bottom_navbar;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ss_bottom_navbar/src/helper/empty_item.dart';
import 'package:ss_bottom_navbar/src/service.dart';
import 'package:ss_bottom_navbar/src/views/nav_item.dart';
import 'package:ss_bottom_navbar/src/views/slide_box.dart';

class SSBottomNav extends StatefulWidget {
  final List<SSBottomNavItem> items;
  final SSBottomBarState state;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? color;
  final Color? selectedColor;
  final Color? unselectedColor;
  final List<BoxShadow>? shadow;
  final bool visible;
  final Widget? bottomSheetWidget;
  final int showBottomSheetAt;
  final bool bottomSheetHistory;
  final int? selected;
  final Duration? duration;

//  final bool isWidthFixed;

  const SSBottomNav({
    required this.items,
    required this.state,
    this.iconSize,
    this.backgroundColor,
    this.color,
    this.selectedColor,
    this.unselectedColor,
    this.shadow,
    this.bottomSheetWidget,
    this.showBottomSheetAt = 0,
    this.selected,
    this.duration,
    this.visible = true,
    this.bottomSheetHistory = true,
//      this.isWidthFixed = false
  });

  @override
  _SSBottomNavState createState() => _SSBottomNavState();
}

class _SSBottomNavState extends State<SSBottomNav> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: widget.state,
        child: _App(
            items: widget.items,
            iconSize: widget.iconSize,
            backgroundColor: widget.backgroundColor,
            color: widget.color,
            selectedColor: widget.selectedColor,
            unselectedColor: widget.unselectedColor,
            shadow: widget.shadow,
            selected: widget.selected,
            bottomSheetWidget: widget.bottomSheetWidget,
            showBottomSheetAt: widget.showBottomSheetAt,
            visible: widget.visible,
            bottomSheetHistory: widget.bottomSheetHistory,
            duration: widget.duration));
  }
}

class _App extends StatelessWidget {
  final List<SSBottomNavItem> items;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? color;
  final Color? selectedColor;
  final Color? unselectedColor;
  final List<BoxShadow>? shadow;
  final bool? visible;
  final Widget? bottomSheetWidget;
  final int? showBottomSheetAt;
  final Duration? duration;
  final bool? bottomSheetHistory;
  final int? selected;

  const _App({
    required this.items,
    this.iconSize,
    this.backgroundColor,
    this.color,
    this.selectedColor,
    this.unselectedColor,
    this.shadow,
    this.bottomSheetWidget,
    this.showBottomSheetAt,
    this.duration,
    this.selected,
    this.visible,
    this.bottomSheetHistory,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).padding;

    return Container(
        height: visible! ? kBottomNavigationBarHeight + size.bottom : 0,
        child: BottomNavBar(
            items: items,
            iconSize: iconSize,
            backgroundColor: backgroundColor,
            color: color,
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            shadow: shadow,
            selected: selected,
            isWidthFixed: false,
            bottomSheetWidget: bottomSheetWidget,
            showBottomSheetAt: showBottomSheetAt,
            visible: visible,
            bottomSheetHistory: bottomSheetHistory,
            duration: duration));
  }
}

class BottomNavBar extends StatefulWidget {
  final List<SSBottomNavItem> items;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? color;
  final Color? selectedColor;
  final Color? unselectedColor;
  final List<BoxShadow>? shadow;
  final int? selected;
  final bool? isWidthFixed;
  final Duration? duration;
  final bool? visible;
  final Widget? bottomSheetWidget;
  final int? showBottomSheetAt;
  final bool? bottomSheetHistory;

  const BottomNavBar(
      {required this.items,
      this.iconSize,
      this.backgroundColor,
      this.color,
      this.selectedColor,
      this.unselectedColor,
      this.shadow,
      this.selected,
      this.isWidthFixed,
      this.visible,
      this.bottomSheetWidget,
      this.showBottomSheetAt,
      this.bottomSheetHistory,
      this.duration});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late SSBottomBarState _service;
  bool _isInit = false;
  int _tempIndex = 0;
  bool _didUpdateWidget = false;
  late bool _isDismissedByAnimation;

  Future<void> _onPressed(Offset offset) async {
    _isDismissedByAnimation = true;

    for (final pos in _service.positions) {
      final index = _service.positions.indexOf(pos);
      final rect1 = {'x': pos!.dx, 'y': pos.dy, 'width': _service.sizes[index]!.dx, 'height': _service.sizes[index]!.dy};
      final rect2 = {'x': offset.dx, 'y': offset.dy, 'width': 1, 'height': 1};

      if (rect1['x']! < rect2['x']! + rect2['width']! &&
          rect1['x']! + rect1['width']! > rect2['x']! &&
          rect1['y']! < rect2['y']! + rect2['height']! &&
          rect1['y']! + rect1['height']! > rect2['y']!) {
        Navigator.maybePop(context);
        _service.clickedIndex = index;

        final condition = index == widget.showBottomSheetAt && widget.bottomSheetHistory!;

        _service.setSelected(condition ? _tempIndex : index);
        _isDismissedByAnimation = false;
        if (condition) _service.clickedIndex = _tempIndex;
      }
    }
  }

  void _dismissedByAnimation(bool condition) {
    if (condition && _isDismissedByAnimation) {
      if (!widget.bottomSheetHistory!) return;

      _service.setSelected(_tempIndex);
      _service.clickedIndex = _tempIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    _service = Provider.of<SSBottomBarState>(context, listen: false);
    final size = MediaQuery.of(context).padding;

    if (_service.items.isEmpty) {
      _service.init(widget.items,
          settings: SSBottomNavBarSettings(
              items: widget.items,
              iconSize: widget.iconSize,
              backgroundColor: widget.backgroundColor,
              color: widget.color,
              selectedColor: widget.selectedColor,
              unselectedColor: widget.unselectedColor,
              shadow: widget.shadow,
              isWidthFixed: widget.isWidthFixed,
              visible: widget.visible,
              duration: widget.duration));

      if (!_isInit) {
        WidgetsBinding.instance!.addPostFrameCallback((_) async {
          await Future<void>.delayed(Duration(milliseconds: 50));

          _service.setSelected(0);
          _isInit = true;
        });
      }
    }

    if (_didUpdateWidget) {
      _service.setSelected(widget.selected!, didUpdateWidget: true);
      _didUpdateWidget = false;
    }

    return Visibility(
      key: ValueKey(1),
      visible: widget.visible!,
      maintainState: true,
      maintainAnimation: true,
      child: Material(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(bottom: size.bottom),
          child: Container(
            height: kBottomNavigationBarHeight,
            child: Stack(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: _service.items.map((e) => EmptyItem(e)).toList()),
                Container(
                  color: widget.backgroundColor ?? Colors.white,
                ),
                SlideBox(),
                Container(
                  alignment: Alignment.center,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _service.items
                          .map((e) => NavItem(
                                e,
                                onTab: () {
                                  final index = _service.items.indexOf(e);

                                  if (index == widget.showBottomSheetAt) {
                                    _service.clickedIndex = index;
                                    _service.setSelected(index);

                                    SSBottomSheet.show(
                                        context: context,
                                        child: widget.bottomSheetWidget,
                                        onPressed: _onPressed,
                                        dismissedByAnimation: _dismissedByAnimation);
                                  } else {
                                    _tempIndex = index;

                                    _service.clickedIndex = index;
                                    _service.setSelected(index);
                                  }
                                },
                              ))
                          .toList()),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SSBottomNavItem {
  final String text;
  final TextStyle? textStyle;
  final IconData iconData;
  final double iconSize;
  final bool isIconOnly;

  SSBottomNavItem({required this.text, this.textStyle, required this.iconData, this.iconSize = 16, this.isIconOnly = false});
}

class SSBottomSheet extends StatefulWidget {
  final Color? backgroundColor;
  final Widget? child;
  final ValueChanged<Offset>? onPressed;
  final double? bottomMargin;
  final ValueChanged<bool>? dismissedByAnimation;

  const SSBottomSheet({Key? key, this.backgroundColor, this.child, this.onPressed, this.bottomMargin, this.dismissedByAnimation}) : super(key: key);

  @override
  _SSBottomSheetState createState() => _SSBottomSheetState();

  static void show({
    required BuildContext context,
    required Widget? child,
    Color backgroundColor = const Color(0xb3212121),
    double? bottomMargin,
    ValueChanged<bool>? dismissedByAnimation,
    ValueChanged<Offset>? onPressed,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) {
          return SSBottomSheet(
            backgroundColor: backgroundColor,
            onPressed: onPressed,
            bottomMargin: bottomMargin,
            dismissedByAnimation: dismissedByAnimation,
            child: child,
          );
        },
        opaque: false,
      ),
    );
  }
}

class _SSBottomSheetState extends State<SSBottomSheet> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  final GlobalKey _childKey = GlobalKey();

  double get _childHeight {
    final renderBox = _childKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  bool get _dismissUnderway => _animationController.status == AnimationStatus.reverse;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _animation = Tween<double>(begin: 1, end: 0).animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _pop();
        widget.dismissedByAnimation!.call(true);
      }
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _pop() {
    Navigator.pop(context);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_dismissUnderway) return;

    final change = details.primaryDelta! / _childHeight;
    _animationController.value -= change;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dismissUnderway) return;

    if (details.velocity.pixelsPerSecond.dy < 0) return;

    if (details.velocity.pixelsPerSecond.dy > 700) {
      final double flingVelocity = -details.velocity.pixelsPerSecond.dy / _childHeight;
      if (_animationController.value > 0.0) {
        _animationController.fling(velocity: flingVelocity);
      }
    } else if (_animationController.value < 0.5) {
      if (_animationController.value > 0.0) {
        _animationController.fling(velocity: -1.0);
      }
    } else {
      _animationController.reverse();
    }
  }

  void onTapDown(BuildContext context, TapDownDetails details) {
    if (_dismissUnderway) return;

    final box = context.findRenderObject() as RenderBox;
    final localOffset = box.globalToLocal(details.globalPosition);

    widget.onPressed!.call(Offset(localOffset.dx, localOffset.dy));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final bottomBarHeight = widget.bottomMargin ?? kBottomNavigationBarHeight + media.padding.bottom;

    return WillPopScope(
        onWillPop: onBackPressed,
        child: GestureDetector(
          onVerticalDragUpdate: _handleDragUpdate,
          onVerticalDragEnd: _handleDragEnd,
          onTapDown: (TapDownDetails details) => onTapDown(context, details),
          excludeFromSemantics: true,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              color: widget.backgroundColor,
              margin: EdgeInsets.only(bottom: bottomBarHeight),
              child: Column(
                key: _childKey,
                children: <Widget>[
                  Spacer(),
                  ClipRect(
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, _) {
                            return Transform(
                              transform: Matrix4.translationValues(0.0, width * _animation.value, 0.0),
                              child: Container(
                                width: width,
                                child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {}, child: widget.child),
                              ),
                            );
                          }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<bool> onBackPressed() async {
    _animationController.reverse();
    return false;
  }
}
