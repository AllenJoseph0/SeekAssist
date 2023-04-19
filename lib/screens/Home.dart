import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import './main_drawer.dart';
import 'package:image_picker/image_picker.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? image;
  File? _image ;


  final picker = ImagePicker();

  Future getImager() async{
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if(pickedImage  !=null ){
        _image = File(pickedImage.path);
      }else{
        print("No Image Selected");
      }

    });

  }

  get body => null; //for captured image

  @override
  void initState() {
    loadCamera();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:MainDrawer(),
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
          child:ElevatedButton.icon(
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
                backgroundColor: Colors.green //elevated button background color
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
            icon: Icon( Icons.photo_library,),
            label: Text('Upload image'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green //elevated button background color
            ),// <-- Text
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
          )
        ]),
      )),
    );
  }
}
