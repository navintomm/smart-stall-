import 'package:flutter/material.dart';

class JoystickController extends StatefulWidget {
  final double size;
  final void Function(Offset offset) onDirectionChanged;

  const JoystickController({
    super.key,
    this.size = 200.0,
    required this.onDirectionChanged,
  });

  @override
  State<JoystickController> createState() => _JoystickControllerState();
}

class _JoystickControllerState extends State<JoystickController>
    with SingleTickerProviderStateMixin {
  Offset _knobOffset = Offset.zero;
  late AnimationController _springController;
  late Animation<Offset> _springAnimation;

  double get _maxOffset {
    final baseSize = widget.size * 0.8;
    return (baseSize * 0.425) - (baseSize * 0.25);
  }

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _springController.addListener(() {
      setState(() {
        _knobOffset = _springAnimation.value;
      });
      widget.onDirectionChanged(Offset(
        _knobOffset.dx / _maxOffset,
        _knobOffset.dy / _maxOffset,
      ));
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    Offset newOffset = _knobOffset + details.delta;

    // Lock motion strictly to 4 directions (orthogonal axes)
    if (newOffset.dx.abs() > newOffset.dy.abs()) {
      newOffset = Offset(newOffset.dx, 0);
    } else {
      newOffset = Offset(0, newOffset.dy);
    }

    // Constrain to circle (which is now effectively just a line on X or Y axis)
    final distance = newOffset.distance;
    if (distance > _maxOffset) {
      // Because one coordinate is 0, we can just use sign and maxOffset
      if (newOffset.dx != 0) {
        newOffset = Offset(newOffset.dx.sign * _maxOffset, 0);
      } else {
        newOffset = Offset(0, newOffset.dy.sign * _maxOffset);
      }
    }

    setState(() {
      _knobOffset = newOffset;
    });

    widget.onDirectionChanged(Offset(
      _knobOffset.dx / _maxOffset,
      _knobOffset.dy / _maxOffset,
    ));
  }

  void _onPanEnd(DragEndDetails details) {
    // Spring back to center
    _springAnimation = Tween<Offset>(
      begin: _knobOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _springController,
      curve: Curves.elasticOut,
    ));
    _springController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final baseSize = widget.size * 0.8;
    final knobSize = baseSize * 0.5;

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Directional Arrows
            const Positioned(top: 0, child: Icon(Icons.keyboard_arrow_up_rounded, color: Colors.orangeAccent, size: 28)),
            Positioned(bottom: 0, child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400, size: 28)),
            Positioned(left: 0, child: Icon(Icons.keyboard_arrow_left_rounded, color: Colors.grey.shade400, size: 28)),
            Positioned(right: 0, child: Icon(Icons.keyboard_arrow_right_rounded, color: Colors.grey.shade400, size: 28)),
            
            // Outer Bevel (Light grey with soft shadow)
            Container(
              width: baseSize,
              height: baseSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8ECEF),
                boxShadow: [
                  BoxShadow(color: Colors.white, blurRadius: 10, offset: Offset(-5, -5)),
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(5, 5)),
                ],
              ),
            ),
            
            // Dark Metallic Ring (Outer)
            Container(
              width: baseSize * 0.85,
              height: baseSize * 0.85,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3B4048), Color(0xFF5A6372)],
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(2, 2)),
                ],
              ),
            ),

            // Inner Track (Lighter metallic)
            Container(
              width: baseSize * 0.65,
              height: baseSize * 0.65,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B93A0), Color(0xFF4A515D)],
                ),
              ),
            ),
            
            // The moving Knob
            Transform.translate(
              offset: _knobOffset,
              child: Container(
                width: knobSize,
                height: knobSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF0F3F6),
                  border: Border.all(color: Colors.white, width: 2), // metallic rim
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 8)),
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4)),
                  ],
                  gradient: const RadialGradient(
                    colors: [Colors.white, Color(0xFFDDE3E9)],
                    stops: [0.3, 1.0],
                    center: Alignment(-0.3, -0.3),
                    radius: 0.8,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Inner raised circle
                    Container(
                      width: knobSize * 0.7,
                      height: knobSize * 0.7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF8FAFC), Color(0xFFD6DCE2)],
                        ),
                      ),
                    ),
                    // 4 Tactile Dots
                    Positioned(top: knobSize * 0.12, child: const _TactileDot()),
                    Positioned(bottom: knobSize * 0.12, child: const _TactileDot()),
                    Positioned(left: knobSize * 0.12, child: const _TactileDot()),
                    Positioned(right: knobSize * 0.12, child: const _TactileDot()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TactileDot extends StatelessWidget {
  const _TactileDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE8ECEF),
        boxShadow: [
          BoxShadow(color: Colors.white, offset: Offset(-1, -1), blurRadius: 1),
          BoxShadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 1),
        ],
      ),
    );
  }
}
