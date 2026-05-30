import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/providers/home_bootstrap_provider.dart';

void main() {
  group('BootstrapSeedGate', () {
    setUp(() => BootstrapSeedGate.instance.reset());

    test('consume returns true exactly once per section', () {
      final gate = BootstrapSeedGate.instance;

      // First consume of a section uses the cached snapshot.
      expect(gate.consume(BootstrapSection.profile), isTrue);
      // Every subsequent build falls through to a fresh fetch.
      expect(gate.consume(BootstrapSection.profile), isFalse);
      expect(gate.consume(BootstrapSection.profile), isFalse);
    });

    test('sections are tracked independently', () {
      final gate = BootstrapSeedGate.instance;

      expect(gate.consume(BootstrapSection.profile), isTrue);
      // Consuming profile must not gate userBalance.
      expect(gate.consume(BootstrapSection.userBalance), isTrue);
      expect(gate.consume(BootstrapSection.profile), isFalse);
      expect(gate.consume(BootstrapSection.userBalance), isFalse);
    });

    test('reset re-arms every section so a new snapshot can re-seed', () {
      final gate = BootstrapSeedGate.instance;

      expect(gate.consume(BootstrapSection.members), isTrue);
      expect(gate.consume(BootstrapSection.members), isFalse);

      // A fresh bootstrap load resets the gate.
      gate.reset();

      expect(gate.consume(BootstrapSection.members), isTrue);
    });

    test('all sections start un-consumed', () {
      final gate = BootstrapSeedGate.instance;
      for (final section in BootstrapSection.values) {
        expect(
          gate.consume(section),
          isTrue,
          reason: 'section $section should seed once after reset',
        );
      }
    });
  });
}
