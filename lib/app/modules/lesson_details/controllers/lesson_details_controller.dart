import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'dart:async';
import 'dart:io';
import '../../../data/models/subject_model.dart';
import 'package:universa/app/data/services/content_service.dart';
import 'package:universa/app/data/services/download_service.dart';
import 'package:universa/app/data/services/logger_service.dart';
import 'package:universa/app/theme/app_theme.dart';

import '../../subject_details/controllers/subject_details_controller.dart';
import '../views/widgets/video_watermark_overlay.dart';

class LessonDetailsController extends GetxController {
  final ContentService _contentService = Get.find<ContentService>();
  final DownloadService _downloadService = Get.find<DownloadService>();
  HttpServer? _localHlsServer;

  final RxInt lessonId = 0.obs;
  final RxnInt nextLessonId = RxnInt();
  final RxnInt prevLessonId = RxnInt();

  final isLocked = false.obs;
  final RxnInt suggestedLessonId = RxnInt();

  final isLoading = true.obs;
  final lesson = Rxn<Lesson>();

  BetterPlayerController? betterPlayerController;
  final isVideoLoading = true.obs;
  final hasVideoError = false.obs;
  final videoErrorMessage = ''.obs;
  StreamSubscription? _downloadProgressSubscription;
  bool _handlingVideoError = false;

