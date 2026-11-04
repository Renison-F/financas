import '../../domain/entities/entities.dart';

/// Default categories (icons from the app icon set; never emoji). Same set as the RN app.
List<Category> defaultCategories(String Function() newId, String now) {
  const rows = <(String, String, String, String)>[
    ('Alimentação', 'expense', 'cart', '#C0703E'),
    ('Supermercado', 'expense', 'cart', '#C0703E'),
    ('Moradia', 'expense', 'home', '#0B5563'),
    ('Transporte', 'expense', 'swap', '#4F5E61'),
    ('Saúde', 'expense', 'plus', '#176B4E'),
    ('Educação', 'expense', 'list', '#8A5200'),
    ('Lazer', 'expense', 'star', '#A93A29'),
    ('Compras', 'expense', 'tag', '#74848A'),
    ('Assinaturas', 'expense', 'receipt', '#0B5563'),
    ('Outros gastos', 'expense', 'more', '#4F5E61'),
    ('Salário', 'income', 'bank', '#176B4E'),
    ('Trabalho extra', 'income', 'sparkle', '#176B4E'),
    ('Rendimentos', 'income', 'arrow-up', '#176B4E'),
    ('Reembolsos', 'income', 'swap', '#176B4E'),
    ('Outras receitas', 'income', 'more', '#176B4E'),
  ];
  return [
    for (var i = 0; i < rows.length; i++)
      Category(
        id: newId(),
        name: rows[i].$1,
        kind: rows[i].$2,
        icon: rows[i].$3,
        color: rows[i].$4,
        archived: false,
        sortOrder: i,
        createdAt: now,
        updatedAt: now,
      ),
  ];
}
