import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart'
    show kTransparentImage;
import 'package:flutter/material.dart';

class FaceDetctionPage extends StatefulWidget {
  const FaceDetctionPage({Key key}) : super(key: key);

  @override
  _FaceDetctionPageState createState() => _FaceDetctionPageState();
}

class _FaceDetctionPageState extends State<FaceDetctionPage> {
  File _imageFile;
  String _mlResult = '<no result>';
  final _picker = ImagePicker();

  Future<bool> _pickImage() async {
    setState(() => this._imageFile = null);
    final File imageFile = await showDialog<File>(
      context: context,
      builder: (ctx) => SimpleDialog(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take picture'),
            onTap: () async {
              final PickedFile pickedFile =
                  await _picker.getImage(source: ImageSource.camera);
              Navigator.pop(ctx, File(pickedFile.path));
            },
          ),
          ListTile(
            leading: Icon(Icons.image),
            title: Text('Pick from gallery'),
            onTap: () async {
              try {
                final PickedFile pickedFile =
                    await _picker.getImage(source: ImageSource.gallery);
                Navigator.pop(ctx, File(pickedFile.path));
              } catch (e) {
                print(e);
                Navigator.pop(ctx, null);
              }
            },
          ),
        ],
      ),
    );
    if (imageFile == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('Please pick one image first.')),
      );
      return false;
    }
    setState(() => this._imageFile = imageFile);
    print('picked image: ${this._imageFile}');
    return true;
  }

  Future<Null> _faceDetect() async {
    setState(() => this._mlResult = '<no result>');
    if (await _pickImage() == false) {
      return;
    }
    String result = '';
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(this._imageFile);
    final options = FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
    );
    final FaceDetector faceDetector =
        FirebaseVision.instance.faceDetector(options);
    final List<Face> faces = await faceDetector.processImage(visionImage);
    result += 'Detected ${faces.length} faces.\n';
    for (Face face in faces) {
      final Rect boundingBox = face.boundingBox;
      // Head is rotated to the right rotY degrees
      final double rotY = face.headEulerAngleY;
      // Head is tilted sideways rotZ degrees
      final double rotZ = face.headEulerAngleZ;
      result += '\n# Face:\n '
          'bbox=$boundingBox\n '
          'rotY=$rotY\n '
          'rotZ=$rotZ\n ';
      // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
      // eyes, cheeks, and nose available):
      final FaceLandmark leftEar = face.getLandmark(FaceLandmarkType.leftEar);
      if (leftEar != null) {
        final Offset leftEarPos = leftEar.position;
        result += 'leftEarPos=$leftEarPos\n ';
      }
      // If classification was enabled with FaceDetectorOptions:
      if (face.smilingProbability != null) {
        final double smileProb = face.smilingProbability;
        result += 'smileProb=${smileProb.toStringAsFixed(3)}\n ';
      }
      // If face tracking was enabled with FaceDetectorOptions:
      if (face.trackingId != null) {
        final int id = face.trackingId;
        result += 'id=$id\n ';
      }
    }
    if (result.length > 0) {
      setState(() => this._mlResult = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Detection'),
      ),
      body: ListView(
        children: <Widget>[
          this._imageFile == null
              ? Placeholder(
                  fallbackHeight: 200.0,
                )
              : FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: FileImage(this._imageFile),
                  // Image.file(, fit: BoxFit.contain),
                ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ButtonBar(
              children: <Widget>[
                RaisedButton(
                  child: Text('Face Detection'),
                  onPressed: this._faceDetect,
                ),
              ],
            ),
          ),
          Divider(),
          Text('Result:', style: Theme.of(context).textTheme.subtitle2),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              this._mlResult,
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
