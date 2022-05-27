import 'dart:io';

import 'package:video_compress/video_compress.dart';
import 'package:video_compression/videoCompressNotifier.dart';

import 'enums.dart';

class VideoCompressApi{
  static Future<MediaInfo?> compressVideo(File file, VideoOutputQuality quality) async{
    try {
      Stopwatch stopwatch = Stopwatch();
      stopwatch.start();
      await VideoCompress.setLogLevel(0);

      late VideoQuality videoQuality;

      switch(quality){
        case VideoOutputQuality.low: {
          videoQuality = VideoQuality.LowQuality;
        } break;
        case VideoOutputQuality.medium: {
          videoQuality = VideoQuality.MediumQuality;
        } break;
        case VideoOutputQuality.fullHd: {
          videoQuality = VideoQuality.Res1920x1080Quality;
        } break;
        case VideoOutputQuality.hd: {
          videoQuality = VideoQuality.Res1280x720Quality;
        } break;
      }

      return VideoCompress.compressVideo(
        file.path,
        quality: videoQuality,
        includeAudio: true,
      ).whenComplete(() {
        stopwatch.stop();
        VideoCompressNotifier.getInstance.setTimeTaken(stopwatch.elapsed.inSeconds.toString());
      });
    } catch (e) {
      VideoCompress.cancelCompression();
    }
  }
}