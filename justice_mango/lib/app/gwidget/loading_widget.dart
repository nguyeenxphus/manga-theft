import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 128.0, horizontal: 64),
      child: Center(
        child: SpinKitSquareCircle(
          color: Colors.pink,
        ),
      ),
    );
  }
}
