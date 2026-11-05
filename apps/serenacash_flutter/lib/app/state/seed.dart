import '../../domain/entities/entities.dart';

/// Default categories (icons from the app icon set; never emoji). Same set as the RN app.
List<Category> defaultCategories(String Function() newId, String now) {
  const rows = <(String, String, String, String)>[
    ('Alimentação', 'expense', 'food', '#C0703E'),
    ('Supermercado', 'expense', 'cart', '#C0703E'),
    ('Moradia', 'expense', 'home', '#0B5563'),
    ('Transporte', 'expense', 'car', '#4F5E61'),
    ('Saúde', 'expense', 'heart', '#176B4E'),
    ('Educação', 'expense', 'book', '#8A5200'),
    ('Lazer', 'expense', 'smile', '#A93A29'),
    ('Compras', 'expense', 'bag', '#74848A'),
    ('Assinaturas', 'expense', 'tv', '#0B5563'),
    ('Outros gastos', 'expense', 'more', '#4F5E61'),
    ('Salário', 'income', 'wallet', '#176B4E'),
    ('Trabalho extra', 'income', 'briefcase', '#176B4E'),
    ('Rendimentos', 'income', 'trending', '#176B4E'),
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
