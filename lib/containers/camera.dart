import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:linka/globals.dart' as globals;

/// refactor dependency, should not be here 
import 'package:linka/containers/cards.dart';

class CameraScreen extends StatefulWidget {

  @override
  _CameraScreenState createState() {
    return _CameraScreenState();
  }
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController controller;
  String imagePath;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller = CameraController(globals.cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Linka'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
            ),
          ),
          _captureControlRowWidget(),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  /// Display the control bar with buttons to take pictures.
  Widget _captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: controller != null &&
                  controller.value.isInitialized 
              ? onTakePictureButtonPressed
              : null,
        )
      ],
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        if (filePath != null) {
          detectLabels().then((_) { 
            
          });
        } 
      }
    });
  }

  Future<void> detectLabels() async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFilePath(imagePath);
    final LabelDetector labelDetector = FirebaseVision.instance.labelDetector();
    final List<Label> labels = await labelDetector.detectInImage(visionImage);

    List<String> labelTexts = new List();
    for (Label label in labels) {
      final String text = label.label;

      var translation = await globals.translate(text);
      print("translation $translation ?? text $text");
      labelTexts.add(translation ?? text);
    }


    final String uuid = Uuid().v1();
    final String downloadURL = await _uploadFile(uuid);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemsListScreen('photos')),
    );

    await globals.addItem(downloadURL, labelTexts);
  }


  Future<String> _uploadFile(filename) async {
    final File file = File(imagePath);
    final StorageReference ref = FirebaseStorage.instance.ref().child('$filename.jpg');
    final StorageUploadTask uploadTask = ref.putFile(
      file,
      StorageMetadata(
        contentLanguage: 'en',
      ),
    );

    final downloadURL = await (await uploadTask.onComplete).ref.getDownloadURL();
    return downloadURL.toString();
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_vision';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    globals.logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

}

