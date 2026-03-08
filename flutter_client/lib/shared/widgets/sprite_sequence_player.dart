import 'dart:async';
import 'package:flutter/material.dart';

class SpriteSequencePlayer extends StatefulWidget {
  final String directoryPath;
  final String framePrefix;
  final int totalFrames;
  final double size;
  final Duration frameDuration;
  final bool loop;

  const SpriteSequencePlayer({
    super.key,
    required this.directoryPath,
    this.framePrefix = 'frame_',
    required this.totalFrames,
    required this.size,
    this.frameDuration = const Duration(milliseconds: 42), // ~24 FPS
    this.loop = true,
  });

  @override
  State<SpriteSequencePlayer> createState() => _SpriteSequencePlayerState();
}

class _SpriteSequencePlayerState extends State<SpriteSequencePlayer> {
  int _currentFrame = 0;
  Timer? _timer;
  late List<ImageProvider> _images;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _preloadItems();
    _startAnimation();
  }

  void _preloadItems() {
    _images = List.generate(widget.totalFrames, (index) {
      final frameStr = index.toString().padLeft(3, '0');
      final path = '${widget.directoryPath}${widget.framePrefix}$frameStr.png';
      return AssetImage(path);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start pre-caching after first build
    if (!_ready) {
      _cacheImages();
    }
  }

  Future<void> _cacheImages() async {
    for (var image in _images) {
      precacheImage(image, context);
    }
    if (mounted) {
      setState(() {
        _ready = true;
      });
    }
  }

  void _startAnimation() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.frameDuration, (timer) {
      if (mounted) {
        setState(() {
          _currentFrame++;
          if (_currentFrame >= widget.totalFrames) {
            if (widget.loop) {
              _currentFrame = 0;
            } else {
              _timer?.cancel();
              _currentFrame = widget.totalFrames - 1;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Image(
        image: _images[_currentFrame],
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
