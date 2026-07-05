import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homesync_client/core/services/logger_service.dart';

/// Movimientos disponibles para un avatar premium animado.
/// idle es el saludo/respiracion ambiental; el resto son eventos.
enum AvatarMotion { idle, victory, versus, celebrate, tada }

/// Permite disparar un movimiento de evento desde afuera
/// (ej. al ganar el duelo semanal o saldar una deuda).
class PremiumAvatarMotionController {
  _PremiumAnimatedAvatarState? _attached;

  void play(AvatarMotion motion) => _attached?._playEvent(motion);
}

/// Reproduce los WebP animados de un avatar premium como "llegada":
/// hace UNA pasada del movimiento ambiental al entrar a la app (mount) y al
/// volver del background (resume), y queda quieto en la pose de reposo del
/// arte. NO se re-dispara al cambiar de pestana. No loopea. Un
/// [PremiumAvatarMotionController] puede interrumpir con un evento; al
/// terminar queda en reposo.
///
/// El idle/llegada es un clip en reverse (el personaje llega con el objeto y
/// lo deja, terminando en la pose del sticker = primer frame original). Los
/// eventos son one-shot que vuelven a la pose. Asi todo asienta en reposo.
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
  final PremiumAvatarMotionController? controller;

  /// Espera antes de reproducir la llegada. Util cuando el widget se monta
  /// durante una transicion de ruta: sin retardo, la animacion arranca tapada
  /// por la transicion y el usuario solo alcanza a ver el final del gesto.
  final Duration arrivalDelay;

  /// "Respiracion": escala sutil en loop mientras NO corre una pasada, para
  /// que el personaje nunca se vea muerto. Opt-in por superficie (hero del
  /// paywall, etc.); los avatares chicos del home no la necesitan.
  final bool breathing;

  const PremiumAnimatedAvatar({
    super.key,
    required this.motionAssets,
    required this.fallbackAsset,
    required this.size,
    this.ambientMotion = AvatarMotion.idle,
    this.controller,
    this.arrivalDelay = Duration.zero,
    this.breathing = false,
  });

  @override
  State<PremiumAnimatedAvatar> createState() => _PremiumAnimatedAvatarState();
}

