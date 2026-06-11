import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Movimientos disponibles para un avatar premium animado.
/// idle es el saludo/respiracion ambiental; el resto son eventos.
enum AvatarMotion { idle, victory, versus, celebrate }

/// Permite disparar un movimiento de evento desde afuera
/// (ej. al ganar el duelo semanal o saldar una deuda).
class PremiumAvatarMotionController {
  _PremiumAnimatedAvatarState? _attached;

  void play(AvatarMotion motion) => _attached?._playEvent(motion);
}

/// Reproduce los WebP animados de un avatar premium con "respiro":
/// hace una pasada completa del movimiento ambiental al aparecer, queda
/// quieto en la pose final (que coincide con la neutral) y la repite cada
/// [restBetweenPlays]. Un [PremiumAvatarMotionController] puede interrumpir
/// con un movimiento de evento; al terminar vuelve al ciclo ambiental.
///
/// Los assets pueden ser rutas de bundle (`assets/...`) o archivos locales
/// descargados (ruta absoluta del cache de la app).
///
/// Decodifica los frames a mano con [ui.Codec] porque Image.asset no
/// permite controlar la reproduccion (y con cacheWidth congela el
/// primer frame). Solo mantiene un frame en memoria a la vez.
///
/// Robustez: se pausa con la app en background o la ruta tapada
/// ([TickerMode]) y respeta reduce-motion (muestra el PNG estatico).
class PremiumAnimatedAvatar extends StatefulWidget {
  /// WebP por movimiento (ruta de asset o archivo local).
  /// Debe incluir al menos [ambientMotion].
  final Map<AvatarMotion, String> motionAssets;

  /// Movimiento que se reproduce en reposo (saludo en el home,
  /// versus en el faceoff, etc.).
  final AvatarMotion ambientMotion;

  /// PNG estatico que se muestra mientras carga o si falla el WebP.
  final String fallbackAsset;
  final double size;
  final Duration restBetweenPlays;
  final PremiumAvatarMotionController? controller;

  const PremiumAnimatedAvatar({
    super.key,
    required this.motionAssets,
    required this.fallbackAsset,
    required this.size,
    this.ambientMotion = AvatarMotion.idle,
    this.restBetweenPlays = const Duration(seconds: 10),
    this.controller,
  });

  @override
  State<PremiumAnimatedAvatar> createState() => _PremiumAnimatedAvatarState();
}

class _PremiumAnimatedAvatarState extends State<PremiumAnimatedAvatar>
    with WidgetsBindingObserver {
  final Map<String, ui.Codec> _codecs = {};
  ui.Image? _frame;
  Timer? _timer;
  bool _failed = false;

  /// true cuando la app esta en background, la ruta esta tapada
  /// (TickerMode) o el usuario tiene reduce-motion activado.
  bool _suspended = false;
  bool _reduceMotion = false;

  /// Invalida pasadas en vuelo cuando arranca una nueva.
  int _playToken = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller?._attached = this;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tickerEnabled = TickerMode.valuesOf(context).enabled;
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final shouldSuspend = !tickerEnabled ||
        _reduceMotion ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused;
    _setSuspended(shouldSuspend);
    if (!_suspended && _timer == null && _frame == null) {
      _startAmbient();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setSuspended(_reduceMotion ? true : false);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _setSuspended(true);
    }
  }

  void _setSuspended(bool value) {
    if (_suspended == value) return;
    _suspended = value;
    if (value) {
      _timer?.cancel();
      _timer = null;
      _playToken++;
    } else if (mounted) {
      _startAmbient();
    }
  }

  @override
  void didUpdateWidget(PremiumAnimatedAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller?._attached == this) {
        oldWidget.controller?._attached = null;
      }
      widget.controller?._attached = this;
    }
    if (oldWidget.ambientMotion != widget.ambientMotion ||
        oldWidget.motionAssets[widget.ambientMotion] !=
            widget.motionAssets[widget.ambientMotion]) {
      for (final codec in _codecs.values) {
        codec.dispose();
      }
      _codecs.clear();
      _failed = false;
      _startAmbient();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.controller?._attached == this) {
      widget.controller?._attached = null;
    }
    _timer?.cancel();
    _playToken++;
    _frame?.dispose();
    _frame = null;
    for (final codec in _codecs.values) {
      codec.dispose();
    }
    super.dispose();
  }

  Future<ui.Codec?> _codecFor(String asset) async {
    final cached = _codecs[asset];
    if (cached != null) return cached;
    try {
      final Uint8List bytes;
      if (asset.startsWith('assets/')) {
        final data = await rootBundle.load(asset);
        bytes = data.buffer.asUint8List();
      } else {
        bytes = await File(asset).readAsBytes();
      }
      final codec = await ui.instantiateImageCodec(bytes);
      if (!mounted) {
        codec.dispose();
        return null;
      }
      return _codecs[asset] = codec;
    } catch (_) {
      return null;
    }
  }

  void _scheduleAmbient() {
    if (!mounted || _suspended) return;
    _timer = Timer(widget.restBetweenPlays, _startAmbient);
  }

  void _startAmbient() {
    if (_suspended) return;
    // Si falta el movimiento ambiental pedido (avatar con set parcial),
    // caer al idle animado antes que al PNG estatico.
    final asset = widget.motionAssets[widget.ambientMotion] ??
        widget.motionAssets[AvatarMotion.idle];
    if (asset == null) {
      setState(() => _failed = true);
      return;
    }
    _playPass(asset, onDone: _scheduleAmbient);
  }

  void _playEvent(AvatarMotion motion) {
    if (_suspended || !mounted) return;
    final asset = widget.motionAssets[motion];
    if (asset == null) return;
    _playPass(asset, onDone: _scheduleAmbient);
  }

  Future<void> _playPass(String asset, {required VoidCallback onDone}) async {
    _timer?.cancel();
    final token = ++_playToken;
    final codec = await _codecFor(asset);
    if (!mounted || token != _playToken) return;
    if (codec == null) {
      // Sin codec no hay pasada, pero el ciclo ambiental debe seguir vivo
      // (un evento fallido no puede dejar congelada a la mascota).
      if (_frame == null) setState(() => _failed = true);
      onDone();
      return;
    }

    var framesShown = 0;
    Future<void> advance() async {
      if (!mounted || token != _playToken) return;
      final ui.FrameInfo info;
      try {
        info = await codec.getNextFrame();
      } catch (_) {
        if (mounted && _frame == null) setState(() => _failed = true);
        onDone();
        return;
      }
      if (!mounted || token != _playToken) {
        info.image.dispose();
        return;
      }
      final previous = _frame;
      setState(() {
        _frame = info.image;
        _failed = false;
      });
      previous?.dispose();
      framesShown++;
      if (framesShown < codec.frameCount) {
        _timer = Timer(info.duration, advance);
      } else {
        onDone();
      }
    }

    await advance();
  }

  @override
  Widget build(BuildContext context) {
    if (_frame == null || _failed || _reduceMotion) {
      return Image.asset(
        widget.fallbackAsset,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) =>
            SizedBox(width: widget.size, height: widget.size),
      );
    }
    // RepaintBoundary: cada frame del WebP marca dirty solo esta capa en
    // vez de repintar hasta el boundary ancestro (la card/pantalla entera).
    return RepaintBoundary(
      child: RawImage(
        image: _frame,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
