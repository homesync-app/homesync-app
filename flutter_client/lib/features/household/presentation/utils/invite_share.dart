import 'package:flutter/services.dart';
import 'package:homesync_client/config/app_store_links.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Cómo terminó un intento de compartir la invitación.
enum InviteShareOutcome {
  /// Se abrió WhatsApp o el selector de apps.
  opened,

  /// No se pudo abrir nada: el mensaje completo quedó copiado.
  copiedFallback,
}

/// El mensaje completo de invitación: saludo según el modo, link a la tienda y
/// el código. Sin link, quien lo recibe no sabe de dónde bajar la app.
String buildInviteMessage(
  AppLocalizations t, {
  required String code,
  required HouseholdType type,
}) {
  final intro = switch (type) {
    HouseholdType.couple => t.invitationIntroCouple,
    HouseholdType.family => t.invitationIntroFamily,
    HouseholdType.friends => t.invitationIntroFriends,
    HouseholdType.solo => t.invitationIntroDefault,
  };
  return t.invitationShareMessage(
    intro,
    AppStoreLinks.playStore(inviteCode: code),
    code,
  );
}

/// Abre WhatsApp con el mensaje armado. Si WhatsApp no está disponible, copia
/// el mensaje entero (no solo el código) para que se pueda pegar en cualquier
/// lado.
Future<InviteShareOutcome> shareInviteViaWhatsApp(
  AppLocalizations t, {
  required String code,
  required HouseholdType type,
}) async {
  final message = buildInviteMessage(t, code: code, type: type);
  final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
  try {
    if (await canLaunchUrl(url) &&
        await launchUrl(url, mode: LaunchMode.externalApplication)) {
      return InviteShareOutcome.opened;
    }
  } catch (error, stackTrace) {
    log.w(
      'Invite share via WhatsApp failed; copying the message instead',
      error: error,
      stackTrace: stackTrace,
    );
  }
  await Clipboard.setData(ClipboardData(text: message));
  return InviteShareOutcome.copiedFallback;
}

/// Selector nativo de apps (Telegram, SMS, Instagram…) para quien no usa
/// WhatsApp.
Future<InviteShareOutcome> shareInviteWithSystemSheet(
  AppLocalizations t, {
  required String code,
  required HouseholdType type,
}) async {
  final message = buildInviteMessage(t, code: code, type: type);
  try {
    await SharePlus.instance.share(ShareParams(text: message));
    return InviteShareOutcome.opened;
  } catch (error, stackTrace) {
    log.w(
      'Invite share sheet failed; copying the message instead',
      error: error,
      stackTrace: stackTrace,
    );
    await Clipboard.setData(ClipboardData(text: message));
    return InviteShareOutcome.copiedFallback;
  }
}
