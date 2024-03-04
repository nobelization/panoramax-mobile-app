import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constant.dart';

class Loader extends StatelessWidget {
  final bool shadowBackground;
  final Widget message;

  const Loader({
    super.key,
    this.shadowBackground = false,
    required this.message
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: this.shadowBackground ?
        Color.fromRGBO(0, 0, 0, 50) :
        Colors.transparent
      ,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.staggeredDotsWave(
            color: DEFAULT_COLOR,
            size: 50,
          ),
          message
        ],
      )
    );
  }
}