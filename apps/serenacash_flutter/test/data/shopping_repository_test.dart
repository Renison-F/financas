import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/data/database/drift_change_log.dart';
import 'package:serenacash/data/database/drift_shopping_repository.dart';
import 'package:serenacash/domain/ports/ports.dart';
import 'package:serenacash/domain/shopping/shopping.dart';

import '../fixtures/fixture_loader.dart';

void main() {
  late AppDatabase db;
  late DriftShoppingRepository repo;
  final clock = FixedClock('2026-11-04T12:00:00.000Z');
  setUp(() {
    db = AppDatabase.inMemory();
    repo = DriftShoppingRepository(db, clock: clock);
  });
  tearDown(() => db.close());

  test(
    'shopping list round-trips (items ordered, merge semantics preserved)',
    () async {
      final list = ShoppingList.fromJson(
        loadFixtures('shopping_lists')
                .firstWhere((c) => c.name == 'estimate')
                .inputMap['list']
            as Map<String, dynamic>,
      );
      await repo.upsertList(list);
      final back = (await repo.list(list.id))!;
      expect(
        jsonEquals(
          {...back.toJson()}..remove('updatedAt'),
          {...list.toJson()}..remove('updatedAt'),
        ),
        isTrue,
        reason: back.toJson().toString(),
      );
      expect(estimateList(back).toJson(), estimateList(list).toJson());
      expect((await repo.lists()).length, 1);
      expect(await repo.deleteList(list.id), isTrue);
      expect(await repo.lists(), isEmpty);
      expect(
        (await DriftChangeLog(
          db,
        ).forEntity(EntityTypes.shoppingList, list.id)).map((c) => c.op),
        ['upsert', 'delete'],
      );
    },
  );

  test(
    'session with lines, promo and events round-trips with identical totals',
    () async {
      final s = ShoppingSession.fromJson(
        loadFixtures('shopping_session')
                .firstWhere((c) => c.name == 'totals')
                .inputMap['session']
            as Map<String, dynamic>,
      );
      final withPromo = addToSession(
        s,
        const CartLine(
          id: 'p',
          name: 'Cerveja',
          unit: 'un',
          quantity: 6,
          unitPriceCents: 450,
          promo: Promo(6, 5),
          priceSource: 'manual',
          checked: true,
        ),
        clock.nowISO(),
      );
      await repo.upsertSession(withPromo);
      final back = (await repo.session(s.id))!;
      expect(
        jsonEquals(back.toJson(), withPromo.toJson()),
        isTrue,
        reason: back.toJson().toString(),
      );
      expect(sessionTotals(back).toJson(), sessionTotals(withPromo).toJson());
      expect((await repo.activeSession())!.id, s.id);
      final finished = finishSession(
        back,
        clock.nowISO(),
        SequentialIdGenerator('o').newId,
      );
      await repo.upsertSession(finished.session);
      await repo.upsertProduct(
        Product(
          id: 'p1',
          name: 'Arroz',
          internalCodes: const [InternalCode('Mercado Bom', '123456')],
          defaultUnit: 'un',
          favorite: false,
          createdAt: clock.nowISO(),
          updatedAt: clock.nowISO(),
        ),
      );
      await repo.addObservations(finished.observations);
      expect(await repo.activeSession(), isNull);
      expect(
        (await repo.observations(productId: 'p1')).length,
        finished.observations.length,
      );
      final products = await repo.products();
      expect(products.single.internalCodes.single.code, '123456');
      expect(
        priceHistory(await repo.observations(), 'p1').observations,
        finished.observations.length,
      );
    },
  );

  test(
    'observation referencing an unknown product is rejected by the foreign key',
    () async {
      await expectLater(
        repo.addObservations([
          PriceObservation(
            id: 'x',
            productId: 'ghost',
            unit: 'un',
            unitPriceCents: 1,
            observedAt: clock.nowISO(),
            source: 'manual',
          ),
        ]),
        throwsA(anything),
      );
      expect(await repo.observations(), isEmpty);
    },
  );
}
