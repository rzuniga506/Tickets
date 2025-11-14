import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Widget para mostrar un badge de contador de notificaciones
class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final Color? badgeColor;
  final Color? textColor;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.child,
    this.badgeColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor ?? AppTheme.errorColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            child: Text(
              count > 99 ? '99+' : count.toString(),
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar un punto indicador simple
class NotificationDot extends StatelessWidget {
  final Widget child;
  final bool show;
  final Color? dotColor;

  const NotificationDot({
    super.key,
    required this.child,
    required this.show,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor ?? AppTheme.errorColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
