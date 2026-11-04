/// Port for shopping lists, in-store sessions and the local product catalog.
library;

import '../shopping/shopping.dart';

abstract interface class ShoppingRepository {
  Future<List<ShoppingList>> lists({bool includeArchived = false});
  Future<ShoppingList?> list(String id);
  Stream<List<ShoppingList>> watchLists();
  Future<void> upsertList(ShoppingList list);
  Future<bool> deleteList(String id);

  Future<List<ShoppingSession>> sessions({int limit = 50});
  Future<ShoppingSession?> session(String id);
  Future<ShoppingSession?> activeSession();
  Future<void> upsertSession(ShoppingSession s);

  Future<List<Product>> products();
  Future<void> upsertProduct(Product p);
  Future<List<PriceObservation>> observations({String? productId});
  Future<void> addObservations(List<PriceObservation> obs);

  Future<void> purgeAll();
}
