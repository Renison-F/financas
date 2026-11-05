/// Icons offered when a category is created or edited, each with the words people search for.
library;

import 'icons.dart';

class CategoryIcon {
  const CategoryIcon(this.icon, this.keywords);
  final SIconName icon;

  /// Lower-case Portuguese words that describe the icon, used by the search.
  final String keywords;
}

const categoryIcons = <CategoryIcon>[
  CategoryIcon(SIconName.tag, 'etiqueta geral outros categoria'),
  CategoryIcon(SIconName.cart, 'mercado supermercado compras feira'),
  CategoryIcon(
    SIconName.food,
    'alimentação restaurante comida almoço jantar refeição',
  ),
  CategoryIcon(SIconName.coffee, 'café lanche padaria'),
  CategoryIcon(SIconName.glass, 'bar bebida festa balada'),
  CategoryIcon(SIconName.bag, 'compras loja shopping sacola'),
  CategoryIcon(SIconName.shirt, 'roupa vestuário moda'),
  CategoryIcon(SIconName.home, 'casa moradia aluguel lar'),
  CategoryIcon(SIconName.building, 'condomínio prédio apartamento imóvel'),
  CategoryIcon(SIconName.key, 'aluguel chave imóvel financiamento'),
  CategoryIcon(SIconName.flash, 'energia luz eletricidade conta de luz'),
  CategoryIcon(SIconName.drop, 'água saneamento conta de água'),
  CategoryIcon(SIconName.wifi, 'internet rede banda larga'),
  CategoryIcon(SIconName.phone, 'telefone celular plano recarga'),
  CategoryIcon(SIconName.tv, 'streaming televisão tv assinatura'),
  CategoryIcon(
    SIconName.wrench,
    'manutenção conserto reforma oficina ferramenta',
  ),
  CategoryIcon(
    SIconName.car,
    'carro transporte veículo automóvel estacionamento',
  ),
  CategoryIcon(SIconName.fuel, 'combustível gasolina posto etanol'),
  CategoryIcon(SIconName.bus, 'ônibus transporte público metrô passagem'),
  CategoryIcon(SIconName.bike, 'bicicleta moto entrega'),
  CategoryIcon(SIconName.plane, 'viagem passagem aérea avião férias'),
  CategoryIcon(SIconName.globe, 'viagem exterior internacional turismo'),
  CategoryIcon(SIconName.heart, 'saúde plano de saúde médico bem-estar'),
  CategoryIcon(SIconName.pill, 'farmácia remédio medicamento'),
  CategoryIcon(SIconName.dumbbell, 'academia esporte exercício treino'),
  CategoryIcon(SIconName.scissors, 'beleza cabelo barbearia salão estética'),
  CategoryIcon(SIconName.book, 'educação escola curso faculdade livro'),
  CategoryIcon(SIconName.person, 'pessoal filho criança cuidados'),
  CategoryIcon(SIconName.people, 'família dependentes filhos pensão'),
  CategoryIcon(SIconName.paw, 'pet animal veterinário cachorro gato'),
  CategoryIcon(SIconName.gift, 'presente doação aniversário'),
  CategoryIcon(SIconName.star, 'lazer diversão especial'),
  CategoryIcon(SIconName.smile, 'lazer diversão passeio'),
  CategoryIcon(SIconName.game, 'jogos videogame entretenimento'),
  CategoryIcon(SIconName.music, 'música show assinatura'),
  CategoryIcon(SIconName.film, 'cinema filme teatro'),
  CategoryIcon(SIconName.camera, 'fotografia foto eletrônicos'),
  CategoryIcon(SIconName.receipt, 'conta boleto assinatura fatura'),
  CategoryIcon(SIconName.document, 'imposto taxa documento cartório'),
  CategoryIcon(SIconName.percent, 'juros imposto taxa desconto'),
  CategoryIcon(SIconName.shield, 'seguro proteção previdência'),
  CategoryIcon(SIconName.card, 'cartão crédito anuidade'),
  CategoryIcon(SIconName.bank, 'banco salário tarifa'),
  CategoryIcon(SIconName.wallet, 'carteira salário dinheiro'),
  CategoryIcon(SIconName.coins, 'dinheiro moedas renda extra'),
  CategoryIcon(
    SIconName.briefcase,
    'trabalho salário emprego freelance negócio',
  ),
  CategoryIcon(SIconName.trending, 'rendimento investimento dividendos'),
  CategoryIcon(SIconName.chart, 'investimento aplicação bolsa'),
  CategoryIcon(SIconName.arrowUp, 'rendimento retorno'),
  CategoryIcon(SIconName.target, 'meta objetivo reserva'),
  CategoryIcon(SIconName.sparkle, 'extra bônus prêmio'),
  CategoryIcon(SIconName.swap, 'reembolso transferência troca'),
  CategoryIcon(SIconName.calendar, 'mensalidade parcela agenda'),
  CategoryIcon(SIconName.lock, 'segurança cofre'),
  CategoryIcon(SIconName.settings, 'serviços manutenção'),
  CategoryIcon(SIconName.more, 'outros diversos'),
];

/// Folds accents and case so that "agua" finds "água".
String foldForSearch(String s) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final i = from.indexOf(ch);
    b.write(i < 0 ? ch : to[i]);
  }
  return b.toString();
}

/// Icons whose keywords match [query]; the whole library when the query is empty.
List<CategoryIcon> searchCategoryIcons(String query) {
  final q = foldForSearch(query.trim());
  if (q.isEmpty) return categoryIcons;
  return categoryIcons
      .where((i) => foldForSearch(i.keywords).contains(q))
      .toList();
}

/// Colors offered for a category (hex, as stored). No purple, by design.
const categoryPalette = <String>[
  '#0B5563',
  '#2E7FA8',
  '#1F5F9E',
  '#176B4E',
  '#5B7F2B',
  '#A6791E',
  '#8A5200',
  '#C0703E',
  '#A93A29',
  '#B84E5E',
  '#7A5A44',
  '#4F5E61',
  '#74848A',
];
