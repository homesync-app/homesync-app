import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:homesync_client/core/theme/app_colors.dart';

class VideoAvatarPlayer extends StatefulWidget {
  final String url;
  final double size;
  final bool isAsset;

  const VideoAvatarPlayer({
    super.key,
    required this.url,
    required this.size,
    this.isAsset = true,
  });

  @override
  State<VideoAvatarPlayer> createState() => _VideoAvatarPlayerState();
}

class _VideoAvatarPlayerState extends State<VideoAvatarPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    String finalUrl = widget.url;
    
    // Fix for Flutter Web: VideoPlayerController.asset can cause double 'assets/' prefix
    if (widget.isAsset && kIsWeb && finalUrl.startsWith('assets/')) {
      finalUrl = finalUrl.replaceFirst('assets/', '');
    }

    if (widget.isAsset) {
      _controller = VideoPlayerController.asset(finalUrl);
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    }

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
      }
    }).catchError((error) {
      debugPrint('Error initializing video: $error');
      // If asset path fails, try the original path as a fallback
      if (widget.isAsset) {
         // Fallback logic could go here
      }
    });
  }

  @override
  void didUpdateWidget(VideoAvatarPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _controller.dispose();
      _isInitialized = false;
      _initializeController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
