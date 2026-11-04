import React from 'react';
import { View } from 'react-native';
import { Screen, Card, Text, spacing } from '../design';
import { StackHeader } from '../features/shared/ScreenHeader';

const FAQ: [string, string][] = [
  ['O que é "pode gastar"?', 'Dinheiro nas contas consideradas, menos contas previstas até o fim do período (inclusive atrasadas), menos faturas de cartão em aberto, menos reservas guardadas dentro das contas e o colchão que você definir. Receitas previstas só entram no modo otimista. É uma estimativa, não um saldo.'],
  ['Compra no cartão conta duas vezes?', 'Não. A compra é despesa na data em que aconteceu (na categoria dela). Pagar a fatura só tira dinheiro da conta e abate a fatura.'],
  ['Como funciona a fatura?', 'Compras até o dia de fechamento entram na fatura do mês; depois, na seguinte. Parcelas caem uma por fatura. O vencimento é o dia que você cadastrou.'],
  ['O que é a marca de hoje?', 'Nas barras de orçamento, a pequena onda mostra onde o gasto deveria estar hoje (proporcional aos dias do mês). Antes dela: sereno. Até 10 pontos depois: atenção. Além disso ou acima do limite: agitado.'],
  ['Previsto × efetivado', 'Previsto é o que ainda vai acontecer (conta a pagar, salário a receber). Efetivado já aconteceu e altera o saldo. Pagamento parcial fica como "parcial" até completar.'],
  ['Reservas e metas', 'Guardar dinheiro numa meta tira o valor da conta de origem. Se a meta fica dentro de uma conta considerada, o valor guardado é descontado do "pode gastar" (quando protegida).'],
  ['Empréstimos', 'Tabela Price (parcela fixa) ou SAC (parcela decrescente), com taxa mensal sobre o saldo devedor. "Quitar hoje" é o valor presente das parcelas restantes à taxa do contrato, sem tarifas: uma estimativa para negociar.'],
  ['Supermercado', 'Código de barras identifica o produto, não o preço. O preço vem da etiqueta lida (OCR), do seu histórico ou de você. Nada é adicionado sem confirmação, e o total do carrinho usa arredondamento de balança.'],
  ['Meus dados', 'Tudo fica no aparelho. Exporte backups em Mais → Exportar. Apague tudo em Privacidade.'],
];

export default function HelpScreen() {
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Ajuda" />
      <Screen>
        <View style={{ gap: spacing.sm }}>{FAQ.map(([q, a]) => <Card key={q}><Text role="title">{q}</Text><Text role="body" color="textMuted" style={{ marginTop: 6 }}>{a}</Text></Card>)}</View>
      </Screen>
    </View>
  );
}
