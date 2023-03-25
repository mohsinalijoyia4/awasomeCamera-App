// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:camerawesome/camerawesome_plugin.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//   late CameraController controller;

//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     final CameraController? cameraController = controller;

//     // App state changed before we got the chance to initialize.
//     if (cameraController == null || !cameraController.value.isInitialized) {
//       return;
//     }

//     if (state == AppLifecycleState.inactive) {
//       cameraController.dispose();
//     } else if (state == AppLifecycleState.resumed) {
//       // onNewCameraSelected(cameraController.description);
//     }
//   }

//   late List<CameraDescription> _cameras;
//   // _cameras =  availableCameras();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsFlutterBinding.ensureInitialized();

//     controller = CameraController(_cameras[0], ResolutionPreset.max);
//     controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//     }).catchError((Object e) {
//       if (e is CameraException) {
//         switch (e.code) {
//           case 'CameraAccessDenied':
//             // Handle access errors here.
//             break;
//           default:
//             // Handle other errors here.
//             break;
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: CameraAwesomeBuilder.awesome(
//         saveConfig: SaveConfig.photoAndVideo(photoPathBuilder: () async {
//           final Directory extDir = await getTemporaryDirectory();
//           final testDir =
//               await Directory('${extDir.path}/test').create(recursive: true);
//           return '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
//         }, videoPathBuilder: () async {
//           final Directory extDir = await getTemporaryDirectory();
//           final testDir =
//               await Directory('${extDir.path}/test').create(recursive: true);
//           return '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
//         }),
//         filter: AwesomeFilter.None,
//       ),
//     );
//   }
// }
