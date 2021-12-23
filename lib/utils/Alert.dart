import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

void showAlertDialog(String title,BackButtonBehavior backButtonBehavior,
    {VoidCallback? cancel,
    VoidCallback? confirm,
      VoidCallback? backgroundReturn}) {
  BotToast.showAnimationWidget(
      clickClose: false,
      allowClick: false,
      onlyOne: true,
      crossPage: true,
      backButtonBehavior: backButtonBehavior,
      wrapToastAnimation: (controller, cancel, child) => Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  cancel();
                  backgroundReturn?.call();
                },
                //The DecoratedBox here is very important,he will fill the entire parent component
                child: AnimatedBuilder(
                  builder: (_, child) => Opacity(
                    opacity: controller.value,
                    child: child,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black26),
                    child: SizedBox.expand(),
                  ),
                  animation: controller,
                ),
              ),
              CustomOffsetAnimation(
                controller: controller,
                child: child,
              )
            ],
          ),
      toastBuilder: (cancelFunc) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            title: Text(title),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  cancelFunc();
                  cancel?.call();
                },
                highlightColor: const Color(0x55FF8A80),
                splashColor: const Color(0x99FF8A80),
                child: const Text(
                  '关闭',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              FlatButton(
                onPressed: () {
                  cancelFunc();
                  confirm?.call();
                },
                child: const Text('确定'),
              ),
            ],
          ),
      animationDuration: Duration(milliseconds: 300));
}

class CustomOffsetAnimation extends StatefulWidget {
  final AnimationController ?controller;
  final Widget ?child;

  const CustomOffsetAnimation({Key? key, this.controller, this.child})
      : super(key: key);

  @override
  _CustomOffsetAnimationState createState() => _CustomOffsetAnimationState();
}

class _CustomOffsetAnimationState extends State<CustomOffsetAnimation> {
  late Tween<Offset> tweenOffset;
  late Tween<double> tweenScale;

  late Animation<double> animation;

  @override
  void initState() {
    tweenOffset = Tween<Offset>(
      begin: const Offset(0.0, 0.8),
      end: Offset.zero,
    );
    tweenScale = Tween<double>(begin: 0.3, end: 1.0);
    animation =
        CurvedAnimation(parent: widget.controller!, curve: Curves.decelerate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      child: widget.child,
      animation: widget.controller!,
      builder: (BuildContext context, Widget ?child) {
        return FractionalTranslation(
            translation: tweenOffset.evaluate(animation),
            child: ClipRect(
              child: Transform.scale(
                scale: tweenScale.evaluate(animation),
                child: Opacity(
                  child: child,
                  opacity: animation.value,
                ),
              ),
            ));
      },
    );
  }
}