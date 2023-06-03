import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
//import './main_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';




class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FlutterTts flutterTts = FlutterTts();
  bool isImageselected=false;
  //AudioCache audioCache = AudioCache();
  //AudioPlayer audioPlayer = AudioPlayer();

  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? image;
  File? _image;

  final picker = ImagePicker();
  stt.SpeechToText speech = stt.SpeechToText();

  Future getImager() async {
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
        isImageselected=true;
      } else {
        print("No Image Selected");
      }
    });
  }

  get body => null; //for captured image

  @override
  void initState() {
    loadCamera();
    SpeechRecognition();
   // audioCache.load('assets/soundfiles/shutter_sound.wav');
    super.initState();
  }
  loadCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![0],ResolutionPreset.high);
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
  Future<void> captureImage() async {
    try {
      if (controller != null) {
        // Check if the camera controller is not null
        if (controller!.value.isInitialized) {
          // Check if the camera controller is initialized
          image = await controller!.takePicture(); // Capture the image
          setState(() {
            // Update the UI
          });
          if (image != null) {
            //audioPlayer.setVolume(1.0);
           // audioPlayer.play(UrlSource('assets/soundfiles/shutter_sound.wav'));
            await predictImagecapture(File(image!.path));
          } else {
            print('No image captured');
          }
        }
      }
    } catch (e) {
      print(e); // Show error
    }
  }

  /*void startListening() {
    speech.listen(
      onResult: (stt.SpeechRecognitionResult result) {
        String spokenWords = result.recognizedWords.toLowerCase();
        if (spokenWords.contains('capture image')) {
          // Call the capture image function here
          captureImage();
        }
      },
    );
  }*/

  void SpeechRecognition() async {
    bool available = await speech.initialize();
    if (available) {
      speech.listen(
        onResult: (stt.SpeechRecognitionResult result) {
          String spokenWords = result.recognizedWords.toLowerCase();
          if (spokenWords.contains('capture image')) {
            // Call the capture image function here
            captureImage();
          }
        },
      );
      Timer(Duration(seconds: 10), ()
      {
        speech.stop();

      });
    }
  }

  String? prediction;

  /* Future<String> getPrediction(File imageFile) async {
    try {
      final url = Uri.parse('https://api.replicate.com/v1/predictions');
      final request = http.MultipartRequest('POST', url);
      print('Image file path: ${imageFile.path}');
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      print('Request files: ${request.files}');
      final response = await request.send();
      final responseJson = jsonDecode(await response.stream.bytesToString());
      print('Response JSON: $responseJson');
      final predictionResult = responseJson['prediction'];
      return predictionResult ?? "No prediction found";
    }
    catch (e) {
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
  Future<void> predictImagecapture(File imagefile) async {
    if (imagefile != null) {
      final subscriptionKey = '471b2a144cee41fe8599ad4f94a8174e';
      final endpoint = 'https://abhii.cognitiveservices.azure.com/';

      final uri =
      Uri.parse('$endpoint/vision/v3.2/analyze?visualFeatures=Description');
      final headers = {
        'Ocp-Apim-Subscription-Key': subscriptionKey,
        'Content-Type': 'application/octet-stream',
      };

      final imageBytes = imagefile.readAsBytesSync();

      final response = await http.post(uri, headers: headers, body: imageBytes);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final captions = responseBody['description']['captions'];
        for (final caption in captions) {
          final captionText = caption['text'];
          print(caption['text']);
          setState(() {
            prediction = caption['text'];
          });
          await flutterTts.speak(captionText);
        }
      }
      Timer(Duration(seconds: 5), () {
        SpeechRecognition();
      });
    }
  }

  Future<void> predictImage() async {
    if (_image != null) {
      final subscriptionKey = '471b2a144cee41fe8599ad4f94a8174e';
      final endpoint = 'https://abhii.cognitiveservices.azure.com/';

      final uri =
      Uri.parse('$endpoint/vision/v3.2/analyze?visualFeatures=Description');
      final headers = {
        'Ocp-Apim-Subscription-Key': subscriptionKey,
        'Content-Type': 'application/octet-stream',
      };

      final imageBytes = _image!.readAsBytesSync();

      final response = await http.post(uri, headers: headers, body: imageBytes);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final captions = responseBody['description']['captions'];
        for (final caption in captions) {
          final captionText = caption['text'];
          print(caption['text']);
          setState(() {
            prediction = caption['text'];
          });
          await flutterTts.speak(captionText);
          // Text("Caption:$prediction");
        }
      } else {
        print(
            'Error: ${response.statusCode} ${responseBody['error']['message']}');
      }
      Timer(Duration(seconds: 5), () {
        SpeechRecognition();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: MainDrawer(),
      appBar: AppBar(
        title: Text("SEEK ASSIST",textAlign: TextAlign.center),
        centerTitle: true,

        backgroundColor: Colors.green,
      ),
      body: Container(
          child: SingleChildScrollView(
            child: Column(children: [
              Container(
                  height: MediaQuery.of(context).size.height * 0.8, // 80% of the screen height
                  width: MediaQuery.of(context).size.width * 1, // 80% of the screen width
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
                          if (image != null) {
                            await predictImagecapture(File(image!.path));
                          } else {
                            print('No image captured');
                          }
                        }
                      }
                    } catch (e) {
                      print(e); //show error
                    }
                  },

                  icon: Icon(Icons.camera),
                  label: Text("Capture"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, //elevated button background color
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
                style:  ElevatedButton.styleFrom(
                    backgroundColor: Colors.green//elevated button background color
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
              if(isImageselected)
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
    );
  }
}