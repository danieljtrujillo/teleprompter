import 'package:flutter/material.dart';
import 'package:teleprompter/src/data/state/recorder_state.dart';
import 'package:teleprompter/src/data/state/teleprompter_settings_state.dart';
import 'package:teleprompter/src/shared/app_logger.dart';
import 'package:teleprompter/src/ui/textScroller/options/teleprompter_color_picker_component.dart';

/// Provider to manage the state of the teleprompter
class TeleprompterState
    with ChangeNotifier, TeleprompterSettingsState, RecorderState {
  bool _scrolling = false; // Indicates if the teleprompter is scrolling
  bool _paused = false; // Indicates if the teleprompter is paused
  int _optionIndex = 0; // Currently selected option index
  double _scrollPosition = 0; // Current scroll position

  // Constructor initializes the teleprompter state
  TeleprompterState(BuildContext context, Color defaultTextColor) {
    prepareCamera().then((value) => refresh());
    loadSettings(context, defaultTextColor).then((value) => refresh());
  }

  // Returns true if the teleprompter is scrolling, false otherwise
  bool isScrolling() => _scrolling && !_paused;

  // Returns true if the teleprompter is paused, false otherwise
  bool isPaused() => _paused;

  // Sets scrolling to false when the teleprompter completes scrolling
  void completedScroll() {
    stopScroll();
  }

  // Stops scrolling if the teleprompter is currently scrolling
  void stopScroll() {
    _scrolling = false;
    _paused = false;
    refresh();
  }

  // Toggles scrolling state between start, pause, and stop
  void toggleStartStop() {
    if (_scrolling && !_paused) {
      _paused = true;
    } else if (_paused) {
      _paused = false;
    } else {
      _scrolling = true;
      _paused = false;
    }
    refresh();
  }

  // Notifies listeners of state changes and logs a debug message
  void refresh() {
    notifyListeners();
    AppLogger().debug('Teleprompter state refresh()');
  }

  // Increases the value for the given option index
  void increaseValueForIndex(int index) {
    setStepValueForIndex(index, getSteps()[index]!);
    refresh();
  }

  // Decreases the value for the given option index
  void decreaseValueForIndex(int index) {
    setStepValueForIndex(index, getSteps()[index]! * -1);
    refresh();
  }

  // Displays a color picker dialog when the option is clicked
  void hit(int index, BuildContext context) {
    showDialog<Widget>(
        context: context,
        builder: (
          BuildContext context,
        ) =>
            TeleprompterColorPickerComponent(this));
  }

  // Getter for the current option index
  int getOptionIndex() => _optionIndex;

  // Updates the current option index
  void updateOptionIndex(int index) => _optionIndex = index;

  // Getter for the current scroll position
  double getScrollPosition() => _scrollPosition;

  // Sets the current scroll position
  void setScrollPosition(double offset) => _scrollPosition = offset;
}
