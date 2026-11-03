import 'package:flutter/material.dart';

import '../theme/neo_palette.dart';

class NeobrutalSurface extends StatefulWidget {
  const NeobrutalSurface({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
    this.borderWidth = 3,
    this.shadowOffset = const Offset(4, 4),
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(16),
    this.width,
    this.height,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double borderWidth;
  final Offset shadowOffset;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  @override
  State<NeobrutalSurface> createState() => _NeobrutalSurfaceState();
}

class _NeobrutalSurfaceState extends State<NeobrutalSurface> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final palette = NeoPalette.of(context);
    final background = widget.backgroundColor ?? palette.card;
    final border = widget.borderColor ?? palette.border;
    final shadow = widget.shadowColor ?? palette.shadow;
    final offset = widget.shadowOffset;
    final radius = BorderRadius.circular(widget.borderRadius);

    final foreground = AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(
        _pressed ? offset.dx : 0,
        _pressed ? offset.dy : 0,
        0,
      ),
      margin: EdgeInsets.only(right: offset.dx, bottom: offset.dy),
      padding: widget.padding,
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        border: Border.all(color: border, width: widget.borderWidth),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: widget.child,
      ),
    );

    final content = Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: <Widget>[
        Positioned.fill(
          child: Container(
            margin: EdgeInsets.only(left: offset.dx, top: offset.dy),
            decoration: BoxDecoration(color: shadow, borderRadius: radius),
          ),
        ),
        foreground,
      ],
    );

    if (!_enabled) return content;

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: content,
      ),
    );
  }
}

class NeobrutalContainer extends StatelessWidget {
  const NeobrutalContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 3,
    this.shadowOffset = const Offset(4, 4),
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final Offset shadowOffset;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return NeobrutalSurface(
      onTap: onTap,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      shadowOffset: shadowOffset,
      borderRadius: borderRadius,
      padding: padding,
      child: child,
    );
  }
}

class NeobrutalButton extends StatelessWidget {
  const NeobrutalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.loading = false,
    this.expand = true,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool loading;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = NeoPalette.of(context);
    final enabled = onPressed != null && !loading;
    final background = enabled
        ? (backgroundColor ?? palette.yellow)
        : palette.muted;
    final foreground = enabled
        ? (foregroundColor ?? Colors.black)
        : palette.textSecondary;

    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: foreground,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 20, color: foreground),
        if (loading || icon != null) const SizedBox(width: 10),
        Flexible(
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );

    return NeobrutalSurface(
      onTap: enabled ? onPressed : null,
      backgroundColor: background,
      borderColor: palette.border,
      shadowOffset: const Offset(5, 5),
      borderRadius: 8,
      width: expand ? double.infinity : null,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }
}

class NeobrutalIconButton extends StatelessWidget {
  const NeobrutalIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 46,
    this.iconSize = 22,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final palette = NeoPalette.of(context);
    final enabled = onPressed != null;
    final foreground = enabled
        ? (foregroundColor ?? Colors.black)
        : palette.textSecondary;

    final button = NeobrutalSurface(
      onTap: enabled ? onPressed : null,
      backgroundColor: enabled
          ? (backgroundColor ?? palette.card)
          : palette.muted,
      borderColor: palette.border,
      shadowOffset: const Offset(3, 3),
      borderRadius: 8,
      width: size,
      height: size,
      padding: EdgeInsets.zero,
      child: Icon(icon, size: iconSize, color: foreground),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