  final downloadProgress = 0.obs;
  final isDownloading = false.obs;
  final isPaused = false.obs;
  final isDownloaded = false.obs;
  String? currentTaskId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is int) {
      lessonId.value = args;
    } else if (args is Map) {
      lessonId.value = args['id'];
    }

    _updateNavigationIds();
    fetchLessonDetails();

    // Listen to global progress stream
    _downloadProgressSubscription = _downloadService.progressStream.listen((event) {
      if (lesson.value != null && event['lesson_id'] == lesson.value!.id) {
        downloadProgress.value = event['progress'];
        final status = event['status'];

        if (status == 1) {
          // Running
          isDownloading.value = true;
          isPaused.value = false;
          isDownloaded.value = false;
        } else if (status == 3) {
          // Success
          isDownloading.value = false;
          isPaused.value = false;
          isDownloaded.value = true;
          LoggerService().success('تم تحميل الدرس بنجاح', title: 'تحميل');
        } else if (status == 5) {
          // Paused
          isDownloading.value = false;
          isPaused.value = true;
        } else {
          // Failed/Cancelled
          isDownloading.value = false;
          isPaused.value = false;
          // Only show error if we were expecting it to run
          // LoggerService().error('فشل التحميل', title: 'خطأ');
        }
      }
    });
  }

  void _updateNavigationIds() {
    try {
      if (Get.isRegistered<SubjectDetailsController>()) {
        final subjectController = Get.find<SubjectDetailsController>();
        nextLessonId.value = subjectController.getNextLessonId(lessonId.value);
        prevLessonId.value = subjectController.getPrevLessonId(lessonId.value);
      }
    } catch (e) {
      debugPrint('SubjectDetailsController not found or error: $e');
    }
  }

  Future<void> loadLesson(int newId) async {
    // Stop current video
    final oldController = betterPlayerController;
    betterPlayerController = null;
    try {
      oldController?.dispose();
    } catch (_) {}
    _localHlsServer?.close(force: true);
    _localHlsServer = null;

    // Reset state
    lessonId.value = newId;
    lesson.value = null;
    isLoading.value = true;
    isVideoLoading.value = true;
    hasVideoError.value = false;
    videoErrorMessage.value = '';
    isDownloading.value = false;
    isPaused.value = false;
    isDownloaded.value = false;
    downloadProgress.value = 0;

    // Update navigation
    _updateNavigationIds();

    // Fetch new details
    await fetchLessonDetails();
  }

  Future<void> fetchLessonDetails() async {
    isLoading.value = true;
    isLocked.value = false;
    try {
      final result = await _contentService.getLessonDetails(lessonId.value);
      if (isClosed) return;
      if (result != null) {
        lesson.value = result;
        await _checkDownloadStatus();
        await _initializePlayer();
      }
    } on LessonLockedException catch (e) {
      isLocked.value = true;
      suggestedLessonId.value = e.suggestedLessonId;
    } catch (e) {
      debugPrint('Error fetching lesson details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkDownloadStatus() async {
    final info = await _downloadService.getDownloadInfo(lessonId.value);
    if (info != null) {
      currentTaskId = info['download_id'];
      downloadProgress.value = info['download_progress'] ?? 0;
      isDownloaded.value = info['download_status'] == 3;
      isDownloading.value = info['download_status'] == 1;
      isPaused.value = info['download_status'] == 5;
    }
  }

  Future<void> _initializePlayer() async {
    if (lesson.value == null) return;

    isVideoLoading.value = true;
    hasVideoError.value = false;
    videoErrorMessage.value = '';
    _handlingVideoError = false;

    try {
      // Check if downloaded and file exists
      final downloadInfo = await _downloadService.getDownloadInfo(
        lessonId.value,
      );
      if (isClosed) return;

      String? videoSource;
      bool isLocal = false;

      if (downloadInfo != null && downloadInfo['download_status'] == 3) {
        final rawPath = downloadInfo['local_video_path'];
        if (rawPath != null) {
          final file = await _downloadService.resolveVideoFile(rawPath);
          if (await file.exists()) {
            videoSource = file.path;
            isLocal = true;
          }
        }
      }

      if (!isLocal) {
        // The server may return an invalid HLS URL, so validate it before
        // handing it to ExoPlayer. Otherwise playback fails with a 404 and the
        // app appears to freeze.
        videoSource = await _resolveRemoteVideoSource();
        if (isClosed) return;
      }

      if (videoSource == null) {
        _showVideoError('تعذر تشغيل الفيديو حاليًا، حاول مرة أخرى لاحقًا');
        return;
      }

      BetterPlayerDataSource dataSource;
      if (isLocal) {
        final isLocalHls = videoSource.toLowerCase().endsWith('.m3u8');
        final localSource = isLocalHls
            ? await _createLocalHlsUrl(videoSource)
            : videoSource;
        if (isClosed) return;
        dataSource = BetterPlayerDataSource(
          isLocalHls
              ? BetterPlayerDataSourceType.network
              : BetterPlayerDataSourceType.file,
          localSource,
          videoFormat: isLocalHls
              ? BetterPlayerVideoFormat.hls
              : BetterPlayerVideoFormat.other,
          cacheConfiguration: const BetterPlayerCacheConfiguration(
            useCache: false,
          ),
        );
      } else {
        final isHls = _isHlsUrl(videoSource);
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          videoSource,
          useAsmsTracks: isHls,
          useAsmsAudioTracks: isHls,
          videoFormat: isHls
              ? BetterPlayerVideoFormat.hls
              : BetterPlayerVideoFormat.other,
        );
      }

      betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          fit: BoxFit.contain,
          autoDetectFullscreenDeviceOrientation: true,
          autoDetectFullscreenAspectRatio: true,
          overlay: const VideoWatermarkOverlay(),
          eventListener: (event) {
            if (event.betterPlayerEventType ==
                BetterPlayerEventType.exception) {
              debugPrint(
                'Video playback error: ${event.parameters?['exception']}',
              );
              _handleVideoError();
            }
          },
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableSkips: false,
            enableFullscreen: true,
            enableQualities: true,
            controlBarColor: AppColors.surface.withValues(alpha: 0.8),
          ),
        ),
        betterPlayerDataSource: dataSource,
      );

      isVideoLoading.value = false;
    } catch (e) {
      debugPrint('Error initializing player: $e');
      _showVideoError('تعذر تشغيل الفيديو حاليًا، حاول مرة أخرى لاحقًا');
    }
  }

  /// Returns the first reachable remote video URL, or null when none works.
  Future<String?> _resolveRemoteVideoSource() async {
    final candidates = <String>[
      if (lesson.value!.directHlsUrl != null) lesson.value!.directHlsUrl!,
      if (lesson.value!.videoUrl != null) lesson.value!.videoUrl!,
    ];

    for (final url in candidates) {
      // Embed/iframe pages can't be played directly by ExoPlayer.
      if (url.contains('/embed/') || url.contains('iframe.')) continue;
      if (await _isUrlReachable(url)) return url;
      if (isClosed) return null;
    }
    return null;
  }

  Future<bool> _isUrlReachable(String url) async {
    final client = HttpClient();
    try {
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-0');
      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );
      // Read only the status; canceling avoids downloading the whole file
      // when the server ignores the Range header.
      final subscription = response.listen((_) {});
      await subscription.cancel();
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  bool _isHlsUrl(String url) =>
      url.toLowerCase().contains('.m3u8');

  void _handleVideoError() {
    if (isClosed || _handlingVideoError) return;
    _handlingVideoError = true;
    _showVideoError(
      'تعذر تشغيل الفيديو حاليًا، تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
    );

    // Dispose the failed player outside of its own event callback.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (isClosed) return;
      final controller = betterPlayerController;
      betterPlayerController = null;
      try {
        controller?.dispose();
      } catch (_) {}
      _handlingVideoError = false;
    });
  }

  void _showVideoError(String message) {
    hasVideoError.value = true;
    videoErrorMessage.value = message;
    isVideoLoading.value = false;
  }

  Future<void> retryVideo() async {
    if (isClosed) return;
    final controller = betterPlayerController;
    betterPlayerController = null;
    try {
      controller?.dispose();
    } catch (_) {}
    await _localHlsServer?.close(force: true);
    _localHlsServer = null;
    await _initializePlayer();
  }

  Future<void> startDownload() async {
    if (lesson.value == null) return;

    // Check internet connection first
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw const SocketException('No internet');
      }
    } on SocketException catch (_) {
      LoggerService().error(
        'تأكد من اتصالك بالانترنت',
        title: 'خطأ في الاتصال',
      );
      return;
    }

    final taskId = await _downloadService.downloadLesson(lesson.value!);
    if (taskId != null) {
      currentTaskId = taskId;
      isDownloading.value = true;
      isPaused.value = false;
      LoggerService().info('بدأ تحميل الدرس في الخلفية', title: 'تحميل');
    }
  }

  Future<void> pauseDownload() async {
    await _downloadService.pauseDownload(lessonId.value);
    isDownloading.value = false;
    isPaused.value = true;
  }

  Future<void> markAsCompleted() async {
    if (lesson.value == null) return;

    try {
      final result = await _contentService.completeLesson(lessonId.value);
      if (result['ok'] == true) {
        // Update local lesson status
        lesson.value = Lesson(
          id: lesson.value!.id,
          title: lesson.value!.title,
          orderIndex: lesson.value!.orderIndex,
          durationSeconds: lesson.value!.durationSeconds,
          isFreePreview: lesson.value!.isFreePreview,
          isCompleted: true,
          videoUrl: lesson.value!.videoUrl,
          directHlsUrl: lesson.value!.directHlsUrl,
          pdfUrl: lesson.value!.pdfUrl,
          externalExamUrl: lesson.value!.externalExamUrl,
        );
        LoggerService().success('تم تعليم الدرس كمكتمل', title: 'تم');

        // Notify SubjectDetailsController to refresh/update
        try {
          if (Get.isRegistered<SubjectDetailsController>()) {
            Get.find<SubjectDetailsController>().fetchSubjectDetails();
          }
        } catch (_) {}
      } else {
        LoggerService().error(result['detail'] ?? 'فشل العملية', title: 'خطأ');
      }
    } catch (e) {
      LoggerService().error('حدث خطأ ما', title: 'خطأ');
    }
  }

  // _monitorProgress removed as we use streams now

  @override
  void onClose() {
    _downloadProgressSubscription?.cancel();
    final controller = betterPlayerController;
    betterPlayerController = null;
    try {
      controller?.dispose();
    } catch (_) {}
    _localHlsServer?.close(force: true);
    super.onClose();
  }

  Future<String> _createLocalHlsUrl(String playlistPath) async {
    final playlistFile = await _downloadService.resolveVideoFile(playlistPath);
    if (!await playlistFile.exists()) {
      throw Exception('playlist_not_found');
    }

    await _localHlsServer?.close(force: true);
    final baseDirectory = playlistFile.parent.path;

    // Explicitly bind to 127.0.0.1 for consistency
    _localHlsServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

    _localHlsServer!.listen((request) async {
      final response = request.response;

      // Add CORS headers
      response.headers.add('Access-Control-Allow-Origin', '*');
      response.headers.add('Access-Control-Allow-Methods', 'GET, OPTIONS');
      response.headers.add(
        'Access-Control-Allow-Headers',
        'Origin, X-Requested-With, Content-Type, Accept',
      );

      if (request.method == 'OPTIONS') {
        response.statusCode = HttpStatus.ok;
        await response.close();
        return;
      }

      final relative = request.uri.path.startsWith('/')
          ? request.uri.path.substring(1)
          : request.uri.path;

      if (relative.contains('..')) {
        response.statusCode = HttpStatus.forbidden;
        await response.close();
        return;
      }

      final targetPath = '$baseDirectory/${Uri.decodeComponent(relative)}';
      final targetFile = File(targetPath);

      if (!await targetFile.exists()) {
        response.statusCode = HttpStatus.notFound;
        await response.close();
        return;
      }

      if (targetPath.toLowerCase().endsWith('.m3u8')) {
        response.headers.contentType = ContentType(
          'application',
          'vnd.apple.mpegurl',
        );
      } else if (targetPath.toLowerCase().endsWith('.ts')) {
        response.headers.contentType = ContentType('video', 'mp2t');
      } else if (targetPath.toLowerCase().endsWith('.key')) {
        response.headers.contentType = ContentType(
          'application',
          'octet-stream',
        );
      }

      await response.addStream(targetFile.openRead());
      await response.close();
    });

    final fileName = playlistFile.uri.pathSegments.last;
    return 'http://127.0.0.1:${_localHlsServer!.port}/$fileName';
  }
}
