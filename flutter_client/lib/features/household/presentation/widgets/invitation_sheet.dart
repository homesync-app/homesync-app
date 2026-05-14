import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/household_usecase_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class InvitationSheet extends ConsumerStatefulWidget {
  const InvitationSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InvitationSheet(),
    );
  }

  @override
  ConsumerState<InvitationSheet> createState() => _InvitationSheetState();
}

class _InvitationSheetState extends ConsumerState<InvitationSheet> {
  String? _invitationCode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvitationCode();
  }

  Future<void> _loadInvitationCode() async {
    setState(() => _isLoading = true);
    try {
      final hId = await ref.read(householdIdProvider.future);
      if (hId == null) return;

      // Intentar buscar código existente o generar uno nuevo
      final result =
          await ref.read(generateInvitationCodeUseCaseProvider).call();
      result.fold(
        (failure) => _showError(failure.message),
        (code) => setState(() => _invitationCode = code),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _copyCode() {
    if (_invitationCode == null) return;
    Clipboard.setData(ClipboardData(text: _invitationCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado al portapapeles'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _shareViaWhatsApp() async {
    if (_invitationCode == null) return;

    final caps = ref.read(householdCapabilitiesProvider);
    String intro = '¡Hola! Te invito a unirte a nuestro hogar en HomeSync.';

    if (caps.type == HouseholdType.couple) {
      intro =
          '¡Hola! Únete a mi pareja en HomeSync para organizar nuestros gastos y tareas.';
    } else if (caps.type == HouseholdType.family) {
      intro = '¡Hola! Te invito a unirte a nuestro hogar familiar en HomeSync.';
    } else if (caps.type == HouseholdType.friends) {
      intro =
          '¡Hola! Únete a nuestra convivencia en HomeSync para organizar mejor el piso.';
    }

    final text =
        '$intro\n\nDescarga la app e ingresa este código: *$_invitationCode*\n\n¡Organicemos nuestro hogar juntos!';
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        _copyCode();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No se pudo abrir WhatsApp. Código copiado.'),),
          );
        }
      }
    } catch (e) {
      _copyCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.divider.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Invitar al hogar',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: theme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caps.type == HouseholdType.family
                ? 'Comparte este código con los miembros de tu familia.'
                : caps.type == HouseholdType.friends
                    ? 'Comparte este código con tus compañeros para sumarlos a la convivencia.'
                    : 'Comparte este código para que alguien se una a tu hogar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            )
          else if (_invitationCode != null) ...[
            GestureDetector(
              onTap: _copyCode,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Text(
                  _invitationCode!,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: theme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Toca para copiar',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textMuted,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _shareViaWhatsApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.share_rounded),
                label: const Text(
                  'Compartir por WhatsApp',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ] else
            TextButton.icon(
              onPressed: _loadInvitationCode,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar generar código'),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: TextStyle(
                color: theme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
