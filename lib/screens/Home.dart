import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:url_launcher/url_launcher.dart';
import 'settings_drawer.dart';
import 'dart:ui' as ui;






class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}
class ImageDetailPage extends StatelessWidget {
  final String imagePath;
  final String caption;

  ImageDetailPage({required this.imagePath, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Image.file(File(imagePath)) ,
              )
          ),
          SizedBox(height: 20),
          Text (
            caption,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}


class _HomeState extends State<Home> {
  FlutterTts flutterTts = FlutterTts();

  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? image;
  File? _image;
  int selectedCameraIndex = 0; // Initially select the first camera
  FlashMode currentFlashMode = FlashMode.auto;
  bool isBarcodeScannerActive = false;
  String? scannedBarcode;




  final picker = ImagePicker();
  stt.SpeechToText speech = stt.SpeechToText();
  // Inside the method where you capture/select an image and have the image path and caption available
  void navigateToImageDetailPage(BuildContext context, String imagePath, String caption) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageDetailPage(imagePath: imagePath, caption: caption),
      ),
    );
  }


  Future getImager() async {
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
         flutterTts.speak('image uploaded');

        _image = File(pickedImage.path);
        // Inside a button onPressed or any other event handler
       // navigateToImageDetailPage(context,pickedImage.path,'');
        predictImage();
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
            await flutterTts.speak('image captured');
            navigateToImageDetailPage(context,image!.path,'');
            predictImagecapture(File(image!.path));
          } else {
            print('No image captured');
          }
        }
      }
    } catch (e) {
      print(e); // Show error
    }
  }


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
    } else {
      print('Speech recognition is not available');
      return;
    }

    // Add a stop signal to terminate speech recognition
    bool stopSignal = false;

    // Start a continuous loop for speech recognition
    while (!stopSignal) {
      // Wait for 1 second before starting the next speech recognition session
      await Future.delayed(Duration(seconds: 1));

      // Check if speech recognition is already listening
      if (!speech.isListening) {
        // Check if the stop signal was received during the delay
        if (stopSignal) {
          break; // Exit the loop if stop signal is received
        }

        // Start listening for speech recognition
        speech.listen(
          onResult: (stt.SpeechRecognitionResult result) {
            String spokenWords = result.recognizedWords.toLowerCase();
            if (spokenWords.contains('capture image')) {
              // Call the capture image function here
              captureImage();
            }
          },
        );
      }
    }
  }

  String? prediction;

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
          navigateToImageDetailPage(context,imagefile.path,'$prediction');
          await flutterTts.speak(captionText);
        }
      }

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
          navigateToImageDetailPage(context,_image!.path,'$prediction');
          await flutterTts.speak(captionText);
          // Text("Caption:$prediction");
        }
      } else {
        print(
            'Error: ${response.statusCode} ${responseBody['error']['message']}');
      }
    }
  }
  // void _navigateToSettingsPage() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => SettingsDrawer()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    double cameraWidthPercent = 1; // 100% of the screen width
    double cameraHeightPercent = 0.9; // 90% of the screen height

    ui.Size screenSize = ui.window.physicalSize / ui.window.devicePixelRatio;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    double cameraWidth = screenWidth * cameraWidthPercent;
    double cameraHeight = screenHeight * cameraHeightPercent;

    return Scaffold(

      backgroundColor: Colors.black,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.black,
        animationCurve: Curves.easeInOut,
        buttonBackgroundColor: Colors.white,
        animationDuration: Duration(milliseconds: 300),
        // backgroundColor: Color(0xFF085B10),
        color: Colors.white60,

        // key: _bottomNavigationKey,
        items: <Widget>[
          Icon(Icons.settings, size: 30),
          Icon(Icons.home, size: 30),
          Icon(Icons.person, size: 30),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsDrawer(),
              ),
            );
          }
        },
      ),


      body:Container(
            child: Column(
                children: [
            Expanded(
            child: Container(
                    width: cameraWidth,
                    height: cameraHeight,
                    child: controller != null ? Stack(
                      children: [
                        // Camera preview widget
                        Positioned.fill(
                          child: AspectRatio(
                            aspectRatio: controller!.value.aspectRatio,
                            child: CameraPreview(controller!),
                          ),
                        ),

                        Positioned(
                          top: 40,
                          left: 20,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                currentFlashMode = getNextFlashMode(currentFlashMode);
                              });
                              setFlashMode(currentFlashMode);
                            },
                            child: Icon(
                              getFlashIcon(currentFlashMode),
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),

                        Positioned(
                          top: 40,
                          right: 20,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isBarcodeScannerActive = !isBarcodeScannerActive;
                              });
                              activateBarcodeScanner();
                              // Barcode scanner activation logic
                            },
                            child: Icon(
                              isBarcodeScannerActive
                                  ? Icons.qr_code_scanner
                                  : Icons.qr_code,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: GestureDetector(
                            onTap: () {
                              switchCameras();
                            },
                            child: Image.asset(
                              'assets/images/camera_switch.png',
                              color: Colors.white,
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),

                        Positioned(
                          left: 20,
                          bottom: 20,
                          child: GestureDetector(
                            onTap: () {
                              getImager();
                            },
                            child: Image.asset(
                              'assets/images/add_image.png',
                              color: Colors.white,
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: GestureDetector(
                              onTap: () async {
                                try {
                                  if (controller != null &&
                                      controller!.value.isInitialized) {
                                    image = await controller!.takePicture();
                                    setState(() {});
                                    if (image != null) {
                                      await flutterTts.speak('image captured');
                                      navigateToImageDetailPage(context,image!.path,'');
                                      await predictImagecapture(File(image!.path));
                                    } else {
                                      print('No image captured');
                                    }
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              },

                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Image.asset(
                                  'assets/images/shutter.png',
                                  color: Color(0xFF085B10),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ): Container(),
                  ),
            ),
                  // Align(
                  //   alignment: Alignment.bottomLeft,
                  //   child: Container(
                  //     margin: EdgeInsets.only(left: 10, bottom: 10),
                  //     child: GestureDetector(
                  //       onTap: () {
                  //         _navigateToSettingsPage(); // Add parentheses here
                  //       },
                  //       child: Icon(
                  //         Icons.settings,
                  //         color: Colors.black,
                  //         size: 50,
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // Container(
                  //   //show captured image
                  //   padding: EdgeInsets.all(30),
                  //   child: image == null
                  //       ? Text("No image captured")
                  //       : Image.file(
                  //     File(image!.path),
                  //     height: 300,
                  //   ),
                  //   //display captured image
                  // ),
                  // if(isImageselected)
                  //   ElevatedButton(
                  //     onPressed: predictImage,
                  //     child: Text('Predict Image'),
                  //   ),
                  // prediction != null
                  //     ? Text(
                  //   "Caption: $prediction",
                  //   style: TextStyle(fontSize: 18),
                  //
                  // )
                  //: Container(),
                ]),
          ),
    );
  }



  void switchCameras() async {
    if (cameras != null && cameras!.length > 1) {
      // Check if multiple cameras are available

      // Release the current camera controller
      await controller!.dispose();

      // Calculate the index of the next camera
      int nextCameraIndex = (selectedCameraIndex + 1) % cameras!.length;

      // Initialize the controller with the next camera
      controller = CameraController(cameras![nextCameraIndex], ResolutionPreset.high);

      // Initialize the camera controller
      await controller!.initialize();

      // Update the selected camera index
      selectedCameraIndex = nextCameraIndex;

      // Update the UI
      setState(() {});
    }
  }
  FlashMode getNextFlashMode(FlashMode currentMode) {
    if (currentMode == FlashMode.auto) {
      return FlashMode.torch;
    } else if (currentMode == FlashMode.torch) {
      return FlashMode.off;
    } else {
      return FlashMode.auto;
    }
  }

  IconData getFlashIcon(FlashMode flashMode) {
    if (flashMode == FlashMode.auto) {
      return Icons.flash_auto;
    } else if (flashMode == FlashMode.torch) {
      return Icons.flash_on;
    } else {
      return Icons.flash_off;
    }
  }

  void setFlashMode(FlashMode flashMode) async {
    if (controller != null && controller!.value.isInitialized) {
      try {
        await controller!.setFlashMode(flashMode);
      } catch (e) {
        print("Failed to set flash mode: $e");
      }
    }
  }
  void activateBarcodeScanner() async {
    if (isBarcodeScannerActive) {
      try {
        String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
          '#FF0000', // Color for the scan view background
          'Cancel', // Text for the cancel button
          true, // Enable flash icon
          ScanMode.DEFAULT, // Scan mode (DEFAULT, QR_CODE, DATA_MATRIX, etc.)
        );

        setState(() {
          scannedBarcode = barcodeScanResult;
        });

        processScannedBarcode(context, barcodeScanResult);
      } on PlatformException catch (e) {
        if (e.code == 'PERMISSION_NOT_GRANTED') {
          // Handle camera permission denied error
          print('Camera permission denied');
        } else {
          // Handle other platform exceptions
          print('Error: ${e.message}');
        }
      }
    }
  }

  void processScannedBarcode(BuildContext context, String barcode) {
    // Example: Open a search in a browser with the scanned barcode
    String searchUrl = barcode; // Replace with your desired search URL
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Scanned Barcode'),
          content: Column(
            children: [
              Text('The scanned barcode is: $barcode'),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await launchUrl(Uri.parse(searchUrl));
                  } catch (e) {
                    throw 'Could not launch $searchUrl: $e';
                  }
                },
                child: Text('Search'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}