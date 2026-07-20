import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/dashboard/data/repositories/supabase_dashboard_repository.dart';

// La firma decide si el stream del feed reemite: dos listas con la misma firma
// son visualmente identicas y el poll de respaldo (cada 15-60s) no debe
// propagar una lista nueva que reconstruya el Home visible.
void main() {
  Map<String, dynamic> activity(String id, {String type = 'task'}) => {
        'id': id,
        'type': type,
        'created_at': '2026-07-19T12:00:00Z',
        'data': {'title': 'Lavar los platos'},
      };

  test('misma lista produce la misma firma (el poll no reemite)', () {
    final a = [activity('1'), activity('2', type: 'expense')];
    final b = [activity('1'), activity('2', type: 'expense')];
    expect(recentActivitySignature(a), recentActivitySignature(b));
  });

  test('una actividad nueva cambia la firma', () {
    final base = [activity('1')];
    final withNew = [activity('2'), activity('1')];
    expect(
      recentActivitySignature(base),
      isNot(recentActivitySignature(withNew)),
    );
  });

  test('una baja cambia la firma', () {
    final base = [activity('1'), activity('2')];
    expect(
      recentActivitySignature(base),
      isNot(recentActivitySignature([activity('1')])),
    );
  });

  test('reordenar cambia la firma (el orden es visible en el feed)', () {
    final ab = [activity('1'), activity('2')];
    final ba = [activity('2'), activity('1')];
    expect(recentActivitySignature(ab), isNot(recentActivitySignature(ba)));
  });

  test('lista vacia tiene firma estable', () {
    expect(recentActivitySignature(const []), recentActivitySignature(const []));
  });
}