class _PremiumAnimatedAvatarState extends State<PremiumAnimatedAvatar>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final Map<String, ui.Codec> _codecs = {};
  ui.Image? _frame;
  Timer? _timer;
  bool _failed = false;

  /// Fundido del ultimo frame hacia el PNG estatico al terminar una pasada.
  Timer? _settleTimer;
  bool _settling = false;

  /// Respiracion en reposo (solo si widget.breathing).
  late final AnimationController _breathController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final Animation<double> _breathScale = Tween<double>(
    begin: 1,
    end: 1.018,
  ).animate(
    CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
  );

  /// Hay una pasada de WebP corriendo (la respiracion se pausa mientras).
  bool _passActive = false;

  /// La ruta esta tapada / pestana inactiva (via TickerMode).
  bool _offstage = false;
  bool _reduceMotion = false;

  /// Hay una "llegada" pendiente de reproducir. Se prende al entrar a la app
  /// (mount) y al volver del background (resume); se consume al reproducirla.
  /// NO se prende al cambiar de pestana, asi la llegada es una sola vez por
  /// entrada a la app y no cada vez que se vuelve al Inicio.
  bool _pendingArrival = true;

  /// Invalida pasadas en vuelo cuando arranca una nueva.
  int _playToken = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller?._attached = this;
    if (kDebugMode) {
      debugPrint('[PAA] mount #${identityHashCode(this)} '
          'ambient=${widget.ambientMotion}');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _offstage = !TickerMode.valuesOf(context).enabled;
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _updateBreathing();
    if (kDebugMode) {
      debugPrint('[PAA] deps #${identityHashCode(this)} '
          'offstage=$_offstage reduce=$_reduceMotion pending=$_pendingArrival');
    }
    _maybePlayArrival();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Volver del background cuenta como "entrar a la app".
      _pendingArrival = true;
      _maybePlayArrival();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _timer?.cancel();
      _timer = null;
      _playToken++;
      if (_breathController.isAnimating) {
        _breathController.stop();
        _breathController.value = 0;
      }
    }
  }

  /// Reproduce la llegada UNA vez si esta visible, sin reduce-motion y hay una
  /// llegada pendiente. Al cambiar de pestana esto se llama pero _pendingArrival
  /// ya esta consumido, asi que no re-dispara.
  void _maybePlayArrival() {
    if (_offstage || _reduceMotion) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    if (!_pendingArrival) return;
    _pendingArrival = false;
    if (widget.arrivalDelay == Duration.zero) {
      _startAmbient();
      return;
    }
    Future.delayed(widget.arrivalDelay, () {
      // Re-chequear al disparar: pudo pasar a background o quedar tapado
      // mientras corria el retardo.
      if (!mounted || _offstage || _reduceMotion) return;
      _startAmbient();
    });
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
    _settleTimer?.cancel();
    _breathController.dispose();
    _playToken++;
    _frame?.dispose();
    _frame = null;
    for (final codec in _codecs.values) {
      codec.dispose();
    }
    if (kDebugMode) {
      debugPrint('[PAA] dispose #${identityHashCode(this)}');
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
    } catch (e, stack) {
      // El platform decoder de algunos Samsung rechaza el WebP animado
      // ("unimplemented"): dejamos rastro remoto para saber que asset falla
      // y en que dispositivos. El fallback al PNG estatico deberia cubrirlo.
      log.w(
        'PremiumAnimatedAvatar codec decode failed asset=${asset.split('/').last}',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  /// Reproduce la "llegada" UNA vez y queda en la pose final (sin repetir).
  void _startAmbient() {
    if (_offstage || _reduceMotion) return;
    // Si falta el movimiento ambiental pedido (avatar con set parcial),
    // caer al idle animado antes que al PNG estatico.
    final asset = widget.motionAssets[widget.ambientMotion] ??
        widget.motionAssets[AvatarMotion.idle];
    if (asset == null) {
      setState(() => _failed = true);
      return;
    }
    _playPass(asset, onDone: () {});
  }

  void _playEvent(AvatarMotion motion) {
    if (_offstage || _reduceMotion || !mounted) return;
    final asset = widget.motionAssets[motion];
    if (asset == null) return;
    // El evento termina en la pose de reposo y se queda ahi (no vuelve a
    // disparar la llegada).
    _playPass(asset, onDone: () {});
  }

  /// Arranca/pausa la respiracion segun el estado actual.
  void _updateBreathing() {
    if (!widget.breathing || !mounted) return;
    final allowed = !_passActive && !_offstage && !_reduceMotion;
    if (allowed && !_breathController.isAnimating) {
      _breathController.repeat(reverse: true);
    } else if (!allowed && _breathController.isAnimating) {
      _breathController.stop();
      _breathController.value = 0;
    }
  }

  void _endPass() {
    _passActive = false;
    _updateBreathing();
  }

  Future<void> _playPass(String asset, {required VoidCallback onDone}) async {
    _timer?.cancel();
    _settleTimer?.cancel();
    _settling = false;
    _passActive = true;
    _updateBreathing();
    final token = ++_playToken;
    final codec = await _codecFor(asset);
    if (kDebugMode) {
      debugPrint('[PAA] pass #${identityHashCode(this)} token=$token '
          'frames=${codec?.frameCount} asset=${asset.split('/').last}');
    }
    if (!mounted || token != _playToken) return;
    if (codec == null) {
      // Sin codec no hay pasada, pero el ciclo ambiental debe seguir vivo
      // (un evento fallido no puede dejar congelada a la mascota).
      if (_frame == null) setState(() => _failed = true);
      _endPass();
      onDone();
      return;
    }

    var framesShown = 0;
    Future<void> advance() async {
      if (!mounted || token != _playToken) return;
      final ui.FrameInfo info;
      try {
        info = await codec.getNextFrame();
      } catch (e) {
        // Un frame que no decodifica deja la pasada congelada en el ultimo
        // frame bueno: dejar rastro para poder diagnosticarlo en debug.
        if (kDebugMode) {
          debugPrint(
            '[PAA] getNextFrame error token=$token frame=$framesShown: $e',
          );
        }
        if (mounted && _frame == null) setState(() => _failed = true);
        _endPass();
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
        if (kDebugMode) {
          debugPrint('[PAA] done #${identityHashCode(this)} token=$token '
              'shown=$framesShown (settling to sticker)');
        }
        _scheduleSettle(token);
        _endPass();
        onDone();
      }
    }

    await advance();
  }

  /// Tras completar una pasada, funde el ultimo frame al PNG estatico: los
  /// takes de Veo no siempre terminan exactamente en la pose del sticker y
  /// sostener un frame intermedio se ve "trabado". El PNG ES la pose estable.
  void _scheduleSettle(int token) {
    _settleTimer?.cancel();
    _settleTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted || token != _playToken) return;
      setState(() => _settling = true);
    });
  }

  void _onSettleFinished() {
    if (!mounted) return;
    setState(() {
      _frame?.dispose();
      _frame = null;
      _settling = false;
    });
  }

  /// Envuelve [child] con la respiracion (escala anclada a los pies) cuando
  /// esta habilitada; los estados sin respiracion pasan tal cual.
  Widget _withBreathing(Widget child) {
    if (!widget.breathing) return child;
    return ScaleTransition(
      scale: _breathScale,
      alignment: Alignment.bottomCenter,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_frame == null || _failed || _reduceMotion) {
      return _withBreathing(
        Image.asset(
          widget.fallbackAsset,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.low,
          errorBuilder: (_, __, ___) =>
              SizedBox(width: widget.size, height: widget.size),
        ),
      );
    }
    // RepaintBoundary: cada frame del WebP marca dirty solo esta capa en
    // vez de repintar hasta el boundary ancestro (la card/pantalla entera).
    final frameImage = RawImage(
      image: _frame,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
    if (!_settling) {
      return _withBreathing(RepaintBoundary(child: frameImage));
    }
    // Asentado: PNG estable debajo, ultimo frame fundiendose encima.
    return _withBreathing(
      RepaintBoundary(
        child: Stack(
          children: [
            Image.asset(
              widget.fallbackAsset,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.low,
              errorBuilder: (_, __, ___) =>
                  SizedBox(width: widget.size, height: widget.size),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: 0),
              duration: const Duration(milliseconds: 400),
              onEnd: _onSettleFinished,
              child: frameImage,
              builder: (_, opacity, child) =>
                  Opacity(opacity: opacity, child: child),
            ),
          ],
        ),
      ),
    );
  }
}
