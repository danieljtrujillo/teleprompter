import 'dart:io';

import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:provider/provider.dart';
import 'package:teleprompter/src/data/state/teleprompter_state.dart';
import 'package:teleprompter/src/ui/textScroller/expandable_component.dart';

/// Component that shows the text to scroll
class TextScrollerOrientedComponent extends StatelessWidget {
  final ScrollController _scrollController;
  final NativeDeviceOrientation orientation;
  final String text;

  const TextScrollerOrientedComponent(
    this._scrollController,
    this.orientation, {
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TeleprompterState>(
      builder: (context, teleprompterState, child) {
        final MediaQueryData mediaQueryData = MediaQuery.of(context);

        final double verticalPadding =
            mediaQueryData.padding.top + mediaQueryData.padding.bottom;
        final double height = mediaQueryData.size.height - verticalPadding;
        final double width = mediaQueryData.size.width;

        double remainingSpace = 245;

        if (Platform.isAndroid) {
          remainingSpace = 175;
        }

        return ExpandableComponent(
          height: height,
          maxHeight: height,
          remainingSpace: remainingSpace,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollEndNotification) {
                teleprompterState.completedScroll();
              }
              return true;
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: teleprompterState.isScrolling()
                  ? const NeverScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: width,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: teleprompterState.getTextColor(),
                          fontSize: teleprompterState.getTextSize(),
                        ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
