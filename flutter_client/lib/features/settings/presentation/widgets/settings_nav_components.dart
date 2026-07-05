import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';

/// Fila de navegación de ajustes, estilo list-detail moderno (iOS/Material 3):
/// ícono tintado + título + (subtítulo / valor) + trailing (chevron o custom).
///
/// Pensada para vivir dentro de un [SettingsNavGroup], que dibuja la tarjeta
/// contenedora y los divisores. El ink splash se pinta sobre un Material
/// transparente clippeado (no queda tapado por el fondo de la tarjeta).
class SettingsNavRow extends StatelessWidget {
  final IconData icon;

  /// Acento del ícono. Si es null usa el primario del tema.
  final Color? iconColor;
  final String title;

  /// Línea secundaria debajo del título (ej. "Pareja · 2 miembros").
  final String? subtitle;

  /// Valor mostrado a la derecha, antes del chevron (ej. "Español").
  final String? value;

  /// Reemplaza el chevron (ej. un Switch). Si se da, no se muestra el chevron.
  final Widget? trailing;

  /// null = sin chevron ni tap (fila informativa). Con onTap se muestra chevron
  /// salvo que [trailing] lo reemplace.
  final VoidCallback? onTap;

  /// Pinta título e ícono en color de peligro (logout, borrar cuenta).
  final bool destructive;

  const SettingsNavRow({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accent = destructive ? theme.error : (iconColor ?? theme.primary);
    final titleColor = destructive ? theme.error : theme.textPrimary;

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(icon, color: accent, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: titleColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: theme.textSecondary,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 10),
            Text(
              value!,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
          ],
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: trailing!,
            )
          else if (onTap != null) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.textMuted,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap!();
        },
        splashColor: accent.withValues(alpha: 0.08),
        highlightColor: accent.withValues(alpha: 0.04),
        child: content,
      ),
    );
  }
}

/// Tarjeta contenedora de un grupo de [SettingsNavRow], con divisores finos
/// entre filas y un label opcional arriba. Es el bloque base del nuevo home
/// de ajustes compacto.
class SettingsNavGroup extends StatelessWidget {
  final List<Widget> children;

  /// Label tenue arriba del grupo (ej. "Preferencias"). Sentence case.
  final String? label;

  const SettingsNavGroup({
    super.key,
    required this.children,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(
          Divider(
            height: 0.5,
            thickness: 0.5,
            indent: 60,
            color: theme.border.withValues(alpha: 0.5),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
                color: theme.textMuted,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: theme.border.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: theme.shadow.withValues(alpha: 0.03),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          ),
        ),
      ],
    );
  }
}

/// Espaciado vertical estándar entre grupos del home de ajustes.
class SettingsNavGap extends StatelessWidget {
  const SettingsNavGap({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(height: AppSpacing.lg);
}
