import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'dart:math' as math;

final class ToastHolderWidget extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const ToastHolderWidget({
    required this.item,
    required this.animation,
    required this.alignment,
    required this.transformerBuilder,
  });

  final ToastificationItem item;

  final Animation<double> animation;
  final AlignmentGeometry alignment;

  final ToastificationAnimationBuilder transformerBuilder;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(item.id),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyLarge ??
            ThemeData.light().textTheme.bodyLarge!,
        child: _AnimationTransformer(
          animation: animation,
          alignment: alignment,
          transformerBuilder: transformerBuilder,
          child: item.builder(context, item),
        ),
      ),
    );
  }
}

class _AnimationTransformer extends StatefulWidget {
  const _AnimationTransformer({
    required this.animation,
    required this.alignment,
    required this.transformerBuilder,
    required this.child,
  });

  final Animation<double> animation;
  final AlignmentGeometry alignment;
  final ToastificationAnimationBuilder transformerBuilder;
  final Widget child;

  @override
  State<_AnimationTransformer> createState() => _AnimationTransformerState();
}

class _AnimationTransformerState extends State<_AnimationTransformer> {
  late final CurvedAnimation _slideInCurvedAnimation;
  late final Animation<double> _slideInAnimation;
  late final CurvedAnimation _targetCurvedAnimation;
  late final Animation<double> _targetAnimation;

  @override
  void initState() {
    super.initState();
    widget.animation.addListener(_handleChange);

    _slideInCurvedAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: const Interval(
        0,
        0.6,
        curve: Curves.easeInOut,
      ),
    );

    _slideInAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_slideInCurvedAnimation);

    _targetCurvedAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: const Interval(
        0.3,
        1,
        curve: Curves.easeInOut,
      ),
    );

    _targetAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_targetCurvedAnimation);
  }

  @override
  void didUpdateWidget(_AnimationTransformer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      oldWidget.animation.removeListener(_handleChange);
      widget.animation.addListener(_handleChange);
    }
  }

  @override
  void dispose() {
    widget.animation.removeListener(_handleChange);
    _slideInCurvedAnimation.dispose();
    _targetCurvedAnimation.dispose();
    super.dispose();
  }

  void _handleChange() {
    if (!mounted) {
      return;
    }
    setState(() {
      // The animation's state is our build state, and it changed already.
    });
  }

  @override
  Widget build(BuildContext context) {
    const AlignmentDirectional axisAlign = AlignmentDirectional(-1.0, 0);

    final alignment = widget.alignment.resolve(Directionality.of(context));

    return Align(
      alignment: axisAlign,
      heightFactor: math.max(_slideInAnimation.value, 0.0),
      child: widget.transformerBuilder(context, _targetAnimation, alignment, widget.child),
    );
  }
}
