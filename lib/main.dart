import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import 'dart:io';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

late List<CameraDescription> _cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

Future<void> navigateToNextScreen(BuildContext context) async {
  await Future.delayed(Duration(seconds: 5));
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => const MyHomePage(
              title: '',
            )),
  );
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    navigateToNextScreen(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
                Text(
                  "AwesomeCamera",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class PreviewScreen extends StatelessWidget {
  final File? imageFile;

  const PreviewScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview'),
      ),
      body: Center(
        child: imageFile != null
            ? Image.file(imageFile!)
            : Text('No image taken.'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? capturedImage;
  final Stream<MediaCapture?> _captureStateStream =
      StreamController<MediaCapture?>().stream;

  // int _counter = 0;
  late CameraController controller;
  Future<bool> _checkPhotosPermission() async {
    if (await Permission.photos.request().isGranted) {
      return true;
    } else {
      print("Permmission is not Granted");
      return false;
    }
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> onImageCaptured(MediaCapture mediaCapture) async {
    final savedFile = await _saveImage(mediaCapture.filePath);

    // final bytes = await File(savedFile.path).readAsBytes();
    // final imageBytes = Uint8List.fromList(bytes);

    // final result = await PhotoManager.editor.saveImage(
    //   imageBytes,
    //   title: '${DateTime.now().millisecondsSinceEpoch}.jpg',
    // );

    // if (result != null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Photo saved to gallery')),
    //   );
    // }
    setState(() {
      capturedImage = savedFile;
    });
  }

  Future<File> _saveImage(String path) async {
    final bytes = await File(path).readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/$fileName';
    final imageFile = File(imagePath);
//  final bytes = await File(savedFile.path).readAsBytes();
    final imageBytes = Uint8List.fromList(bytes);

    final result = await PhotoManager.editor.saveImage(
      imageBytes,
      title: '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo saved to gallery')),
      );
    }
    await imageFile.writeAsBytes(bytes);
    return imageFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.awesome(
        onMediaTap: (MediaCapture file) {
          setState(() {
            onImageCaptured(file);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreviewScreen(imageFile: capturedImage),
              ),
            );
          });
        },
        saveConfig: SaveConfig.photoAndVideo(photoPathBuilder: () async {
          final Directory extDir = await getTemporaryDirectory();
          final testDir =
              await Directory('${extDir.path}/test').create(recursive: true);
          return '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        }, videoPathBuilder: () async {
          final Directory extDir = await getTemporaryDirectory();
          final testDir =
              await Directory('${extDir.path}/test').create(recursive: true);
          return '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
        }),
        filter: AwesomeFilter.None,
      ),
    );
  }
}
