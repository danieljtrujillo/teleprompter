import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:teleprompter/src/shared/app_logger.dart';

List<CameraDescription> cameras = [];

class CameraDetector {
  bool _cameraReady = false;
  CameraController? cameraController;

  Future<void> startCameras() async {
    try {
      AppLogger().debug('Starting camera initialization');
      cameras = await availableCameras();
      AppLogger().debug('Available cameras: ${cameras.length}');
    } catch (e) {
      AppLogger().error('Failed to get available cameras: $e');
    }
  }

  bool isCameraReady() => _cameraReady;

  CameraController? getCameraController() => cameraController;

  Future<void> selectFrontCamera() async {
    AppLogger().debug('Selecting front camera');
    for (final CameraDescription cameraDescription in cameras) {
      if (cameraDescription.lensDirection == CameraLensDirection.front) {
        await onNewCameraSelected(cameraDescription);
        _cameraReady = true;
        AppLogger().debug('Front camera selected and initialized');
        break;
      }
    }
    if (!_cameraReady) {
      AppLogger().error('No front camera found');
    }
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    AppLogger().debug('Initializing new camera: ${cameraDescription.name}');
    if (cameraController != null) {
      await cameraController!.dispose();
      AppLogger().debug('Previous camera controller disposed');
    }

    cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
      enableAudio: true,
    );

    AppLogger().debug('New CameraController created');

    // Force portrait orientation for 9:16 aspect ratio
    cameraController!.lockCaptureOrientation(DeviceOrientation.portraitUp);
    AppLogger().debug('Camera orientation locked to portrait');

    // If the controller is updated then update the UI.
    cameraController!.addListener(() {
      AppLogger().debug('Camera event: ${cameraController!.value}');
      if (cameraController!.value.hasError) {
        AppLogger().error('Camera error ${cameraController!.value.errorDescription}');
      }
    });

    try {
      AppLogger().debug('Initializing camera controller');
      await cameraController!.initialize();
      _cameraReady = true;
      AppLogger().debug('Camera controller initialized successfully');
    } on CameraException catch (e) {
      AppLogger().error('Error initializing camera: ${e.description}');
      _cameraReady = false;
    }
  }

  Future<void> disposeCamera() async {
    if (cameraController != null) {
      AppLogger().debug('Disposing camera controller');
      await cameraController!.dispose();
      cameraController = null;
      _cameraReady = false;
      AppLogger().debug('Camera controller disposed');
    }
  }
}
