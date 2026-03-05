import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/services/mercadopago_service.dart';
import 'package:homesync_client/core/providers/core_providers.dart';

class MercadoPagoSettingsCard extends ConsumerStatefulWidget {
  const MercadoPagoSettingsCard({super.key});

  @override
  ConsumerState<MercadoPagoSettingsCard> createState() =>
      _MercadoPagoSettingsCardState();
}

class _MercadoPagoSettingsCardState
    extends ConsumerState<MercadoPagoSettingsCard> {
  final _aliasController = TextEditingController();
  final _mpService = MercadoPagoService();
  bool _isSaving = false;

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  Future<void> _saveAlias() async {
    final alias = _aliasController.text.trim();
    if (alias.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client
          .from('users')
          .update({'mercadopago_alias': alias}).eq('id', userId);

      ref.invalidate(userProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Alias guardado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text('Error: $e'),
      ),
      data: (profile) {
        final currentAlias = profile?['mercadopago_alias'] as String? ?? '';
        if (_aliasController.text.isEmpty && currentAlias.isNotEmpty) {
          _aliasController.text = currentAlias;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.lightBlue, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pagos y Mercado Pago',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('Configura cómo recibir y pagar gastos',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Alias/CVU Field
              const Text('TU ALIAS O CVU',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _aliasController,
                      decoration: InputDecoration(
                        hintText: 'ej: mi.alias.mp',
                        filled: true,
                        fillColor: AppColors.primary.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveAlias,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      minimumSize: const Size(80, 48),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Guardar'),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 4),
                child: Text(
                    'Esto permite que tu pareja te transfiera directamente sin comisiones.',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Pagos habilitados vía CheckoutPro
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.success, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pagos habilitados. Podés saldar deudas y aportar a metas directamente con Mercado Pago.',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
