import 'dart:async';

import 'package:drift/drift.dart';

/// Emits [load] once on listen and again after every matching table update. Implemented with an
/// explicit controller (not `async*`) so cancelling never waits on an idle update stream.
Stream<T> watchQuery<T>(
  GeneratedDatabase db,
  TableUpdateQuery query,
  Future<T> Function() load,
) {
  late StreamController<T> controller;
  StreamSubscription<Set<TableUpdate>>? sub;
  var running = false;
  var pending = false;
  Future<void> emit() async {
    if (running) {
      pending = true;
      return;
    }
    running = true;
    try {
      do {
        pending = false;
        final v = await load();
        if (!controller.isClosed) controller.add(v);
      } while (pending);
    } catch (e, st) {
      if (!controller.isClosed) controller.addError(e, st);
    } finally {
      running = false;
    }
  }

  controller = StreamController<T>(
    onListen: () {
      emit();
      sub = db.tableUpdates(query).listen((_) => emit());
    },
    onCancel: () async {
      await sub?.cancel();
      await controller.close();
    },
  );
  return controller.stream;
}
