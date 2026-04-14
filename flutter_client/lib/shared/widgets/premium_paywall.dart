import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/services/analytics_service.dart';

class PremiumPaywall extends ConsumerWidget {
  const PremiumPaywall({super.key});

  static void show(BuildContext context) {
    AnalyticsService().trackPaywallOpened(
      source: 'shared_paywall',
      variant: 'bottom_sheet',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumPaywall(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Stack(
        children: [
          // Fondo decorativo
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFDE68A).withValues(alpha: 0.3),
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 40),

              // Título
              const Text(
                'HomeSync Premium',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF92400E),
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                'Lleva tu relación al siguiente nivel',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 40),

              // Beneficios
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  children: [
                    _buildBenefitItem(
                      icon: Icons.sync_alt_rounded,
                      title: 'Sincronización Inteligente',
                      description:
                          'Convierte tus compras en gastos automáticamente.',
                    ),
                    _buildBenefitItem(
                      icon: Icons.calendar_month_rounded,
                      title: 'Pagos Recurrentes',
                      description:
                          'Gestiona Netflix, alquiler y más en equipo.',
                    ),
                    _buildBenefitItem(
                      icon: Icons.favorite_rounded,
                      title: 'Notas de Amor',
                      description:
                          'Mensajes especiales directo en tu Dashboard.',
                    ),
                    _buildBenefitItem(
                      icon: Icons.face_retouching_natural_rounded,
                      title: 'Avatares Exclusivos',
                      description: 'Diseños únicos y animados para destacar.',
                    ),
                    _buildBenefitItem(
                      icon: Icons.palette_rounded,
                      title: 'Temas Personalizados',
                      description:
                          'Próximamente: Cambia los colores de tu app.',
                    ),
                  ],
                ),
              ),

              // Botón de acción
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(premiumProvider.notifier)
                            .togglePremiumMock();
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'SIMULAR SUSCRIPCIÓN (TEST)',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Tal vez más tarde',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Cerrar button
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE68A).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFFB45309), size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
