import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';

class FAQSheet extends StatelessWidget {
  const FAQSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FAQSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.help_outline_rounded,
                    color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Text(
                  'Preguntas Frecuentes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Todo lo que necesitas saber sobre HomeSync',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFAQItem(
                  context,
                  icon: Icons.favorite_rounded,
                  color: AppColors.accentRed,
                  question: '¿Cómo funciona el hogar compartido?',
                  answer:
                      'HomeSync está diseñado para parejas y convivientes. Al unirte a un hogar con un código, ambos comparten la misma lista de tareas, gastos y ahorros. ¡Todo lo que uno haga se refleja al instante para el otro!',
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.monetization_on_rounded,
                  color: AppColors.accentGold,
                  question: '¿Para qué sirven las monedas?',
                  answer:
                      'Las monedas (Coins) son la recompensa por completar tareas. Puedes usarlas en la sección de "Recompensas" para canjear vales creados por tu pareja, como "Cena romántica" o "Día de relax".',
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.accentTeal,
                  question: '¿Qué son los Duelos Semanales?',
                  answer:
                      'Cada semana comienza un nuevo duelo de XP. El miembro que complete más tareas y gane más puntos de experiencia será el ganador de la semana. ¡Es una forma divertida de motivarse mutuamente!',
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.bolt_rounded,
                  color: AppColors.accentBlue,
                  question: '¿Cómo gano XP?',
                  answer:
                      'Ganas XP cada vez que completas una tarea. Las tareas más difíciles o importantes suelen dar más XP. Subir de nivel demuestra quién es el más aplicado de la casa.',
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.accentGreen,
                  question: '¿Cómo funcionan los Gastos?',
                  answer:
                      'Pueden anotar los gastos diarios y elegir si se dividen 50/50 o si uno pagó por el otro. La app lleva el balance de quién le debe a quién automáticamente.',
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.stars_rounded,
                  color: AppColors.primary,
                  question: '¿Cómo consigo Avatares Premium?',
                  answer:
                      'Los Avatares 3D Premium se desbloquean con una suscripción o logros especiales. Estos avatares son animados y le dan un toque único a tu perfil.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
