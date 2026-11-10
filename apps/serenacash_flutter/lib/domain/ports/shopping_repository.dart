/// Port for shopping lists, in-store sessions and the local product catalog.
library;

import 'dart:typed_data';

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

  /// Evidence photos of a purchase. The bytes are stored encrypted, apart from what is listed.
  Future<void> saveEvidence(Evidence evidence, Uint8List bytes);
  Future<List<Evidence>> evidenceOf(String sessionId);
  Future<Uint8List?> evidenceBytes(String id);
  Future<void> deleteEvidence(String id);

  /// The item lines read from the receipt of a purchase, with how each was paired with the cart.
  Future<List<ReceiptLine>> receiptLines(String sessionId);
  Future<void> replaceReceiptLines(String sessionId, List<ReceiptLine> lines);

  Future<void> purgeAll();
}
