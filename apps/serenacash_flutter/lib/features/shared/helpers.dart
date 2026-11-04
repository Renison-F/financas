import '../../app/app.dart';
import '../../domain/entities/entities.dart';
import '../../domain/money/money.dart';
import 'format.dart';

String formatBRLHidden(int cents, bool hidden) =>
    formatBRL(cents, hidden: hidden);
String kindLabelOf(AppLocalizations l, Transaction t) => kindLabel(l, t.kind);
