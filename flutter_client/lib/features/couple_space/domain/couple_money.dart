import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';

/// Hacia dónde está el saldo entre los dos.
enum CoupleBalanceDirection { even, iOwe, theyOwe }

/// El saldo leído desde el lado de quien mira.
///
/// Mismo umbral que usa el Home para ofrecer "Saldar": por debajo de unos
/// pesos la diferencia es redondeo, no una deuda que valga la pena registrar.
class CoupleBalanceView {
  static const double evenThreshold = 10;

  final CoupleBalanceDirection direction;

  /// Siempre positivo; la dirección dice quién le debe a quién.
  final double amount;

  const CoupleBalanceView._(this.direction, this.amount);

  /// [myBalance] es el balance del usuario actual en `expenseBalancesProvider`:
  /// negativo cuando le debe a su pareja, positivo cuando le deben a él.
  factory CoupleBalanceView.fromMyBalance(double myBalance) {
    if (myBalance.abs() <= evenThreshold) {
      return const CoupleBalanceView._(CoupleBalanceDirection.even, 0);
    }
    return CoupleBalanceView._(
      myBalance < 0 ? CoupleBalanceDirection.iOwe : CoupleBalanceDirection.theyOwe,
      myBalance.abs(),
    );
  }

  bool get isEven => direction == CoupleBalanceDirection.even;
}

/// Cuánto puso cada uno en el mes en curso.
class CoupleMonthMoney {
  final double mePaid;
  final double partnerPaid;

  const CoupleMonthMoney({required this.mePaid, required this.partnerPaid});

  static const CoupleMonthMoney zero =
      CoupleMonthMoney(mePaid: 0, partnerPaid: 0);

  double get total => mePaid + partnerPaid;
  bool get isEmpty => total <= 0;

  /// Proporción pagada por el usuario actual, acotada a [0,1].
  double get myShare => total <= 0 ? 0 : (mePaid / total).clamp(0.0, 1.0);
}

/// Suma lo que pagó cada uno en el mes de [now].
///
/// Solo cuentan gastos reales: ni ingresos ni liquidaciones (una liquidación
/// devuelve plata de un gasto que ya contó). Con economía dividida también se
/// excluyen los gastos personales y regalos, que no son del hogar; con
/// economía integrada ([includePersonal]) todo gasto es de los dos, igual que
/// el total del Home.
CoupleMonthMoney computeCoupleMonthMoney({
  required Iterable<FeedItemModel> feed,
  required DateTime now,
  required String? currentUserId,
  required String? partnerId,
  bool includePersonal = false,
}) {
  var mine = 0.0;
  var theirs = 0.0;

  for (final item in feed) {
    if (!item.isRealExpense || item.transactionType != 'expense') continue;
    if (item.date.year != now.year || item.date.month != now.month) continue;
    if (!includePersonal) {
      final split = (item.splitType ?? 'equal').toLowerCase();
      if (split == 'personal' || split == 'gift') continue;
    }
    if (item.payerId.isEmpty) continue;

    if (currentUserId != null && item.payerId == currentUserId) {
      mine += item.amount;
    } else if (partnerId != null && item.payerId == partnerId) {
      theirs += item.amount;
    }
  }

  return CoupleMonthMoney(mePaid: mine, partnerPaid: theirs);
}
