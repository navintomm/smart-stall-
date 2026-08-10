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
      // Send normalized offset (-1 to 1)
      final maxOffset = widget.size / 2 - (widget.size * 0.25);
      widget.onDirectionChanged(Offset(
        _knobOffset.dx / maxOffset,
        _knobOffset.dy / maxOffset,
      ));
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final maxOffset = widget.size / 2 - (widget.size * 0.25);
    Offset newOffset = _knobOffset + details.delta;

    // Constrain to circle
    final distance = newOffset.distance;
    if (distance > maxOffset) {
      newOffset = Offset.fromDirection(newOffset.direction, maxOffset);
    }

    setState(() {
      _knobOffset = newOffset;
    });

    // Notify
    widget.onDirectionChanged(Offset(
      _knobOffset.dx / maxOffset,
      _knobOffset.dy / maxOffset,
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
    final knobSize = widget.size * 0.5;

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            // Inner shadow effect via multiple drop shadows (neu-morphic)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.05), width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center indicator / track
            Container(
              width: widget.size * 0.15,
              height: widget.size * 0.15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withOpacity(0.1), width: 2),
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
                  color: Colors.white,
                  gradient: const RadialGradient(
                    colors: [Colors.white, Color(0xFFF3F4F6)],
                    stops: [0.3, 1.0],
                    center: Alignment(-0.2, -0.2),
                    radius: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 15),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: knobSize * 0.6,
                    height: knobSize * 0.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
