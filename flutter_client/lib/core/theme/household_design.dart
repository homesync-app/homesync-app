import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';

class HouseholdModeDesign {
  final HouseholdType type;
  final String name;
  final String shortName;
  final String dashboardTitle;
  final String dashboardSubtitle;
  final String primaryActionLabel;
  final String designTone;
  final IconData icon;
  final IconData outlineIcon;
  final Color accent;
  final Color secondaryAccent;
  final Color tertiaryAccent;
  final List<Color> heroGradient;
  final List<String> principles;

  const HouseholdModeDesign({
    required this.type,
    required this.name,
    required this.shortName,
    required this.dashboardTitle,
    required this.dashboardSubtitle,
    required this.primaryActionLabel,
    required this.designTone,
    required this.icon,
    required this.outlineIcon,
    required this.accent,
    required this.secondaryAccent,
    required this.tertiaryAccent,
    required this.heroGradient,
    required this.principles,
  });
}

extension HouseholdModeDesignX on HouseholdType {
  HouseholdModeDesign get design {
    return switch (this) {
      HouseholdType.solo => const HouseholdModeDesign(
          type: HouseholdType.solo,
          name: 'Solo',
          shortName: 'Solo',
          dashboardTitle: 'Tu espacio',
          dashboardSubtitle:
              'Un lugar claro para ordenar tus gastos, compras y rutinas.',
          primaryActionLabel: 'Registrar',
          designTone: 'Calmo, personal y enfocado',
          icon: Icons.person_rounded,
          outlineIcon: Icons.person_outline_rounded,
          accent: AppColors.sage,
          secondaryAccent: AppColors.accentBlue,
          tertiaryAccent: AppColors.accentGold,
          heroGradient: [
            Color(0xFFEAF4F1),
            Color(0xFFFFFBF7),
          ],
          principles: [
            'Priorizar foco personal sobre actividad social.',
            'Usar menos elementos por pantalla y más aire.',
            'Mostrar progreso sin presión competitiva.',
          ],
        ),
      HouseholdType.couple => const HouseholdModeDesign(
          type: HouseholdType.couple,
          name: 'Pareja',
          shortName: 'Pareja',
          dashboardTitle: 'Nuestro hogar',
          dashboardSubtitle:
              'Balance, gestos y acuerdos para cuidar lo compartido.',
          primaryActionLabel: 'Sumar algo',
          designTone: 'Cálido, cercano y emocional',
          icon: Icons.favorite_rounded,
          outlineIcon: Icons.favorite_outline_rounded,
          accent: AppColors.primary,
          secondaryAccent: AppColors.accentPeach,
          tertiaryAccent: AppColors.sage,
          heroGradient: [
            Color(0xFFFFEBDD),
            Color(0xFFFFF8F2),
          ],
          principles: [
            'Dar protagonismo al vínculo y al equilibrio compartido.',
            'Permitir detalles expresivos sin perder claridad financiera.',
            'Usar microcopy afectivo, breve y argentino.',
          ],
        ),
      HouseholdType.family => const HouseholdModeDesign(
          type: HouseholdType.family,
          name: 'Familia',
          shortName: 'Familia',
          dashboardTitle: 'Hogar familiar',
          dashboardSubtitle:
              'Coordinación simple para que todos sepan qué toca.',
          primaryActionLabel: 'Organizar',
          designTone: 'Claro, colaborativo y contenedor',
          icon: Icons.family_restroom_rounded,
          outlineIcon: Icons.family_restroom_outlined,
          accent: AppColors.sage,
          secondaryAccent: AppColors.accentGold,
          tertiaryAccent: AppColors.accentGreen,
          heroGradient: [
            Color(0xFFEAF4F1),
            Color(0xFFFFF6E5),
          ],
          principles: [
            'Separar vistas de adultos, adolescentes y niños con claridad.',
            'Usar jerarquías más operativas que decorativas.',
            'Hacer visibles responsabilidades, aprobaciones y recompensas.',
          ],
        ),
      HouseholdType.friends => const HouseholdModeDesign(
          type: HouseholdType.friends,
          name: 'Compañeros',
          shortName: 'Convivencia',
          dashboardTitle: 'Convivencia',
          dashboardSubtitle:
              'Cuentas claras, tareas repartidas y acuerdos sin vueltas.',
          primaryActionLabel: 'Resolver',
          designTone: 'Ágil, neutral y práctico',
          icon: Icons.group_rounded,
          outlineIcon: Icons.group_outlined,
          accent: AppColors.accentBlue,
          secondaryAccent: AppColors.sage,
          tertiaryAccent: AppColors.accentPurple,
          heroGradient: [
            Color(0xFFEAF2FF),
            Color(0xFFF7FBFA),
          ],
          principles: [
            'Evitar tonos románticos o familiares.',
            'Priorizar reparto, deuda, estado y próximos pasos.',
            'Usar lenguaje directo y liviano.',
          ],
        ),
    };
  }
}
