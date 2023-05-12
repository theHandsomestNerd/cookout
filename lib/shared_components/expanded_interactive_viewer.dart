import 'package:flutter/material.dart';

import '../wrappers/card_with_background.dart';

class ExpandedInteractiveViewer extends StatefulWidget {
  const ExpandedInteractiveViewer({Key? key, required this.image}) : super(key: key);
  final ImageProvider image;

  @override
  State<ExpandedInteractiveViewer> createState() => _ExpandedInteractiveViewerState();
}

class _ExpandedInteractiveViewerState extends State<ExpandedInteractiveViewer> {
  TransformationController transformationController =
  TransformationController();

  double scale = 1;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            child: GestureDetector(
              onDoubleTap: () {
                // final double scale = .5;
                setState(() {
                  if (scale == 1) {
                    scale = 1.1;
                  } else {
                    scale = 1;
                  }
                });
                final zoomed =
                Matrix4.identity().scaled(scale, scale);

                final value = zoomed;
                transformationController.value = value;
              },
              child: scale != 1
                  ? ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 350),
                child: InteractiveViewer(
                  clipBehavior: Clip.none,
                  transformationController:
                  transformationController,
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: .3,
                  maxScale: 2.5,
                  child: Center(
                    child: Flex(
                      direction: Axis.vertical,
                      children: [
                        Expanded(
                          child: Image(
                              image: widget.image),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : CardWithBackground(
                image: widget.image,
                child: Container(),
              ),
            ),
          ),
          SizedBox(
            height: 32,
          )
        ],
      ),
    );
  }
}
