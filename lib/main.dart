import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

void main() {
  runApp( 
    
    const MaterialApp(
    title: 'Mechanical Binary Counter',
    home: MechanicalBinaryCounter(),
  ));
}

class MechanicalBinaryCounter extends StatefulWidget {
  const MechanicalBinaryCounter({super.key});

  @override
  MechanicalBinaryCounterState createState() => MechanicalBinaryCounterState();
}

class MechanicalBinaryCounterState extends State<MechanicalBinaryCounter> {
  int _value = 0;
  final int _bitCount = 8; // To show 8 bits
  double _dragStartY = 0;
  final double _dragThreshold = 30; // Sensitivity of the drag to change value

  void _incrementValue() {
    setState(() {
      _value = (_value + 1) % (1 << _bitCount); // Increment and wrap around at 256 (2^8)
    });
  }

  void _decrementValue() {
    setState(() {
      _value = (_value - 1) % (1 << _bitCount); // Decrement and wrap around at 256 (2^8)
      if (_value < 0) _value += (1 << _bitCount);
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if ((details.localPosition.dy - _dragStartY).abs() > _dragThreshold) {
      if (details.localPosition.dy > _dragStartY) {
        _incrementValue();
      } else {
        _decrementValue();
      }
      _dragStartY = details.localPosition.dy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[300],
      body: Center(
        child: GestureDetector(
          onVerticalDragStart: (details) {
            _dragStartY = details.localPosition.dy;
          },
          onVerticalDragUpdate: _onVerticalDragUpdate,
          child: Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.brown[400],
                    border: Border.all(
                        color: Colors.brown, width: 3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: BinaryFlipColumn(
                    value: _value,
                    bitCount: _bitCount,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BinaryFlipColumn extends StatelessWidget {
  final int value;
  final int bitCount;

  const BinaryFlipColumn({
    super.key,
    required this.value,
    required this.bitCount,
  });

  List<int> _getBinaryDigits(int value, int bitCount) {
    final binaryString = value.toRadixString(2).padLeft(bitCount, '0');
    return binaryString.split('').map((e) => int.parse(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final binaryDigits = _getBinaryDigits(value, bitCount);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: binaryDigits.map((digit) => FlipCard(value: digit)).toList(),
    );
  }
}

class FlipCard extends StatefulWidget {
  final int value;

  const FlipCard({
    super.key,
    required this.value,
  });

  @override
  FlipCardState createState() => FlipCardState();
}

class FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _previousValue;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final isFirstHalf = _animation.value < 0.5;
        final displayValue = isFirstHalf ? _previousValue : widget.value;
        final transformValue = isFirstHalf ? _animation.value * math.pi : (1 - _animation.value) * math.pi;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(transformValue),
          alignment: Alignment.center,
          child: Container(
            width: 30,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: displayValue == 1 ? Colors.brown[700] : Colors.brown[500],
              border: Border.all(color: Colors.brown[800]!, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '$displayValue',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
