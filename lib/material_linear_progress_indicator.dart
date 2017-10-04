import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class MaterialLinearProgressIndicator extends ProgressIndicator {
  const MaterialLinearProgressIndicator({
    Key key,
    double value,
  }) : super(key: key, value: value);

  @override
  _MaterialLinearProgressIndicatorState createState() =>
      new _MaterialLinearProgressIndicatorState();
}

class _MaterialLinearProgressIndicatorState
    extends State<MaterialLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _controller;
  Color _backgroundColor;
  Color _foregroundColor;
  double _previous = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _animation =
    new CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn)..addListener(() {
//      print(_animation.value);
      if (_previous > _animation.value) {
        _backgroundColor = _foregroundColor;
        _foregroundColor = _colorList.first;
        _colorList.removeAt(0);
        _colorList.add(_foregroundColor);
      }
      _previous = _animation.value;
    });
    _backgroundColor = Colors.green;
    _foregroundColor = Colors.yellow;
    if (widget.value == null)
      _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);

    if (widget.value != null)
      return _buildIndicator(context, _animation.value, textDirection);

    return new AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget child) {
        return _buildIndicator(context, _animation.value, textDirection);
      },
    );
  }

  @override
  void didUpdateWidget(MaterialLinearProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    }
    else if (widget.value != null && _controller.isAnimating)
      _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _colorList = [Colors.green, Colors.yellow, Colors.red, Colors.blue];

  Widget _buildIndicator(BuildContext context, double animationValue,
      TextDirection textDirection) {
    return new Container(
      constraints: const BoxConstraints.tightFor(
        width: double.INFINITY,
        height: 6.0,
      ),
      child: new CustomPaint(
        painter: new _MaterialLinearProgressIndicatorPainter(
          backgroundColor: _backgroundColor,
          valueColor: _foregroundColor,
          value: _animation.value,
          // may be null
          animationValue: animationValue,
          // ignored if widget.value is not null
          textDirection: textDirection,
        ),
      ),
    );
  }
}

class _MaterialLinearProgressIndicatorPainter extends CustomPainter {
  const _MaterialLinearProgressIndicatorPainter({
    this.backgroundColor,
    this.valueColor,
    this.value,
    this.animationValue,
    @required this.textDirection,
  }) : assert(textDirection != null);

  final Color backgroundColor;
  final Color valueColor;
  final double value;
  final double animationValue;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = new Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);

    paint.color = valueColor;
    if (value != null) {
      final double width = value.clamp(0.0, 1.0) * size.width;

      double left;
      switch (textDirection) {
        case TextDirection.rtl:
          left = size.width - width;
          break;
        case TextDirection.ltr:
          left = 0.0;
          break;
      }

      canvas.drawRect(new Offset(left, 0.0) & new Size(width, size.height), paint);
    } else {
      final double startX = size.width * (1.5 * animationValue - 0.5);
      final double endX = startX + 0.5 * size.width;
      final double x = startX.clamp(0.0, size.width);
      final double width = endX.clamp(0.0, size.width) - x;

      double left;
      switch (textDirection) {
        case TextDirection.rtl:
          left = size.width - width - x;
          break;
        case TextDirection.ltr:
          left = x;
          break;
      }

      canvas.drawRect(new Offset(left, 0.0) & new Size(width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_MaterialLinearProgressIndicatorPainter oldPainter) {
    return oldPainter.backgroundColor != backgroundColor
        || oldPainter.valueColor != valueColor
        || oldPainter.value != value
        || oldPainter.animationValue != animationValue
        || oldPainter.textDirection != textDirection;
  }
}
