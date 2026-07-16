import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/shared/widgets/app_smooth_network_image.dart';

/// Miniatura del ticket escaneado que aparece en el formulario.
///
/// Muestra la imagen local (antes de guardar) o una URL firmada (en detalle).
/// Tapeable para ver el ticket en fullscreen.
/// Tiene botón de eliminar para limpiar el escaneo.
class ReceiptPreviewWidget extends StatelessWidget {
  /// Path local de la imagen comprimida (estado pre-confirmación).
  final String? localPath;

  /// URL firmada para mostrar desde Storage (en detalle de gasto ya guardado).
  final String? signedUrl;

  final VoidCallback? onRemove;

  const ReceiptPreviewWidget({
    super.key,
    this.localPath,
    this.signedUrl,
    this.onRemove,
  }) : assert(
          localPath != null || signedUrl != null,
          'Debe proveer localPath o signedUrl',
        );

  @override
  Widget build(BuildContext context) {
    final imageWidget = _buildImage();
    if (imageWidget == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _openFullscreen(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageWidget,
          ),
          // Badge "Ticket"
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '🧾 Ticket',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Botón de eliminar
          if (onRemove != null)
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cancel,
                    size: 18,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget? _buildImage() {
    if (localPath != null) {
      return Image.file(
        File(localPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    if (signedUrl != null) {
      return AppSmoothNetworkImage(
        url: signedUrl!,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => _placeholder(),
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return null;
  }

  Widget _placeholder() => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.receipt_long, color: Colors.grey),
      );

  void _openFullscreen(BuildContext context) {
    final imageWidget = _buildImage();
    if (imageWidget == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text(
              'Ticket',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: localPath != null
                  ? Image.file(File(localPath!))
                  : AppSmoothNetworkImage(
                      url: signedUrl!,
                      fit: BoxFit.contain,
                      placeholderBuilder: (_) => const SizedBox(
                        width: 56,
                        height: 56,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white70,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
