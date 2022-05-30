import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';

class FFmpegService {
  void FFmpegExecuteCommand(
      /*String ffmpegCommand = '-i /assets/videos/VID_20220525_095330.mp4 -vf "boxblur=10" -c:a copy /storage/emulated/0/Android/data/com.anes.video_compression/files/video_compress/man-blur.mp4',*/) {
    String original = '/storage/emulated/0/DCIM/camera/VID_20220525_155104.mp4';
    String edited =
        '/storage/emulated/0/DCIM/camera/blurred13.mp4';
    String ffmpegCommand = '-i $original -filter_complex "[0:v]boxblur=luma_radius=10:chroma_radius=10:luma_power=1[blurred]" -map "[blurred]" $edited -loglevel debug -v verbose';
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    /// command example: '-i file1.mp4 -c:v mpeg4 file2.mp4'
    FFmpegKit.execute(ffmpegCommand).then((session) async {
      // Unique session id created for this execution
      final sessionId = session.getSessionId();

      // Command arguments as a single string
      final command = session.getCommand();

      // Command arguments
      final commandArguments = session.getArguments();

      // State of the execution. Shows whether it is still running or completed
      final state = await session.getState();

      // Return code for completed sessions. Will be undefined if session is still running or FFmpegKit fails to run it
      final returnCode = await session.getReturnCode();

      final startTime = session.getStartTime();
      final endTime = await session.getEndTime();
      final duration = await session.getDuration();

      // Console output generated for this execution
      final output = await session.getOutput();

      // The stack trace if FFmpegKit fails to run a command
      final failStackTrace = await session.getFailStackTrace();

      // The list of logs generated for this execution
      final logs = await session.getLogs();

      // The list of statistics generated for this execution (only available on FFmpegSession)
      final statistics = await (session as FFmpegSession).getStatistics();

      if (ReturnCode.isSuccess(returnCode)) {
        print("FFmpeg return code: $returnCode");
        stopwatch.stop();
        print("FFmpeg time taken: ${stopwatch.elapsed.inSeconds.toString()}");
      } else if (ReturnCode.isCancel(returnCode)) {
        print("FFmpeg return code: $returnCode");
      } else {
        print("FFmpeg return code: ${returnCode!.getValue()}");
        for(int i = 0; i < logs.length; i++) {
          print("FFmpeg log: ${logs[i].getMessage()}");
        }
        print("FFmpeg stacktrace: ${failStackTrace}");
      }
    });
  }
}
