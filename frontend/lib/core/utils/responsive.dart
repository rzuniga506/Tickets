import 'package:flutter/material.dart';

/// Sistema de breakpoints para diseño responsivo web-first
/// Prioriza experiencia en desktop pero mantiene compatibilidad móvil
class Breakpoints {
  // Breakpoints estándar
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1536;

  // Helpers
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= largeDesktop;

  /// Retorna el número de columnas según el ancho de pantalla
  static int getColumns(BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
    int largeDesktop = 4,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.largeDesktop) return largeDesktop;
    if (width >= Breakpoints.desktop) return desktop;
    if (width >= Breakpoints.tablet) return tablet;
    return mobile;
  }

  /// Retorna el crossAxisCount para GridView
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= largeDesktop) return 6; // 6 columnas para pantallas muy grandes
    if (width >= desktop) return 4;      // 4 columnas para desktop
    if (width >= tablet) return 3;       // 3 columnas para tablet
    if (width >= mobile) return 2;       // 2 columnas para móvil grande
    return 1;                             // 1 columna para móvil pequeño
  }

  /// Retorna el crossAxisCount para quick actions
  static int getQuickActionColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktop) return 4;  // 4 columnas en desktop
    if (width >= tablet) return 3;   // 3 columnas en tablet
    return 2;                         // 2 columnas en móvil
  }

  /// Retorna padding horizontal adaptativo
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= largeDesktop) return 48;
    if (width >= desktop) return 32;
    if (width >= tablet) return 24;
    return 16;
  }

  /// Retorna el max width para formularios y contenido centrado
  static double getContentMaxWidth(BuildContext context) {
    return isDesktop(context) ? 600 : double.infinity;
  }

  /// Retorna el max width para modales y dialogs
  static double getDialogMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktop) return 500;
    return width * 0.9;
  }
}

/// Widget responsivo que adapta su layout según el tamaño de pantalla
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= Breakpoints.mobile) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Widget que centra contenido y aplica max-width
class CenteredContent extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const CenteredContent({
    super.key,
    required this.child,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? Breakpoints.getContentMaxWidth(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: child,
      ),
    );
  }
}

/// GridView responsivo que ajusta columnas automáticamente
class ResponsiveGrid extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double spacing;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = 16,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = Breakpoints.getGridColumns(context);

        return GridView.builder(
          padding: padding,
          physics: physics,
          shrinkWrap: shrinkWrap,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: 1.0,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

/// Lista o Grid según el tamaño de pantalla
class AdaptiveListGrid extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;

  const AdaptiveListGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // En desktop/tablet usar grid, en móvil usar lista
        if (constraints.maxWidth >= Breakpoints.tablet) {
          final columns = Breakpoints.getGridColumns(context);

          return GridView.builder(
            controller: controller,
            padding: padding,
            physics: physics,
            shrinkWrap: shrinkWrap,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: (constraints.maxWidth.isFinite && constraints.maxWidth > 0)
                  ? (constraints.maxWidth >= Breakpoints.desktop ? 1.2 : 1.0)
                  : 1.0,
            ),
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          );
        } else {
          // Lista vertical para móvil
          return ListView.builder(
            controller: controller,
            padding: padding,
            physics: physics,
            shrinkWrap: shrinkWrap,
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          );
        }
      },
    );
  }
}

/// Wrap responsivo que ajusta spacing según pantalla
class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final double? runSpacing;
  final WrapAlignment alignment;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.spacing,
    this.runSpacing,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing ?? (Breakpoints.isDesktop(context) ? 16.0 : 8.0);

    return Wrap(
      spacing: effectiveSpacing,
      runSpacing: runSpacing ?? effectiveSpacing,
      alignment: alignment,
      children: children,
    );
  }
}
