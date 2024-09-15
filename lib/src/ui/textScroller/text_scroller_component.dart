import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:provider/provider.dart';
import 'package:teleprompter/src/data/state/teleprompter_state.dart';
import 'package:teleprompter/src/shared/app_logger.dart';
import 'package:teleprompter/src/shared/my_snack_bar.dart';
import 'package:teleprompter/src/ui/textScroller/text_scroller_options_component.dart';
import 'package:teleprompter/src/ui/textScroller/text_scroller_oriented_component.dart';
import 'package:teleprompter/src/ui/timer/stopwatch_widget.dart';

class TextScrollerComponent extends StatefulWidget {
  final String title;
  final String text;
  final String savedToGallery;
  final String errorSavingToGallery;
  final Widget startRecordingButton;
  final Widget stopRecordingButton;
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
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    AppLogger().debug('TextScrollerComponent initialized');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  void _handleScrolling(TeleprompterState teleprompterState) {
    AppLogger().debug('_handleScrolling called. isScrolling: ${teleprompterState.isScrolling()}, isPaused: ${teleprompterState.isPaused()}');
    if (teleprompterState.isScrolling()) {
      _startScrolling(teleprompterState);
    } else if (teleprompterState.isPaused()) {
      _pauseScrolling();
    } else {
      _stopScrolling();
    }
  }

  void _startScrolling(TeleprompterState teleprompterState) {
    AppLogger().debug('_startScrolling called');
    if (!_scrollController.hasClients) {
      AppLogger().debug('ScrollController has no clients');
      return;
    }

    final double maxExtent = _scrollController.position.maxScrollExtent;
    final double distanceDifference = maxExtent - _scrollController.offset;
    final double durationDouble = distanceDifference / teleprompterState.getSpeedFactor();

    AppLogger().debug('Scroll animation parameters: maxExtent=$maxExtent, distanceDifference=$distanceDifference, duration=${durationDouble.toInt()} seconds');

    _animationController?.dispose();
    _animationController = AnimationController(
      duration: Duration(seconds: durationDouble.toInt()),
      vsync: this,
    );

    _animationController!.addListener(() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _animationController!.value * maxExtent,
        );
      }
    });

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        AppLogger().debug('Scroll animation completed');
        teleprompterState.completedScroll();
      }
    });

    _animationController!.forward();
    AppLogger().debug('Scroll animation started');
  }

  void _pauseScrolling() {
    AppLogger().debug('_pauseScrolling called');
    _animationController?.stop();
  }

  void _stopScrolling() {
    AppLogger().debug('_stopScrolling called');
    _animationController?.reset();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeleprompterState>(
      builder: (context, teleprompterState, child) {
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
              IconButton(
                onPressed: () async {
                  if (teleprompterState.isRecording()) {
                    final bool success = await teleprompterState.stopRecording();
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
                  } else {
                    teleprompterState.startRecording(teleprompterState);
                  }
                  teleprompterState.refresh();
                },
                icon: teleprompterState.isRecording()
                    ? widget.stopRecordingButton
                    : widget.startRecordingButton,
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
                },
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            shape: widget.floatingButtonShape,
            onPressed: () {
              AppLogger().debug('FloatingActionButton pressed');
              teleprompterState.toggleStartStop();
              _handleScrolling(teleprompterState);
              teleprompterState.refresh();
            },
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
