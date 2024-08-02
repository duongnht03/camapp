import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  List<CameraDescription> cameras = [];
  CameraController? cameraController;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if(cameraController == null ||
       cameraController?.value.isInitialized == false) {
      return;
    }

    if(state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if(state == AppLifecycleState.resumed) {
      _setUpCameraController();
    }
  }

  @override
  void initState() {
    super.initState();
    _setUpCameraController();
  }

  Future<void> _setUpCameraController() async {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      cameras = _cameras;
      cameraController =
          CameraController(cameras![0], ResolutionPreset.high);
      cameraController?.initialize().then((_) {
        if(!mounted) {
          return;
        }
        setState(() {});
      }).catchError(
          (Object e) {
            print(e);
          }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Center(
      child: Stack(
        children: [
          Container(
            child: CameraPreview(
              cameraController!,
            ),
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: IconButton(
              onPressed: () async{
                XFile picture = await cameraController!.takePicture();
                Gal.putImage(picture.path);
              },
              icon: const Icon(
                Icons.camera,
                color: Colors.red,
                size: 80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
