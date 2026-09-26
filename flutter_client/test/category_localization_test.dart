import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/activity_presentation.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final es = lookupAppLocalizations(const Locale('es'));

  group('localizedCategoryName', () {
    test('claves de tareas en español, inglés o con tildes', () {
      expect(localizedCategoryName(en, 'cocina'), en.taskCategoryKitchen);
      expect(localizedCategoryName(en, 'kitchen'), en.taskCategoryKitchen);
      expect(localizedCategoryName(en, 'baño'), en.taskCategoryBathroom);
      expect(
        localizedCategoryName(en, 'Niños / cuidado'),
        en.taskCategoryKidsCare,
      );
      expect(
        localizedCategoryName(es, 'residuos'),
        es.taskCategoryTrashRecycling,
      );
    });

    test('claves de finanzas y alias viejos', () {
      expect(
        localizedCategoryName(en, 'supermarket'),
        en.expensesFormCategorySupermarket,
      );
      expect(
        localizedCategoryName(en, 'restaurants'),
        en.expensesFormCategoryRestaurants,
      );
      expect(
        localizedCategoryName(en, 'salary'),
        en.expensesFormIncomeCategorySalary,
      );
      expect(
        localizedCategoryName(en, 'transporte'),
        en.expensesFormCategoryTransport,
      );
    });

    test('una clave compartida se resuelve según el contexto', () {
      expect(
        localizedCategoryName(en, 'compras'),
        en.taskCategoryShoppingOrganization,
      );
      expect(
        localizedCategoryName(en, 'compras', preferFinance: true),
        en.expensesFormCategorySupermarket,
      );
    });

    test('claves genéricas o vacías', () {
      expect(localizedCategoryName(en, 'general'), en.categoryLabelHome);
      expect(localizedCategoryName(en, null), en.categoryLabelOther);
      expect(localizedCategoryName(es, ''), es.categoryLabelOther);
    });

    test('en inglés no se filtra el nombre en español', () {
      expect(localizedCategoryName(en, 'cocina'), 'Kitchen');
      expect(localizedCategoryName(en, 'supermarket'), 'Supermarket');
    });
  });

  group('activityDisplayTitle', () {
    test('un título que es solo la categoría se traduce', () {
      expect(
        activityDisplayTitle(en, 'Supermercado', 'supermarket'),
        en.expensesFormCategorySupermarket,
      );
      expect(
        activityDisplayTitle(en, 'cocina', 'cocina'),
        en.taskCategoryKitchen,
      );
    });

    test('en un gasto, una clave compartida es la de finanzas', () {
      expect(
        activityDisplayTitle(en, 'compras', 'compras', isExpense: true),
        en.expensesFormCategorySupermarket,
      );
      expect(
        activityDisplayTitle(en, 'compras', 'compras'),
        en.taskCategoryShoppingOrganization,
      );
      expect(
        localizedCategoryName(en, 'ropa', preferFinance: true),
        en.expensesFormCategoryClothing,
      );
    });

    test('los títulos reales no se tocan', () {
      expect(activityDisplayTitle(en, 'Netflix', 'entertainment'), 'Netflix');
      expect(
        activityDisplayTitle(en, 'Lavar los platos', 'cocina'),
        'Lavar los platos',
      );
      expect(
        activityDisplayTitle(en, '  ', 'cocina'),
        en.activityFallbackTitle,
      );
    });
  });
}
