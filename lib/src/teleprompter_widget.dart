import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teleprompter/src/data/services/camera_service.dart';
import 'package:teleprompter/src/data/state/teleprompter_state.dart';
import 'package:teleprompter/src/ui/camera/teleprompter_camera.dart';
import 'package:teleprompter/src/ui/textScroller/text_scroller_component.dart';

/// Widget that shows the teleprompter
class TeleprompterWidget extends StatefulWidget {
  const TeleprompterWidget({
    required this.text,
    this.title = 'Script name',
    this.savedToGallery = 'Video recorded saved to your gallery',
    this.errorSavingToGallery = 'Error saving video to your gallery',
    this.defaultTextColor = const Color.fromARGB(255, 255, 255, 255),
    this.startRecordingButton =
        const Icon(Icons.fiber_manual_record_sharp, color: Colors.red),
    this.stopRecordingButton = const Icon(Icons.stop, color: Colors.red),
    this.floatingButtonShape,
    this.defaultOpacity = 0.9,
    super.key,
  });

  /// Title of the teleprompter script
  final String title;

  /// Text where the tele
  final String text;

  /// Message to show when the video is saved to the gallery
  final String savedToGallery;

  /// Message to show when the video is not saved to the gallery
  final String errorSavingToGallery;

  /// Color of the teleprompter text at the start
  final Color defaultTextColor;

  /// Start record button
  final Widget startRecordingButton;

  /// Stop record button
  final Widget stopRecordingButton;

  /// Shape of the floating button
  final ShapeBorder? floatingButtonShape;

  /// Default opacity of the teleprompter text
  final double defaultOpacity;

  @override
  _TeleprompterWidgetState createState() => _TeleprompterWidgetState();
}

class _TeleprompterWidgetState extends State<TeleprompterWidget> {
  final CameraService _cameraService = CameraService();
  bool _isCameraInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      print("Initializing camera...");
      await _cameraService.startCameras();
      await _cameraService.selectFrontCamera();
      setState(() {
        _isCameraInitialized = true;
      });
      print("Camera initialized successfully");
    } catch (e) {
      print("Error initializing camera: $e");
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  @override
  void dispose() {
    _cameraService.disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => TeleprompterState(
          context,
          widget.defaultTextColor,
        ),
        child: Consumer<TeleprompterState>(
          builder: (context, teleprompterState, child) {
            final CameraController? cameraController =
                CameraService().getCameraController();

            // Stack with a camera behind and text above:
            return Stack(
              children: [
                cameraController != null
                    ? TeleprompterCamera(cameraController)
                    : Container(), // This creates a transparent container,
                Opacity(
                  opacity: teleprompterState.getOpacity(),
                  child: TextScrollerComponent(
                    title: widget.title,
                    text: widget.text,
                    savedToGallery: widget.savedToGallery,
                    errorSavingToGallery: widget.errorSavingToGallery,
                    stopRecordingButton: widget.stopRecordingButton,
                    startRecordingButton: widget.startRecordingButton,
                    floatingButtonShape: widget.floatingButtonShape,
                  ),
                )
              ],
            );
          },
        ),
      );
}
