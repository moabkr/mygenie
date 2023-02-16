import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OneTimeLottie extends StatefulWidget {
  final String asset;
  final String status;

  const OneTimeLottie(this.asset, this.status);

  @override
  _OneTimeLottieState createState() => _OneTimeLottieState();
}

class _OneTimeLottieState extends State<OneTimeLottie>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.forward().then((value) {
      setState(() {
        _controller.dispose();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.isAnimating
        ? Lottie.asset(
            widget.asset,
            controller: _controller,
          )
        : Container();
  }
}
