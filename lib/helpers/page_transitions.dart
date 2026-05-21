import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final SlideDirection direction;

  SmoothPageRoute({
    required this.child,
    this.direction = SlideDirection.rightToLeft,
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final curvedAnimation = CurvedAnimation(
             parent: animation,
             curve: Curves.easeOutCubic,
             reverseCurve: Curves.easeInCubic,
           );

           switch (direction) {
             case SlideDirection.rightToLeft:
               final slideIn = Tween<Offset>(
                 begin: const Offset(1.0, 0.0),
                 end: Offset.zero,
               ).animate(curvedAnimation);

               final slideOut =
                   Tween<Offset>(
                     begin: Offset.zero,
                     end: const Offset(AppTheme.parallaxSlideOffset, 0.0),
                   ).animate(
                     CurvedAnimation(
                       parent: secondaryAnimation,
                       curve: Curves.easeOutCubic,
                       reverseCurve: Curves.easeInCubic,
                     ),
                   );

               return SlideTransition(
                 position: slideIn,
                 child: SlideTransition(position: slideOut, child: child),
               );

             case SlideDirection.bottomToTop:
               final slideIn = Tween<Offset>(
                 begin: const Offset(0.0, 1.0),
                 end: Offset.zero,
               ).animate(curvedAnimation);

               final fade = Tween<double>(
                 begin: 0.0,
                 end: 1.0,
               ).animate(curvedAnimation);

               return SlideTransition(
                 position: slideIn,
                 child: FadeTransition(opacity: fade, child: child),
               );

             case SlideDirection.fadeScale:
               final scale = Tween<double>(
                 begin: AppTheme.scaleRouteTransition,
                 end: 1.0,
               ).animate(curvedAnimation);

               final fade = Tween<double>(
                 begin: 0.0,
                 end: 1.0,
               ).animate(curvedAnimation);

               return FadeTransition(
                 opacity: fade,
                 child: ScaleTransition(scale: scale, child: child),
               );
           }
         },
         transitionDuration: AppTheme.transitionDuration,
         reverseTransitionDuration: AppTheme.reverseTransitionDuration,
       );
}

enum SlideDirection { rightToLeft, bottomToTop, fadeScale }
