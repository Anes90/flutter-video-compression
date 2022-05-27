import 'package:flutter/material.dart';

class VideoCompressNotifier extends ChangeNotifier {
  static VideoCompressNotifier? _instance;

  VideoCompressNotifier._private() {
    _instance = this;
  }

  static VideoCompressNotifier get getInstance {
    if (_instance == null) return VideoCompressNotifier._private();
    return _instance!;
  }

  String? _timeTaken;

  String? get timeTaken => _timeTaken;

  void setTimeTaken(String timeTaken){
    print("Time taken $timeTaken");
    _timeTaken = timeTaken;
  }
}