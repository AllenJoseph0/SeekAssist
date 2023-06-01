import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import './main_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:alan_voice/alan_voice.dart';

// String sdkKey =
//     " 08d02464c6f0de671b6df6d9f830c5b82e956eca572e1d8b807a3e2338fdd0dc/stage";
// @override
// // void initState() {
// //   super.initState();
// //   initAlan();
// // }

// initAlan() {
//   AlanVoice.addButton(
//       "08d02464c6f0de671b6df6d9f830c5b82e956eca572e1d8b807a3e2338fdd0dc/stage");
// }

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

// void initState() {
//   super.initState();
//   initAlan();
// }

class _HomeState extends State<Home> {
  // _HomeState() {
  //   /// Init Alan Button with project key from Alan AI Studio
  //   AlanVoice.addButton(
  //       "08d02464c6f0de671b6df6d9f830c5b82e956eca572e1d8b807a3e2338fdd0dc/stage",
  //       buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);

  //   /// Handle commands from Alan AI Studio
  //   AlanVoice.onCommand.add((command) {
  //     debugPrint("got new command ${command.toString()}");
  //   });
  // }

  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? image;
  File? _image;

  final picker = ImagePicker();

  Future getImager() async {
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      } else {
        print("No Image Selected");
      }
    });
  }

  get body => null; //for captured image

//   // @override
//   String sdkKey =
//       " 08d02464c6f0de671b6df6d9f830c5b82e956eca572e1d8b807a3e2338fdd0dc/stage";
// // @override
// // // void initState() {
// // //   super.initState();
// // //   initAlan();
// // // }

//   initAlan() {
//     AlanVoice.addButton(
//         "08d02464c6f0de671b6df6d9f830c5b82e956eca572e1d8b807a3e2338fdd0dc/stage");
//   }

  @override
  void initState() {
    loadCamera();
    super.initState();
    super.initState();
    // initAlan();
  }

  loadCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![0], ResolutionPreset.max);
      //cameras[0] = first camera, change to 1 to another camera

      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {
      print("NO any camera found");
    }
  }

  String? prediction;

 /* Future<String> getPrediction(File imageFile) async {
    try {
      final url = Uri.parse('https://api.replicate.com/v1/predictions');
      final request = http.MultipartRequest('POST', url);
      print('Image file path: ${imageFile.path}');
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));
      print('Request files: ${request.files}');
      final response = await request.send();
      final responseJson = jsonDecode(await response.stream.bytesToString());
      print('Response JSON: $responseJson');
      final predictionResult = responseJson['prediction'];
      return predictionResult ?? "No prediction found";
    } catch (e) {
      print('Error: $e');
      return "Error getting prediction";
    }
  }

  Future<void> predictImage() async {
    try {
      if (_image != null) {
        final predictionResult = await getPrediction(_image!);
        setState(() {
          prediction = predictionResult;
        });
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error: $e');
    }
  }*/
  Future<void> predictImage() async{
    final subscriptionKey = '471b2a144cee41fe8599ad4f94a8174e';
    final endpoint = 'https://abhii.cognitiveservices.azure.com/';
    final imagePath = '_image';

    final uri = Uri.parse('$endpoint/vision/v3.2/analyze?visualFeatures=Description');
    final headers = {
      'Ocp-Apim-Subscription-Key': subscriptionKey,
      'Content-Type': 'application/octet-stream',
    };

    final imageBytes = File(imagePath).readAsBytesSync();

    final response = await http.post(uri, headers: headers, body: imageBytes);
    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final captions = responseBody['description']['captions'];
      for (final caption in captions) {
        print(caption['text']);
        prediction=caption;
      }
    } else {
      print('Error: ${response.statusCode} ${responseBody['error']['message']}');}
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text("SeekAssist"),
        backgroundColor: Colors.green,
      ),
      body: Container(
          child: SingleChildScrollView(
        child: Column(children: [
          Container(
              height: 300,
              width: 400,
              child: controller == null
                  ? Center(child: Text("Loading Camera..."))
                  : !controller!.value.isInitialized
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : CameraPreview(controller!)),
          Container(
            height: 100,
            alignment: Alignment.center,
            padding: EdgeInsets.all(20),
            child: ElevatedButton.icon(
              //image capture button
              onPressed: () async {
                try {
                  if (controller != null) {
                    //check if controller is not null
                    if (controller!.value.isInitialized) {
                      //check if controller is initialized
                      image = await controller!.takePicture(); //capture image
                      setState(() {
                        //update UI
                      });
                    }
                  }
                } catch (e) {
                  print(e); //show error
                }
              },

              icon: Icon(Icons.camera),
              label: Text("Capture"),
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green //elevated button background color
                  ),
            ),
          ),
          Container(
            child: _image == null
                ? Text('No Image Selected')
                : Image.file(_image!),
          ),
          ElevatedButton.icon(
            onPressed: () {
              getImager();
            },
            icon: Icon(
              Icons.photo_library,
            ),
            label: Text('Upload image'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green //elevated button background color
                ), // <-- Text
          ),
          Container(
            //show captured image
            padding: EdgeInsets.all(30),
            child: image == null
                ? Text("No image captured")
                : Image.file(
                    File(image!.path),
                    height: 300,
                  ),
            //display captured image
          ),
          ElevatedButton(
            onPressed: predictImage,
            child: Text('Predict Image'),
          ),
          prediction != null
              ? Text(
                  "Caption: $prediction",
                  style: TextStyle(fontSize: 18),
                )
              : Container(),
        ]),
      )),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {}, child: Icon(Icons.mic, size: 45)),
    );
  }
}
