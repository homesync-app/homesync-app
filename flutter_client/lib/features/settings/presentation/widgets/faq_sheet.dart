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
                Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
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
                  question: 'Como funciona el hogar compartido?',
                  answer:
                      'HomeSync esta pensado para parejas y convivientes. Al unirte a un hogar con un codigo, ambos comparten la misma lista de tareas, gastos y ahorros. Todo lo que haga uno se refleja para el otro.',
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.monetization_on_rounded,
                  color: AppColors.accentGold,
                  question: 'Para que sirven los Coins?',
                  answer:
                      'Los Coins son la recompensa por completar tareas. Puedes usarlos en la seccion de recompensas para canjear vales creados por tu pareja, como una cena romantica o un dia de relax.',
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.accentTeal,
                  question: 'Que son los Duelos Semanales?',
                  answer:
                      'Cada semana comienza un nuevo duelo de XP. El miembro que complete mas tareas y gane mas puntos de experiencia sera el ganador. Es una forma divertida de motivarse mutuamente.',
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.bolt_rounded,
                  color: AppColors.accentBlue,
                  question: 'Como gano XP?',
                  answer:
                      'Ganas XP cada vez que completas una tarea. Las tareas mas dificiles o importantes suelen dar mas XP. Subir de nivel muestra tu progreso dentro del hogar.',
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.accentGreen,
                  question: 'Como funcionan las finanzas?',
                  answer:
                      'En HomeSync puedes registrar gastos reales y tambien anticipar gastos que todavia no pagaste. Los gastos confirmados son los que afectan el balance real entre ustedes. Los pendientes sirven como recordatorio y proyeccion, pero no cambian la deuda hasta que se pagan.',
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.event_repeat_rounded,
                  color: AppColors.primary,
                  question:
                      'Como cuentan los recurrentes y el balance estimado?',
                  answer:
                      'Un recurrente nuevo empieza desde su primera fecha valida. Si lo creas antes o el mismo dia del vencimiento, puede contar este mes. Si lo creas despues, empieza en el siguiente ciclo. "Tu parte pendiente" muestra solo lo que te corresponde segun el split, y "Balance estimado" usa tu balance actual menos esa parte pendiente.',
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.auto_awesome_rounded,
                  color: const Color(0xFF8B5CF6),
                  question: 'Que son los Eventos Especiales?',
                  answer:
                      'Cada semana aparece un desafio de pareja en la tienda. Son actividades pensadas para fortalecer la relacion. Al completarlas, ambos reciben Coins y desbloquean medallas en su perfil de logros.',
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.trending_up_rounded,
                  color: AppColors.primary,
                  question: 'Niveles y logros?',
                  answer:
                      'A medida que ganan XP, suben de nivel. En la seccion de estadisticas pueden ver sus logros, que son medallas por hitos alcanzados, como completar 50 tareas o superar desafios semanales.',
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
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
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
