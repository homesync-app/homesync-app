import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/settlement_confirm_dialog.dart';

/// Opens [SettlementConfirmDialog] via `showDialog` (so the dialog lives on its
/// own route and `Navigator.pop` works) and returns once it is on screen.
Future<void> _openDialog(
  WidgetTester tester, {
  required Future<void> Function() onConfirm,
  VoidCallback? onSettled,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => SettlementConfirmDialog(
                  titleText: 'Registrar equilibrio',
                  amountText: r'10.000 $',
                  directionText: 'Vos -> Pat',
                  bodyText: 'Esto va a dejar el balance del hogar en cero.',
                  confirmLabel: 'Registrar pago',
                  cancelLabel: 'Ahora no',
                  doneBadgeText: 'Listo',
                  errorTextBuilder: (m) =>
                      'No se pudo equilibrar el balance: $m',
                  onConfirm: onConfirm,
                  onSettled: onSettled,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('confirming a successful settle closes the dialog and runs '
      'onSettled', (tester) async {
    var settledCalls = 0;
    await _openDialog(
      tester,
      onConfirm: () async {},
      onSettled: () => settledCalls++,
    );

    expect(find.text('Registrar equilibrio'), findsOneWidget);

    await tester.tap(find.text('Registrar pago'));
    await tester.pump(); // submitting
    await tester.pump(); // onConfirm resolves → success badge
    await tester.pump(const Duration(milliseconds: 500)); // delay → pop
    await tester.pumpAndSettle();

    // The dialog is gone and the host side effect ran exactly once.
    expect(find.text('Registrar equilibrio'), findsNothing);
    expect(settledCalls, 1);
  });

  testWidgets('a failed settle shows the error INLINE and keeps the dialog open',
      (tester) async {
    var settledCalls = 0;
    await _openDialog(
      tester,
      onConfirm: () async =>
          throw const ServerFailure('El monto debe ser mayor a 0'),
      onSettled: () => settledCalls++,
    );

    await tester.tap(find.text('Registrar pago'));
    await tester.pumpAndSettle();

    // Error is visible inside the dialog (not a hidden background snackbar).
    expect(
      find.textContaining('El monto debe ser mayor a 0'),
      findsOneWidget,
    );
    // Dialog stayed open, the action reverted to its idle label, and the host
    // success side effect never ran.
    expect(find.text('Registrar equilibrio'), findsOneWidget);
    expect(find.text('Registrar pago'), findsOneWidget);
    expect(settledCalls, 0);
  });

  testWidgets('a very long error message never overflows the dialog',
      (tester) async {
    final longMessage = 'Línea de error larguísima. ' * 40;
    await _openDialog(
      tester,
      onConfirm: () async => throw ServerFailure(longMessage),
    );

    await tester.tap(find.text('Registrar pago'));
    await tester.pumpAndSettle();

    // The bounded + scrollable error box must absorb the overflow.
    expect(tester.takeException(), isNull);
    expect(find.text('Registrar equilibrio'), findsOneWidget);
  });
}
