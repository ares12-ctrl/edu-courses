import 'dart:io';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:universa/app/data/services/auth_service.dart';
import 'package:universa/app/theme/app_theme.dart';
import 'package:universa/app/data/services/logger_service.dart';
import 'package:universa/app/data/services/download_service.dart';
import 'package:universa/app/modules/lesson_details/views/widgets/video_watermark_overlay.dart';

class OfflinePlayerController extends GetxController {
  BetterPlayerController? betterPlayerController;
  HttpServer? _localHlsServer;
  final DownloadService _downloadService = Get.find<DownloadService>();
  final AuthService _authService = Get.find<AuthService>();
  late final String path;
  late final String title;
  String username = '';

  @override
  void onInit() {
    super.onInit();
    _loadUsername();
    final args = Get.arguments;
    if (args != null && args is Map) {
      path = args['path'] ?? '';
      title = args['title'] ?? '';
      if (path.isNotEmpty) {
        _initializePlayer();
      }
    } else {
      path = '';
      title = 'Error';
      Get.back();
    }
  }

  Future<void> _loadUsername() async {
    username = await _authService.getUsername() ?? '';
    update();
  }

  Future<void> _initializePlayer() async {
    try {
      final isLocalHls = path.toLowerCase().endsWith('.m3u8');
      debugPrint('OfflinePlayer: Raw path from DB: $path');
      debugPrint('OfflinePlayer: Is local HLS: $isLocalHls');
      final source = isLocalHls ? await _createLocalHlsUrl(path) : path;
      debugPrint('OfflinePlayer: Source URL resolved to: $source');

      final dataSource = BetterPlayerDataSource(
        isLocalHls
            ? BetterPlayerDataSourceType.network
            : BetterPlayerDataSourceType.file,
        source,
        videoFormat: isLocalHls
            ? BetterPlayerVideoFormat.hls
            : BetterPlayerVideoFormat.other,
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: false,
        ),
      );
      betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          fit: BoxFit.contain,
          overlay: const VideoWatermarkOverlay(),
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableSkips: false,
            enableFullscreen: true,
            controlBarColor: AppColors.surface.withValues(alpha: 0.8),
          ),
        ),
        betterPlayerDataSource: dataSource,
      );
      update();
    } catch (e) {
      debugPrint('OfflinePlayer Error: $e');
      LoggerService().error('تعذر تشغيل الفيديو المحمل', title: 'خطأ');
      if (Get.isOverlaysOpen) {
        Future.delayed(const Duration(milliseconds: 300), () => Get.back());
      }
    }
  }

  Future<String> _createLocalHlsUrl(String playlistPath) async {
    final playlistFile = await _downloadService.resolveVideoFile(playlistPath);
    if (!await playlistFile.exists()) {
      debugPrint(
        'OfflinePlayer: Playlist file not found at: ${playlistFile.path}',
      );
      throw Exception('playlist_not_found');
    }

    final resolvedPath = playlistFile.path;
    await _localHlsServer?.close(force: true);
    final baseDirectory = p.dirname(resolvedPath);

    // Explicitly bind to 127.0.0.1 for consistency
    _localHlsServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    debugPrint(
      'OfflinePlayer: Server started at http://${_localHlsServer!.address.address}:${_localHlsServer!.port}',
    );

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
        debugPrint('OfflinePlayer Server: Forbidden path attempt: $relative');
        response.statusCode = HttpStatus.forbidden;
        await response.close();
        return;
      }

      final decodedRelative = Uri.decodeComponent(relative);
      final targetPath = p.join(baseDirectory, decodedRelative);
      final targetFile = File(targetPath);

      if (!await targetFile.exists()) {
        debugPrint(
          'OfflinePlayer Server: 404 Not Found: $targetPath (URI: ${request.uri.path})',
        );
        response.statusCode = HttpStatus.notFound;
        await response.close();
        return;
      }

      debugPrint('OfflinePlayer Server: Serving: $targetPath');

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

    final fileName = p.basename(playlistPath);
    return 'http://127.0.0.1:${_localHlsServer!.port}/$fileName';
  }

  @override
  void onClose() {
    betterPlayerController?.dispose();
    _localHlsServer?.close(force: true);
    super.onClose();
  }
}
