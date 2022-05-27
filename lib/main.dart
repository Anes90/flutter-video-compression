import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_compression/enums.dart';
import 'package:video_compression/videoCompressNotifier.dart';

import 'buttonWidget.dart';
import 'progressDialogWidget.dart';
import 'videoCompressApi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => VideoCompressNotifier.getInstance),
      ],
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Video Compression',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Video Compression'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? fileVideo = null;
  Uint8List? thumbnailBytes;
  int? videoSize;
  MediaInfo? compressedVideoInfo;
  VideoOutputQuality? videoQuality;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            child: const Text('Clear'),
            style: TextButton.styleFrom(primary: Colors.white),
            onPressed: clearSelection,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContent() {
    if (fileVideo == null) {
      return ButtonWidget(
        text: 'Pick Video',
        onClicked: pickVideo,
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildThumbnail(),
          const SizedBox(
            height: 24,
          ),
          buildVideoInfo(),
          const SizedBox(
            height: 16,
          ),
          buildCompressedVideoInfo(),
          const SizedBox(
            height: 16,
          ),
          ButtonWidget(
            text: 'Compress Video (Low quality)',
            onClicked: () {
              videoQuality = VideoOutputQuality.low;
              compressVideo(VideoOutputQuality.low);
            },
          ),
          const SizedBox(
            height: 8,
          ),
          ButtonWidget(
            text: 'Compress Video (Medium quality)',
            onClicked: () {
              videoQuality = VideoOutputQuality.medium;
              compressVideo(VideoOutputQuality.medium);
            },
          ),
          const SizedBox(
            height: 8,
          ),
          ButtonWidget(
            text: 'Compress Video (HD resolution)',
            onClicked: () {
              videoQuality = VideoOutputQuality.hd;
              compressVideo(VideoOutputQuality.hd);
            },
          ),
          const SizedBox(
            height: 8,
          ),
          ButtonWidget(
            text: 'Compress Video (FullHD resolution)',
            onClicked: () {
              videoQuality = VideoOutputQuality.fullHd;
              compressVideo(VideoOutputQuality.fullHd);
            },
          ),
        ],
      );
    }
  }

  Widget buildThumbnail() => thumbnailBytes == null
      ? const CircularProgressIndicator()
      : Image.memory(
          thumbnailBytes!,
          height: 200,
        );

  Widget buildVideoInfo() {
    if (videoSize == null) return Container();
    final size = videoSize! / 1024;

    return Column(
      children: [
        const Text(
          'Original Video Info',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          'Size: ${size.toInt()} KB',
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  Future pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile == null) return;
    final file = File(pickedFile.path);

    setState(() => fileVideo = file);

    generateThumbnail(fileVideo!);

    getVideoSize(fileVideo!);
  }

  Future generateThumbnail(File file) async {
    final thumbnailBytes = await VideoCompress.getByteThumbnail(file.path);

    setState(() => this.thumbnailBytes = thumbnailBytes);
  }

  Future getVideoSize(File file) async {
    final size = await file.length();
    setState(() => videoSize = size);
  }

  Future compressVideo(VideoOutputQuality quality) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Dialog(child: ProgressDialogWidget()));

    final info = await VideoCompressApi.compressVideo(fileVideo!, quality);

    setState(() => compressedVideoInfo = info);

    Navigator.of(context).pop();
  }

  Widget buildCompressedVideoInfo() {
    if (compressedVideoInfo == null) return Container();
    final size = compressedVideoInfo!.filesize! / 1024;

    return Column(
      children: [
        const Text(
          'Compressed Video Info',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          videoQuality != null ? 'Quality: ${videoQuality!.name}' : '',
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          'Size: ${size.toInt()} KB',
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Selector<VideoCompressNotifier, String?>(
          selector: (context, videoCompressNotifier) =>
              videoCompressNotifier.timeTaken,
          builder: (context, timeTaken, child) => Text(
            'Time: ${timeTaken.toString()} seconds',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

  void clearSelection() => setState(() {
        fileVideo = null;
        compressedVideoInfo = null;
      });
}
