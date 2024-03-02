import 'package:flutter/cupertino.dart';

class Transitions {
  Transitions();

  /// Creates a slide transition to be used by Navigator.
  ///
  /// [destination]: Widget to navigate to after the animation finishes.
  /// [duration]: Duration of the transition animation in milliseconds.
  /// [dx]: The horizontal offset.
  /// [dy]: The vertical offset.
  PageRouteBuilder slide(Widget destination, int duration, double dx, double dy) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionDuration: Duration(milliseconds: duration),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(dx, dy),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

}