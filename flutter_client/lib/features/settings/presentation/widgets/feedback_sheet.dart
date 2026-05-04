import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/breadcrumb_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum FeedbackType { bug, suggestion }

class FeedbackSheet extends ConsumerStatefulWidget {
  final FeedbackType initialType;

  const FeedbackSheet(
      {super.key, this.initialType = FeedbackType.bug, this.currentScreen});

  final String? currentScreen;

  static void show(BuildContext context,
      {FeedbackType type = FeedbackType.bug, String? screen}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FeedbackSheet(initialType: type, currentScreen: screen),
    );
  }

  @override
  ConsumerState<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends ConsumerState<FeedbackSheet> {
  late FeedbackType _type;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isSending = false;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSending = true);
    HapticFeedback.mediumImpact();

    try {
      final client = ref.read(supabaseClientProvider);
      final userId = ref.read(currentUserIdProvider);
      final profile = ref.read(userProfileProvider).valueOrNull;
      final email = profile?['email'] as String?;
      final info = await PackageInfo.fromPlatform();

      String? deviceModel;
      String? osVersion;
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceModel = '${android.manufacturer} ${android.model}';
        osVersion =
            'Android ${android.version.release} (SDK ${android.version.sdkInt})';
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        deviceModel = ios.utsname.machine;
        osVersion = '${ios.systemName} ${ios.systemVersion}';
      }

      final locale = Platform.localeName;

      await client.from('user_feedback').insert({
        'user_id': userId,
        'email': email,
        'type': _type.name,
        'title': title,
        'description':
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'app_version': '${info.version}+${info.buildNumber}',
        'platform': Platform.isAndroid
            ? 'android'
            : Platform.isIOS
                ? 'ios'
                : 'unknown',
        'device_model': deviceModel,
        'os_version': osVersion,
        'locale': locale,
        'screen_name': widget.currentScreen ?? breadcrumb.currentScreen,
        'breadcrumbs': breadcrumb.getBreadcrumbs(),
      });

      setState(() {
        _isSending = false;
        _sent = true;
      });

      await Future.delayed(const Duration(milliseconds: 1600));
      if (mounted) Navigator.pop(context);
    } catch (e, st) {
      log.e('Error enviando feedback', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo enviar. Intentalo de nuevo.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: theme.scaffoldBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _sent ? _buildSuccess(theme) : _buildForm(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess(dynamic theme) {
    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              color: AppColors.success, size: 32),
        ),
        const SizedBox(height: 16),
        Text(
          _type == FeedbackType.bug
              ? '¡Gracias por reportarlo!'
              : '¡Gracias por la idea!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _type == FeedbackType.bug
              ? 'Lo revisamos a la brevedad.'
              : 'La vamos a tener en cuenta.',
          style: TextStyle(fontSize: 14, color: theme.textSecondary),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildForm(dynamic theme) {
    return Column(
      key: const ValueKey('form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // tipo selector
        Row(
          children: [
            _typeChip(theme, FeedbackType.bug, Icons.bug_report_outlined,
                'Reportar error'),
            const SizedBox(width: 10),
            _typeChip(theme, FeedbackType.suggestion,
                Icons.lightbulb_outline_rounded, 'Sugerir mejora'),
          ],
        ),
        const SizedBox(height: 20),

        Text(
          _type == FeedbackType.bug ? '¿Qué pasó?' : '¿Qué mejorarías?',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: theme.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          maxLength: 120,
          decoration: InputDecoration(
            hintText: _type == FeedbackType.bug
                ? 'Ej: La pantalla de gastos no carga'
                : 'Ej: Poder filtrar tareas por semana',
            filled: true,
            fillColor: theme.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.primary, width: 1.5),
            ),
            counterStyle: TextStyle(fontSize: 11, color: theme.textMuted),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descCtrl,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: _type == FeedbackType.bug
                ? 'Descripción opcional: pasos para reproducirlo, qué esperabas ver...'
                : 'Descripción opcional: contexto, por qué sería útil...',
            filled: true,
            fillColor: theme.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.primary, width: 1.5),
            ),
            counterStyle: TextStyle(fontSize: 11, color: theme.textMuted),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed:
                _isSending || _titleCtrl.text.trim().isEmpty ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: theme.primary.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              elevation: 0,
            ),
            child: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _type == FeedbackType.bug
                        ? 'Enviar reporte'
                        : 'Enviar sugerencia',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _typeChip(
      dynamic theme, FeedbackType type, IconData icon, String label) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _type = type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primary.withValues(alpha: 0.12)
                : theme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.primary.withValues(alpha: 0.6)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected ? theme.primary : theme.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? theme.primary : theme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
