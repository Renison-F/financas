/// Accent-insensitive normalization for Portuguese text (search, intent detection, duplicate matching).
library;

const _map = {
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'ñ': 'n',
};

String stripDiacritics(String s) {
  final sb = StringBuffer();
  for (final r in s.runes) {
    final ch = String.fromCharCode(r);
    sb.write(_map[ch] ?? ch);
  }
  return sb.toString();
}

String normalizeText(String s) => stripDiacritics(s.toLowerCase());

/// Number of single-character edits (insert, delete, replace) between two words.
int editDistance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var prev = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final cur = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      final del = prev[j] + 1, ins = cur[j - 1] + 1, sub = prev[j - 1] + cost;
      cur[j] = del < ins ? (del < sub ? del : sub) : (ins < sub ? ins : sub);
    }
    prev = cur;
  }
  return prev[b.length];
}

/// Whether [text] (already normalized) has a word equal or close to one of [words]: a typo of one
/// letter in a medium word, two in a long one. Short words must match exactly.
bool hasWordLike(String text, Iterable<String> words) {
  final tokens = text.split(RegExp(r'[^a-z0-9]+')).where((t) => t.isNotEmpty);
  for (final t in tokens) {
    for (final w in words) {
      final tolerance = w.length >= 8 ? 2 : (w.length >= 5 ? 1 : 0);
      if ((t.length - w.length).abs() > tolerance) continue;
      if (editDistance(t, w) <= tolerance) return true;
    }
  }
  return false;
}
