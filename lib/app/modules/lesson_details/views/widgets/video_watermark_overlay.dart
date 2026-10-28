import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/services/auth_service.dart';

class VideoWatermarkOverlay extends StatefulWidget {
  const VideoWatermarkOverlay({super.key});

  @override
  State<VideoWatermarkOverlay> createState() => _VideoWatermarkOverlayState();
}

class _VideoWatermarkOverlayState extends State<VideoWatermarkOverlay> {
  final AuthService _authService = Get.find<AuthService>();
  String? _username;
  Timer? _timer;
  Alignment _currentAlignment = Alignment.topLeft;
  final Random _random = Random();

  final List<Alignment> _alignments = [
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.centerLeft,
    Alignment.center,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.bottomRight,
    const Alignment(-0.5, -0.5),
    const Alignment(0.5, 0.5),
    const Alignment(-0.5, 0.5),
    const Alignment(0.5, -0.5),
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _startTimer();
  }

  Future<void> _loadUsername() async {
    final username = await _authService.getUsername();
    if (mounted) {
      setState(() {
        _username = username ?? 'EduCourses';
      });
    }
  }

  void _startTimer() {
    _changeAlignment(); // Initial alignment
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _changeAlignment();
    });
  }

  void _changeAlignment() {
    if (mounted) {
      setState(() {
        _currentAlignment = _alignments[_random.nextInt(_alignments.length)];
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_username == null) return const SizedBox.shrink();

    return IgnorePointer(
      child: Align(
        alignment: _currentAlignment,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            _username!,
            style: GoogleFonts.cairo(
              color: Colors.yellow.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 4.0,
                  color: Colors.black.withOpacity(0.8),
                  offset: const Offset(1.0, 1.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
