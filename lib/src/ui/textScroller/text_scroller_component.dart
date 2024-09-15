import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:provider/provider.dart';
import 'package:teleprompter/src/data/state/teleprompter_state.dart';
import 'package:teleprompter/src/shared/app_logger.dart';
import 'package:teleprompter/src/shared/my_snack_bar.dart';
import 'package:teleprompter/src/ui/textScroller/text_scroller_options_component.dart';
import 'package:teleprompter/src/ui/textScroller/text_scroller_oriented_component.dart';
import 'package:teleprompter/src/ui/timer/stopwatch_widget.dart';

/// This class represents the TextScrollerComponent, a StatefulWidget that provides
/// functionality for displaying text and controlling its scrolling behavior.
class TextScrollerComponent extends StatefulWidget {
  /// The title of the widget, typically used as the app bar title.
  final String title;

  /// The text content to be displayed and scrolled.
  final String text;

  /// A message to be displayed when the recording is successfully saved to the gallery.
  final String savedToGallery;

  /// An error message to be displayed when there is an issue saving the recording to the gallery.
  final String errorSavingToGallery;

  /// Widget to be used as start recording
  final Widget startRecordingButton;

  /// Widget to be used as stop recording
  final Widget stopRecordingButton;

  /// An optional shape border for the floating action button.
  final ShapeBorder? floatingButtonShape;

  const TextScrollerComponent({
    required this.title,
    required this.text,
    required this.savedToGallery,
    required this.errorSavingToGallery,
    required this.startRecordingButton,
    required this.stopRecordingButton,
    this.floatingButtonShape,
    super.key,
  });

  @override
  _TextScrollerComponentState createState() => _TextScrollerComponentState();
}

class _TextScrollerComponentState extends State<TextScrollerComponent>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScrolling(TeleprompterState teleprompterState) {
    if (teleprompterState.isScrolling()) {
      final double maxExtent = _scrollController.position.maxScrollExtent;
      final double distanceDifference = maxExtent - _scrollController.offset;
      final double durationDouble =
          distanceDifference / teleprompterState.getSpeedFactor();

      _scrollController.animateTo(
        maxExtent,
        duration: Duration(seconds: durationDouble.toInt()),
        curve: Curves.linear,
      ).then((_) {
        if (mounted) {
          teleprompterState.completedScroll();
        }
      });
    } else if (teleprompterState.isPaused()) {
      _scrollController.jumpTo(_scrollController.offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeleprompterState>(
      builder: (context, teleprompterState, child) {
        _handleScrolling(teleprompterState);

        return Scaffold(
          appBar: AppBar(
            title: teleprompterState.isRecording()
                ? const StopwatchWidget()
                : FittedBox(
                    child: Text(
                      widget.title,
                      overflow: TextOverflow.fade,
                    ),
                  ),
            actions: [
              teleprompterState.isRecording()
                  ? IconButton(
                      onPressed: () async {
                        final bool success =
                            await teleprompterState.stopRecording();
                        teleprompterState.refresh();

                        if (success && mounted) {
                          MySnackBar.show(
                            context: context,
                            text: widget.savedToGallery,
                          );
                        } else if (mounted) {
                          MySnackBar.showError(
                            context: context,
                            text: widget.errorSavingToGallery,
                          );
                        }
                      },
                      icon: widget.stopRecordingButton,
                    )
                  : IconButton(
                      onPressed: () {
                        teleprompterState.startRecording(teleprompterState);
                        teleprompterState.refresh();
                      },
                      icon: widget.startRecordingButton,
                    )
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: NativeDeviceOrientationReader(
                  builder: (context) {
                    final orientation =
                        NativeDeviceOrientationReader.orientation(context);
                    AppLogger().debug('Received new orientation: $orientation');

                    return TextScrollerOrientedComponent(
                      _scrollController,
                      orientation,
                      text: widget.text,
                    );
                  },
                ),
              ),
              TextScrollerOptionsComponent(
                  index: teleprompterState.getOptionIndex(),
                  updateIndex: (int index) {
                    teleprompterState.updateOptionIndex(index);
                    teleprompterState.refresh();
                  })
            ],
          ),
          floatingActionButton: FloatingActionButton(
            shape: widget.floatingButtonShape,
            onPressed: teleprompterState.toggleStartStop,
            child: Icon(
              teleprompterState.isScrolling()
                  ? Icons.pause
                  : teleprompterState.isPaused()
                      ? Icons.play_arrow
                      : Icons.play_arrow,
            ),
          ),
        );
      },
    );
  }
}
