import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../services/mercadopago_service.dart';
import '../providers/core_providers.dart';

class MercadoPagoSettingsCard extends ConsumerStatefulWidget {
  const MercadoPagoSettingsCard({super.key});

  @override
  ConsumerState<MercadoPagoSettingsCard> createState() => _MercadoPagoSettingsCardState();
}

class _MercadoPagoSettingsCardState extends ConsumerState<MercadoPagoSettingsCard> {
  final _aliasController = TextEditingController();
  final _mpService = MercadoPagoService();
  bool _isSaving = false;
  bool _isConnectingMP = false;

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
          .update({'mercadopago_alias': alias})
          .eq('id', userId);
      
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
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
  Future<void> _connectMP() async {
    setState(() => _isConnectingMP = true);
    try {
      await _mpService.startOAuthFlow();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isConnectingMP = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final connectionAsync = ref.watch(mercadopagoConnectionProvider);

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
              BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
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
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('Configura cómo recibir y pagar gastos',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Alias/CVU Field
              const Text('TU ALIAS O CVU', 
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1.2)),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveAlias,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      minimumSize: const Size(80, 48),
                    ),
                    child: _isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Guardar'),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 4),
                child: Text('Esto permite que tu pareja te transfiera directamente sin comisiones.', 
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              // OAuth Connection Section
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sincronización Automática',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        Text('Conecta tu cuenta para sugerir gastos automáticamente.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  connectionAsync.when(
                    loading: () => const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => const Icon(Icons.error, color: AppColors.error, size: 20),
                    data: (conn) {
                      final isConnected = conn != null;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isConnected) ...[
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                            const SizedBox(width: 6),
                            const Text('Conectado', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 12)),
                          ] else 
                            ElevatedButton(
                              onPressed: _isConnectingMP ? null : _connectMP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                minimumSize: const Size(80, 32),
                                shape: const StadiumBorder(),
                              ),
                              child: _isConnectingMP
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Conectar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
