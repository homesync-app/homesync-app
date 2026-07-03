import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:homesync_client/features/notifications/domain/entities/app_notification.dart';
import 'package:homesync_client/features/notifications/presentation/utils/notification_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations_en.dart';
import 'package:homesync_client/l10n/generated/app_localizations_es.dart';

AppNotification _n(
  String type, {
  Map<String, dynamic>? params,
  String title = 'Titulo server',
  String body = 'Cuerpo server',
}) {
  return AppNotification(
    id: 'n1',
    title: title,
    body: body,
    type: type,
    params: params,
    createdAt: DateTime(2026, 7, 3),
    isRead: false,
  );
}

void main() {
  final en = AppLocalizationsEn();
  final es = AppLocalizationsEs();

  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  test('fila legada sin params cae al title/body crudos del server', () {
    final content = localizedNotificationContent(en, _n('task_assigned'));
    expect(content.title, 'Titulo server');
    expect(content.body, 'Cuerpo server');
  });

  test('tipo desconocido cae al title/body crudos', () {
    final content = localizedNotificationContent(
      en,
      _n('algo_nuevo', params: {'x': 1}),
    );
    expect(content.title, 'Titulo server');
  });

  test('task_assigned se localiza en EN con params', () {
    final content = localizedNotificationContent(
      en,
      _n(
        'task_assigned',
        params: {'actor_name': 'Ana', 'task_title': 'Lavar platos'},
      ),
    );
    expect(content.title, 'New task assigned');
    expect(content.body, 'Ana assigned you the task: Lavar platos');
  });

  test('task_approved usa coin_reward numerico', () {
    final content = localizedNotificationContent(
      es,
      _n(
        'task_approved',
        params: {'task_title': 'Baño', 'coin_reward': 3, 'xp_reward': 35},
      ),
    );
    expect(content.body, '"Baño" fue aprobada. Ganaste 3 coins.');
  });

  test('expense_added settlement usa el copy de deuda saldada', () {
    final content = localizedNotificationContent(
      en,
      _n(
        'expense_added',
        params: {
          'actor_name': 'Blas',
          'expense_title': 'Liquidacion de deuda',
          'amount': 1500,
          'kind': 'settlement',
        },
      ),
    );
    expect(content.title, 'Debt settled!');
    expect(content.body, contains('Blas settled their debt of'));
    expect(content.body, contains('1,500'));
  });

  test('expense_added groceries usa el verbo de compra', () {
    final content = localizedNotificationContent(
      es,
      _n(
        'expense_added',
        params: {
          'actor_name': 'Ana',
          'expense_title': 'Coto',
          'amount': 200.5,
          'kind': 'groceries',
        },
      ),
    );
    expect(content.body, contains('compró en Coto'));
  });

  test('planned_payment_upcoming formatea fecha y monto', () {
    final content = localizedNotificationContent(
      en,
      _n(
        'planned_payment_upcoming',
        params: {
          'expense_title': 'Alquiler',
          'amount': 350000,
          'due_date': '2026-07-06',
        },
      ),
    );
    expect(content.title, 'Upcoming payment: Alquiler');
    expect(content.body, contains('Jul'));
    expect(content.body, contains('350,000'));
  });

  test('params incompletos caen al fallback en vez de renderizar huecos', () {
    final content = localizedNotificationContent(
      en,
      _n('task_assigned', params: {'actor_name': 'Ana'}),
    );
    expect(content.title, 'Titulo server');
  });
}
