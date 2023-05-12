import 'package:flutter/material.dart';

class CardWithBackground extends StatelessWidget {
  const CardWithBackground({
    Key? key,
    required this.child,
    this.width,
    required this.image,
    this.height,
    this.shape,
  }) : super(key: key);

  final ShapeBorder? shape;
  final Widget child;
  final double? width;
  final double? height;
  final ImageProvider? image;

  // "https://placeimg.com/640/480/any"
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
            //set border radius more than 50% of height and width to make circle
          ),
      child: Container(
          decoration: image != null
              ? BoxDecoration(
                  image: DecorationImage(
                  image: image!,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ))
              : null,
          child: child),
    );
  }
}
