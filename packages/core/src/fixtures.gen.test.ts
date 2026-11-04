/**
 * Generates reference fixtures (JSON) from the TypeScript domain so the Dart implementation can be checked
 * for exact equivalence. Run: pnpm --filter @financas/core test -- fixtures.gen
 * Output: docs/flutter-migration/fixtures/*.json (committed) — each case has inputs, expected output and a note.
 */
import { it } from 'vitest';
import { writeFileSync, mkdirSync } from 'node:fs';
import { resolve } from 'node:path';
import { cents, addCents, mulCents, divCents, allocate, parseMoneyBR, formatBRL, percentOf } from './money/money';
import { addMonthsClamped, addDays, daysInMonth, diffDays, weekdayOf, lastMonthKeys, monthKeyToDate, endOfMonth } from './dates/dates';
import { accountBalance, consolidatedBalance, monthTotals, overdue, upcoming } from './domain/ledger';
import { invoiceMonthFor, invoiceDueDate, invoice, cardCommitment, planInstallments } from './domain/cards';
import { occurrencesBetween, nextOccurrence } from './domain/recurrence';
import { availability } from './domain/availability';
import { budgetsForMonth, spentInMonth, pace, monthElapsedPercent } from './domain/budgets';
import { goalProgress } from './domain/goals';
import { buildSchedule, priceInstallment, loanPosition, simulateExtraPayment, payoffValue } from './domain/loans';
import { expensesByCategory, cashflow, compareMonths, yearSummary, recurringExpenses, projectBalance, netWorth, searchTransactions } from './domain/reports';
import { detectIntent, answer, recommendations } from './domain/assistant';
import { resolveAccess, withinLimit, mergeEntitlements, type Entitlement } from './billing/entitlements';
import { normalizeLayout, applyPreset, moveWidgetBy, hideWidget, showWidget, DEFAULT_LAYOUT, WIDGET_IDS } from './dashboard/widgets';
import { parseCSV, guessColumnMapping, candidatesFromCSV, parseDateFlexible, exportTransactionsCSV } from './io/csv';
import { parseOFX, candidatesFromOFX } from './io/ofx';
import { findDuplicates, textSimilarity } from './io/duplicates';
import { importLegacyBackup } from './io/legacy';
import { mergeEntity } from './sync/model';
import { account, card, category, goal, ledger, loan, tx, budget } from './domain/test-helpers';

const OUT = resolve(__dirname, '../../../docs/flutter-migration/fixtures');
const write = (name: string, cases: unknown[]) => { mkdirSync(OUT, { recursive: true }); writeFileSync(resolve(OUT, `${name}.json`), JSON.stringify({ generatedFrom: 'packages/core (TypeScript) @ ae2c229', cases }, null, 2)); };
const c = (name: string, input: unknown, expected: unknown, note = '') => ({ name, input, expected, note });

it('generates fixtures', () => {
  // ---- money ----
  write('money', [
    c('cents from decimal', { amount: 24.9 }, cents(24.9)), c('cents float noise', { amount: 0.1 + 0.2 }, cents(0.1 + 0.2)), c('cents negative', { amount: -5.49 }, cents(-5.49)),
    ...[[1000, 0.125, 'half-even'], [1005, 0.5, 'half-even'], [1015, 0.5, 'half-even'], [699, 1.5, 'half-even'], [699, 1.5, 'half-up'], [1005, 0.5, 'half-up'], [-1005, 0.5, 'half-up'], [-1005, 0.5, 'half-even'], [333, 3, 'down'], [12345, 0.0199, 'half-up']].map(([a, f, m]) => c(`mul ${a}x${f} ${m}`, { cents: a, factor: f, mode: m }, mulCents(a as number, f as number, m as never))),
    c('div 1000/3', { cents: 1000, divisor: 3 }, divCents(1000, 3)), c('percentOf 999 33.33', { cents: 999, percent: 33.33 }, percentOf(999, 33.33)),
    ...[[10000, 3, 'first'], [10000, 3, 'last'], [100, 3, 'first'], [5, 10, 'first'], [-10000, 3, 'first'], [777, 1, 'first'], [123457, 7, 'first'], [123457, 60, 'first']].map(([t, n, r]) => c(`allocate ${t}/${n} ${r}`, { total: t, n, remainderOn: r }, allocate(t as number, n as number, r as never))),
    ...['R$ 1.234,56', '1234,56', '24,9', '24', '-R$ 5,00', 'R$ -5,00', ' 0,05 ', '1234.56', '1,234.56', '', 'abc', '1,2,3', '1.234', '1.234.567,89', '12.5'].map((s) => c(`parse "${s}"`, { text: s }, parseMoneyBR(s))),
    ...[123456, -500, 0, 1, 99, 100000000].map((v) => c(`format ${v}`, { cents: v }, formatBRL(v))), c('format hidden', { cents: 123456, hidden: true }, formatBRL(123456, { hidden: true })),
    c('add overflow-safe', { a: 1, b: 2 }, addCents(1, 2)),
  ]);
  // ---- dates ----
  write('dates', [
    ...[['2026-01-31', 1], ['2024-01-31', 1], ['2026-01-31', 2], ['2026-11-15', 2], ['2026-03-31', -1], ['2026-01-31', 13], ['2024-02-29', 12]].map(([d, m]) => c(`addMonthsClamped ${d} ${m}`, { date: d, months: m }, addMonthsClamped(d as string, m as number))),
    c('addMonthsClamped anchor 31 +2', { date: '2026-01-31', months: 2, anchorDay: 31 }, addMonthsClamped('2026-01-31', 2, 31)), c('addMonthsClamped anchor 31 +1 from feb', { date: '2026-02-28', months: 1, anchorDay: 31 }, addMonthsClamped('2026-02-28', 1, 31)),
    ...[['2026-12-31', 1], ['2026-03-01', -1], ['2026-11-01', 0], ['2026-10-31', 30], ['2026-02-28', 1], ['2024-02-28', 1]].map(([d, n]) => c(`addDays ${d} ${n}`, { date: d, days: n }, addDays(d as string, n as number))),
    c('daysInMonth 2026-02', { year: 2026, month: 2 }, daysInMonth(2026, 2)), c('daysInMonth 2024-02', { year: 2024, month: 2 }, daysInMonth(2024, 2)), c('daysInMonth 2100-02', { year: 2100, month: 2 }, daysInMonth(2100, 2)),
    c('diffDays', { from: '2026-01-01', to: '2026-01-31' }, diffDays('2026-01-01', '2026-01-31')), c('diffDays negative', { from: '2026-03-01', to: '2026-02-01' }, diffDays('2026-03-01', '2026-02-01')), c('diffDays across DST and year', { from: '2025-10-15', to: '2026-03-15' }, diffDays('2025-10-15', '2026-03-15')),
    c('weekday 2026-11-04', { date: '2026-11-04' }, weekdayOf('2026-11-04')), c('lastMonthKeys', { end: '2026-02', n: 3 }, lastMonthKeys('2026-02', 3)), c('monthKeyToDate clamp', { key: '2026-02', day: 31 }, monthKeyToDate('2026-02', 31)), c('endOfMonth', { key: '2026-11' }, endOfMonth('2026-11')),
  ]);
  // ---- ledger ----
  const a = account({ id: 'a', openingBalanceCents: 100000 }); const b = account({ id: 'b' }); const cc = card({ id: 'c' });
  const L1 = ledger({ accounts: [a, b], cards: [cc], transactions: [
    tx({ id: 't1', kind: 'income', amountCents: 300000, date: '2026-11-05', accountId: 'a' }), tx({ id: 't2', kind: 'expense', amountCents: 5000, date: '2026-11-06', accountId: 'a' }),
    tx({ id: 't3', kind: 'expense', amountCents: 9999, date: '2026-11-07', accountId: 'a', status: 'planned' }), tx({ id: 't4', kind: 'transfer', amountCents: 50000, date: '2026-11-08', accountId: 'a', toAccountId: 'b' }),
    tx({ id: 't5', kind: 'card_purchase', amountCents: 20000, date: '2026-11-09', cardId: 'c' }), tx({ id: 't6', kind: 'card_payment', amountCents: 20000, date: '2026-11-27', accountId: 'a', cardId: 'c', invoiceMonth: '2026-11' }),
    tx({ id: 't7', kind: 'expense', amountCents: 10000, date: '2026-11-10', accountId: 'b', status: 'partially_paid', paidCents: 4000 }), tx({ id: 't8', kind: 'expense', amountCents: 777, date: '2026-11-11', accountId: 'a', status: 'cancelled' }),
    tx({ id: 't9', kind: 'balance_adjustment', amountCents: 100, date: '2026-11-12', toAccountId: 'b' }), tx({ id: 't10', kind: 'goal_deposit', amountCents: 1000, date: '2026-11-13', accountId: 'a', toAccountId: 'a', goalId: 'g' }),
    tx({ id: 'late', kind: 'expense', amountCents: 100, date: '2026-10-28', dueDate: '2026-10-30', status: 'planned', accountId: 'a' }),
  ] });
  write('ledger', [
    c('ledger L1', { ledger: L1 }, { balanceA: accountBalance(L1, 'a'), balanceB: accountBalance(L1, 'b'), balanceA_asOf_1105: accountBalance(L1, 'a', '2026-11-05'), consolidated: consolidatedBalance(L1), monthTotals: monthTotals(L1, '2026-11'), overdueIds: overdue(L1, '2026-11-04').map((t) => t.id), upcomingIds: upcoming(L1, '2026-11-04', '2026-11-30').map((t) => t.id) }, 'transfer neutral; card payment is not an expense; partial counts paid part; same-account goal deposit is neutral'),
  ]);
  // ---- cards ----
  const k = card({ id: 'k', closingDay: 20, dueDay: 27, limitCents: 100000 }); const k2 = card({ id: 'k2', closingDay: 28, dueDay: 5 });
  const L2 = ledger({ accounts: [a], cards: [k], transactions: [
    tx({ id: 'p1', kind: 'card_purchase', amountCents: 10000, date: '2026-10-15', cardId: 'k' }), tx({ id: 'p2', kind: 'card_purchase', amountCents: 5000, date: '2026-10-25', cardId: 'k' }), tx({ id: 'p3', kind: 'card_purchase', amountCents: 7000, date: '2026-11-03', cardId: 'k' }),
    tx({ id: 'p4', kind: 'card_purchase', amountCents: 3000, date: '2026-11-03', cardId: 'k', invoiceMonth: '2027-01' }), tx({ id: 'pay1', kind: 'card_payment', amountCents: 10000, date: '2026-10-27', cardId: 'k', accountId: 'a', invoiceMonth: '2026-10' }), tx({ id: 'pay2', kind: 'card_payment', amountCents: 2000, date: '2026-11-27', cardId: 'k', accountId: 'a', invoiceMonth: '2026-11' }),
  ] });
  const strip = (inv: ReturnType<typeof invoice>) => ({ ...inv, purchases: inv.purchases.map((t) => t.id), payments: inv.payments.map((t) => t.id) });
  write('cards', [
    ...[['2026-11-20'], ['2026-11-21'], ['2026-12-31'], ['2026-02-28']].map(([d]) => c(`invoiceMonthFor closing20 ${d}`, { closingDay: 20, date: d }, invoiceMonthFor(k, d!))),
    c('invoiceDueDate k 2026-11', { closingDay: 20, dueDay: 27, month: '2026-11' }, invoiceDueDate(k, '2026-11')), c('invoiceDueDate k2 2026-11', { closingDay: 28, dueDay: 5, month: '2026-11' }, invoiceDueDate(k2, '2026-11')), c('invoiceDueDate day31 feb', { closingDay: 10, dueDay: 31, month: '2026-02' }, invoiceDueDate(card({ closingDay: 10, dueDay: 31 }), '2026-02')),
    ...[['2026-10', '2026-11-04'], ['2026-11', '2026-11-04'], ['2026-11', '2026-11-22'], ['2026-11', '2026-11-28'], ['2027-01', '2026-11-04']].map(([m, t]) => c(`invoice ${m} today ${t}`, { ledger: L2, cardId: 'k', month: m, today: t }, strip(invoice(L2, k, m!, t!)))),
    c('cardCommitment 2026-11-04', { ledger: L2, cardId: 'k', today: '2026-11-04' }, cardCommitment(L2, k, '2026-11-04')), c('cardCommitment 2026-11-28', { ledger: L2, cardId: 'k', today: '2026-11-28' }, cardCommitment(L2, k, '2026-11-28')),
    ...[[100000, 3, '2026-11-25', 0], [9000, 3, '2026-01-31', 1], [100, 3, '2026-11-20', 0], [123457, 12, '2026-11-21', 0]].map(([t, n, d, o]) => c(`planInstallments ${t}/${n} ${d} +${o}`, { totalCents: t, count: n, purchaseDate: d, closingDay: 20, firstInvoiceOffsetMonths: o }, planInstallments({ totalCents: t as number, count: n as number, purchaseDate: d as string, card: k, firstInvoiceOffsetMonths: o as number }))),
  ]);
  // ---- recurrence ----
  write('recurrence', [
    c('monthly from 31', { rule: { id: 'r', frequency: 'monthly', startDate: '2026-01-31' }, from: '2026-01-01', to: '2026-05-31' }, occurrencesBetween({ id: 'r', frequency: 'monthly', startDate: '2026-01-31' }, '2026-01-01', '2026-05-31')),
    c('monthly count 3', { rule: { id: 'r', frequency: 'monthly', startDate: '2026-01-10', count: 3 }, from: '2026-01-01', to: '2027-01-01' }, occurrencesBetween({ id: 'r', frequency: 'monthly', startDate: '2026-01-10', count: 3 }, '2026-01-01', '2027-01-01')),
    c('weekly endDate', { rule: { id: 'r', frequency: 'weekly', startDate: '2026-01-01', endDate: '2026-01-20' }, from: '2026-01-01', to: '2026-03-01' }, occurrencesBetween({ id: 'r', frequency: 'weekly', startDate: '2026-01-01', endDate: '2026-01-20' }, '2026-01-01', '2026-03-01')),
    c('yearly leap', { rule: { id: 'r', frequency: 'yearly', startDate: '2024-02-29' }, from: '2024-01-01', to: '2026-12-31' }, occurrencesBetween({ id: 'r', frequency: 'yearly', startDate: '2024-02-29' }, '2024-01-01', '2026-12-31')),
    c('biweekly window', { rule: { id: 'r', frequency: 'biweekly', startDate: '2026-01-01' }, from: '2026-01-20', to: '2026-02-20' }, occurrencesBetween({ id: 'r', frequency: 'biweekly', startDate: '2026-01-01' }, '2026-01-20', '2026-02-20')),
    c('quarterly', { rule: { id: 'r', frequency: 'quarterly', startDate: '2026-01-15' }, from: '2026-01-01', to: '2026-12-31' }, occurrencesBetween({ id: 'r', frequency: 'quarterly', startDate: '2026-01-15' }, '2026-01-01', '2026-12-31')),
    c('next after', { rule: { id: 'r', frequency: 'monthly', startDate: '2026-01-05' }, after: '2026-11-04' }, nextOccurrence({ id: 'r', frequency: 'monthly', startDate: '2026-01-05' }, '2026-11-04')),
    c('next ended', { rule: { id: 'r', frequency: 'monthly', startDate: '2026-01-05', count: 2 }, after: '2026-11-04' }, nextOccurrence({ id: 'r', frequency: 'monthly', startDate: '2026-01-05', count: 2 }, '2026-11-04')),
  ]);
  // ---- availability ----
  const av1 = account({ id: 'a', openingBalanceCents: 200000 }); const avs = account({ id: 's', openingBalanceCents: 100000, includeInAvailability: false }); const avc = card({ id: 'c', closingDay: 20, dueDay: 27 });
  const L3 = ledger({ accounts: [av1, avs], cards: [avc], goals: [goal({ id: 'g', reserved: true }), goal({ id: 'g2', reserved: true, accountId: 'a' })], transactions: [
    tx({ kind: 'expense', amountCents: 30000, date: '2026-11-10', accountId: 'a', status: 'planned' }), tx({ kind: 'expense', amountCents: 5000, date: '2026-10-30', accountId: 'a', status: 'planned' }), tx({ kind: 'expense', amountCents: 99999, date: '2026-12-05', accountId: 'a', status: 'planned' }),
    tx({ kind: 'income', amountCents: 400000, date: '2026-11-25', accountId: 'a', status: 'planned' }), tx({ kind: 'card_purchase', amountCents: 25000, date: '2026-11-02', cardId: 'c' }),
    tx({ kind: 'goal_deposit', amountCents: 50000, date: '2026-09-01', accountId: 'a', goalId: 'g' }), tx({ kind: 'goal_deposit', amountCents: 20000, date: '2026-09-02', accountId: 'a', toAccountId: 'a', goalId: 'g2' }),
  ] });
  write('availability', [
    c('prudent', { ledger: L3, today: '2026-11-04' }, availability(L3, { today: '2026-11-04' })), c('optimistic cushion', { ledger: L3, today: '2026-11-04', includePlannedIncome: true, safetyCushionCents: 10000 }, availability(L3, { today: '2026-11-04', includePlannedIncome: true, safetyCushionCents: 10000 })),
    c('horizon 30d', { ledger: L3, today: '2026-11-10', horizonEnd: '2026-12-10' }, availability(L3, { today: '2026-11-10', horizonEnd: '2026-12-10' })), c('empty', { ledger: ledger(), today: '2026-11-04' }, availability(ledger(), { today: '2026-11-04' })),
  ]);
  // ---- budgets & goals ----
  const food = category({ id: 'food', name: 'Alimentação' }); const market = category({ id: 'market', name: 'Supermercado', parentId: 'food' });
  const L4 = ledger({ categories: [food, market], cards: [cc], budgets: [budget({ id: 'b1', categoryId: 'food', limitCents: 100000 }), budget({ id: 'b2', categoryId: 'food', limitCents: 120000, month: '2026-12' }), budget({ id: 'g', limitCents: 300000 })], transactions: [
    tx({ kind: 'expense', amountCents: 20000, date: '2026-11-02', categoryId: 'food' }), tx({ kind: 'card_purchase', amountCents: 30000, date: '2026-11-03', categoryId: 'market', cardId: 'c' }), tx({ kind: 'expense', amountCents: 10000, date: '2026-11-20', categoryId: 'food', status: 'planned' }), tx({ kind: 'expense', amountCents: 5000, date: '2026-11-20', categoryId: 'food', status: 'partially_paid', paidCents: 2000 }),
  ] });
  const bs = budgetsForMonth(L4, '2026-11', '2026-11-15').map((s) => ({ ...s, budget: s.budget.id, category: s.category?.id }));
  write('budgets', [c('spentInMonth food', { ledger: L4, month: '2026-11', categoryId: 'food' }, spentInMonth(L4, '2026-11', 'food')), c('budgetsForMonth 2026-11 @15', { ledger: L4, month: '2026-11', today: '2026-11-15' }, bs), c('budgetsForMonth 2026-12', { ledger: L4, month: '2026-12', today: '2026-12-01' }, budgetsForMonth(L4, '2026-12', '2026-12-01').map((s) => ({ ...s, budget: s.budget.id, category: s.category?.id }))),
    ...[[30, 50], [55, 50], [61, 50], [101, 100], [50, 50], [60, 50], [60.1, 50]].map(([u, e]) => c(`pace ${u} vs ${e}`, { used: u, expected: e }, pace(u!, e!))), c('monthElapsed after', { month: '2026-11', today: '2026-12-01' }, monthElapsedPercent('2026-11', '2026-12-01')), c('monthElapsed before', { month: '2026-11', today: '2026-10-01' }, monthElapsedPercent('2026-11', '2026-10-01')), c('monthElapsed mid', { month: '2026-11', today: '2026-11-15' }, monthElapsedPercent('2026-11', '2026-11-15'))]);
  const g = goal({ id: 'g', targetCents: 120000, targetDate: '2027-05-04', createdAt: '2026-11-04T00:00:00.000Z' });
  const L5 = ledger({ goals: [g], transactions: [tx({ kind: 'goal_deposit', amountCents: 20000, date: '2026-11-04', goalId: 'g' }), tx({ kind: 'goal_withdrawal', amountCents: 5000, date: '2026-11-05', goalId: 'g' })] });
  write('goals', [c('progress', { ledger: L5, goalId: 'g', today: '2026-11-05' }, { ...goalProgress(L5, g, '2026-11-05'), goal: 'g' })]);
  // ---- loans ----
  const l1 = loan({ id: 'l', principalCents: 1000000, monthlyRatePercent: 2, termMonths: 12, firstDueDate: '2026-01-10' });
  const lsac = loan({ principalCents: 1200000, monthlyRatePercent: 1, termMonths: 12, system: 'sac', firstDueDate: '2026-12-10' });
  const lfee = loan({ principalCents: 100000, monthlyRatePercent: 0, termMonths: 2, firstDueDate: '2026-12-10', monthlyFeeCents: 500, upfrontFeesCents: 1000 });
  const L6 = ledger({ loans: [l1], transactions: [tx({ kind: 'loan_payment', amountCents: 94560, date: '2026-01-10', loanId: 'l' }), tx({ kind: 'loan_payment', amountCents: 94560, date: '2026-02-10', loanId: 'l' }), tx({ kind: 'loan_payment', amountCents: 10000, date: '2026-02-11', loanId: 'l' })] });
  const pos = loanPosition(L6, l1, '2026-04-15');
  write('loans', [
    ...[[1000000, 2, 12], [1200000, 0, 12], [5000000, 1.99, 48], [123456, 3.5, 7]].map(([p, r, n]) => c(`price ${p} ${r}% ${n}`, { principalCents: p, monthlyRatePercent: r, n }, priceInstallment(p!, r!, n!))),
    c('schedule price', { loan: l1 }, buildSchedule(l1)), c('schedule sac', { loan: lsac }, buildSchedule(lsac)), c('schedule fees', { loan: lfee }, buildSchedule(lfee)), c('schedule price 2.5% 36', { loan: loan({ principalCents: 2500000, monthlyRatePercent: 2.5, termMonths: 36, firstDueDate: '2026-01-31' }) }, buildSchedule(loan({ principalCents: 2500000, monthlyRatePercent: 2.5, termMonths: 36, firstDueDate: '2026-01-31' }))),
    c('position', { ledger: L6, loanId: 'l', today: '2026-04-15' }, { ...pos, loan: 'l', schedule: undefined, nextDue: pos.nextDue?.number, overdueInstallments: pos.overdueInstallments.map((r) => r.number) }),
    c('payoffValue slice 2', { loanId: 'l', from: 2, rate: 2, today: '2026-03-10' }, payoffValue(buildSchedule(l1).slice(2), 2, '2026-03-10')),
    c('extra reduce_installment', { outstanding: 500000, extra: 100000, remaining: 6, mode: 'reduce_installment' }, simulateExtraPayment(l1, 500000, 100000, 6, 'reduce_installment')), c('extra reduce_term', { outstanding: 500000, extra: 100000, remaining: 6, mode: 'reduce_term' }, simulateExtraPayment(l1, 500000, 100000, 6, 'reduce_term')), c('extra payoff', { outstanding: 500000, extra: 600000, remaining: 6, mode: 'reduce_term' }, simulateExtraPayment(l1, 500000, 600000, 6, 'reduce_term')),
  ]);
  // ---- reports ----
  const rent = category({ id: 'rent', name: 'Moradia' }); const ra = account({ id: 'a', openingBalanceCents: 100000, openingDate: '2026-01-01' }); const rc = card({ id: 'c', closingDay: 20, dueDay: 27 });
  const L7 = ledger({ accounts: [ra], cards: [rc], categories: [food, market, rent], loans: [loan({ id: 'l', principalCents: 100000, monthlyRatePercent: 0, termMonths: 10, firstDueDate: '2026-12-10' })], transactions: [
    tx({ id: 'r1', kind: 'income', amountCents: 500000, date: '2026-10-05', accountId: 'a', description: 'Salário' }), tx({ id: 'r2', kind: 'income', amountCents: 500000, date: '2026-11-05', accountId: 'a', description: 'Salário' }),
    tx({ id: 'r3', kind: 'expense', amountCents: 150000, date: '2026-09-10', accountId: 'a', categoryId: 'rent', description: 'Aluguel' }), tx({ id: 'r4', kind: 'expense', amountCents: 150000, date: '2026-10-10', accountId: 'a', categoryId: 'rent', description: 'Aluguel' }), tx({ id: 'r5', kind: 'expense', amountCents: 150000, date: '2026-11-10', accountId: 'a', categoryId: 'rent', description: 'Aluguel' }),
    tx({ id: 'r6', kind: 'expense', amountCents: 40000, date: '2026-11-11', accountId: 'a', categoryId: 'food', description: 'Padaria' }), tx({ id: 'r7', kind: 'card_purchase', amountCents: 60000, date: '2026-11-12', cardId: 'c', categoryId: 'market', description: 'Mercado Bom' }),
    tx({ id: 'r8', kind: 'expense', amountCents: 20000, date: '2026-11-28', accountId: 'a', categoryId: 'food', description: 'Delivery', status: 'planned' }), tx({ id: 'r9', kind: 'income', amountCents: 100000, date: '2026-11-30', accountId: 'a', description: 'Freela', status: 'planned' }),
  ] });
  write('reports', [
    c('expensesByCategory flat', { ledger: L7, month: '2026-11' }, expensesByCategory(L7, '2026-11')), c('expensesByCategory rollUp', { ledger: L7, month: '2026-11', rollUp: true }, expensesByCategory(L7, '2026-11', { rollUp: true })), c('expensesByCategory planned', { ledger: L7, month: '2026-11', includePlanned: true }, expensesByCategory(L7, '2026-11', { includePlanned: true })),
    c('cashflow 3', { ledger: L7, end: '2026-11', months: 3 }, cashflow(L7, '2026-11', 3)), c('compareMonths', { ledger: L7, month: '2026-11' }, compareMonths(L7, '2026-11')), c('yearSummary', { ledger: L7, year: 2026 }, yearSummary(L7, 2026)), c('recurring', { ledger: L7, end: '2026-11' }, recurringExpenses(L7, '2026-11')),
    c('projectBalance', { ledger: L7, today: '2026-11-15', until: '2026-11-30' }, projectBalance(L7, '2026-11-15', '2026-11-30')), c('netWorth', { ledger: L7, end: '2026-11', months: 2, today: '2026-11-15' }, netWorth(L7, '2026-11', 2, '2026-11-15')),
    c('search salario', { ledger: L7, query: 'salario' }, searchTransactions(L7, 'salario').map((t) => t.id)), c('search food planned', { ledger: L7, categoryIds: ['food'], status: ['planned'] }, searchTransactions(L7, '', { categoryIds: ['food'], status: ['planned'] }).map((t) => t.id)), c('search min', { ledger: L7, minCents: 200000 }, searchTransactions(L7, '', { minCents: 200000 }).map((t) => t.id)),
  ]);
  // ---- assistant ----
  const L8 = ledger({ accounts: [account({ id: 'a', openingBalanceCents: 300000 })], categories: [food], cards: [card({ id: 'c', limitCents: 100000 })], budgets: [budget({ id: 'bb', categoryId: 'food', limitCents: 50000 })], goals: [goal({ id: 'g', name: 'Viagem', targetCents: 100000 })], transactions: [
    tx({ kind: 'income', amountCents: 500000, date: '2026-11-01', accountId: 'a' }), tx({ kind: 'expense', amountCents: 45000, date: '2026-11-03', accountId: 'a', categoryId: 'food', description: 'Mercado' }), tx({ kind: 'expense', amountCents: 80000, date: '2026-11-06', accountId: 'a', description: 'Aluguel', status: 'planned' }),
    tx({ kind: 'expense', amountCents: 5000, date: '2026-10-20', accountId: 'a', description: 'Luz', status: 'planned' }), tx({ kind: 'card_purchase', amountCents: 90000, date: '2026-11-02', cardId: 'c' }), tx({ kind: 'goal_deposit', amountCents: 30000, date: '2026-11-02', accountId: 'a', goalId: 'g' }),
  ] });
  const qs = ['Quanto posso gastar?', 'Quais contas vencem esta semana?', 'Onde estou gastando mais?', 'Quanto já gastei com alimentação?', 'Tenho dinheiro suficiente para comprar um celular de 1.200,50?', 'Como organizar minhas contas?', 'Quanto falta para minha meta?', 'Quanto tenho comprometido em parcelas?', 'Como está o mês?', 'Posso comprar algo de 999.999,00?', 'xyz'];
  write('assistant', [...qs.map((q) => c(`intent "${q}"`, { question: q }, detectIntent(q))), ...qs.map((q) => c(`answer "${q}"`, { ledger: L8, question: q, today: '2026-11-04' }, { ...answer(L8, q, '2026-11-04'), text: undefined })), c('recommendations', { ledger: L8, today: '2026-11-04' }, recommendations(L8, '2026-11-04').map((r) => ({ id: r.id, severity: r.severity })))], );
  // ---- billing ----
  const iso = (d: string) => new Date(d).toISOString(); const now = '2026-11-04T12:00:00.000Z';
  const ent = (p: Partial<Entitlement>): Entitlement => ({ planId: 'plus_monthly', state: 'active', verifiedAt: iso('2026-11-04T11:00:00Z'), source: 'store_verified', ...p });
  const bcases: [string, Entitlement[]][] = [['free', []], ['active', [ent({ expiresAt: iso('2026-12-04T00:00:00Z') })]], ['expired', [ent({ expiresAt: iso('2026-11-01T00:00:00Z') })]], ['refunded', [ent({ state: 'refunded' })]], ['paused', [ent({ state: 'paused' })]], ['grace', [ent({ state: 'in_grace_period', expiresAt: iso('2026-11-01T00:00:00Z') })]], ['billing_issue', [ent({ state: 'billing_issue', expiresAt: iso('2026-11-01T00:00:00Z') })]], ['cancelled active', [ent({ state: 'cancelled_active_until_expiry', expiresAt: iso('2026-11-20T00:00:00Z') })]], ['cancelled expired', [ent({ state: 'cancelled_active_until_expiry', expiresAt: iso('2026-11-02T00:00:00Z') })]], ['cached fresh', [ent({ source: 'cached', verifiedAt: iso('2026-11-01T00:00:00Z'), expiresAt: iso('2027-01-01T00:00:00Z') })]], ['cached stale', [ent({ source: 'cached', verifiedAt: iso('2026-10-01T00:00:00Z'), expiresAt: iso('2027-01-01T00:00:00Z') })]], ['lifetime+plus', [ent({ planId: 'lifetime', state: 'active' }), ent({ expiresAt: iso('2026-12-04T00:00:00Z') })]], ['yearly over monthly', [ent({ planId: 'plus_yearly', expiresAt: iso('2027-11-04T00:00:00Z') }), ent({ expiresAt: iso('2026-12-04T00:00:00Z') })]]];
  write('billing', [...bcases.map(([n, e]) => c(`access ${n}`, { entitlements: e, now }, { ...resolveAccess(e, new Date(now)), features: [...resolveAccess(e, new Date(now)).features].sort() })), c('withinLimit free cards 0', { tier: 'free', key: 'cards', count: 0 }, withinLimit(resolveAccess([], new Date(now)), 'cards', 0)), c('withinLimit free cards 1', { tier: 'free', key: 'cards', count: 1 }, withinLimit(resolveAccess([], new Date(now)), 'cards', 1)), c('merge freshest', { existing: [ent({ verifiedAt: iso('2026-11-01T00:00:00Z'), state: 'expired' })], incoming: [ent({ verifiedAt: iso('2026-11-04T00:00:00Z'), state: 'active' })] }, mergeEntitlements([ent({ verifiedAt: iso('2026-11-01T00:00:00Z'), state: 'expired' })], [ent({ verifiedAt: iso('2026-11-04T00:00:00Z'), state: 'active' })]))]);
  // ---- dashboard ----
  let lay = applyPreset(DEFAULT_LAYOUT, 'focus'); lay = showWidget(lay, 'goals', 1); lay = moveWidgetBy(lay, 'goals', -1); lay = moveWidgetBy(lay, 'goals', -1); lay = hideWidget(lay, 'bills_to_pay');
  write('dashboard', [c('widget ids', {}, WIDGET_IDS), c('default layout', {}, DEFAULT_LAYOUT), c('ops sequence', { ops: ['preset focus', 'show goals @1', 'move goals -1', 'move goals -1', 'hide bills_to_pay'] }, lay), c('normalize corrupted', { raw: { order: ['available', 'bogus', 'available', 'goals'], period: 'weird', privacyMode: 'yes', accountIds: ['a', 2] } }, normalizeLayout({ order: ['available', 'bogus', 'available', 'goals'], period: 'weird', privacyMode: 'yes', accountIds: ['a', 2] })), c('normalize null', { raw: null }, normalizeLayout(null))]);
  // ---- io ----
  const csv = '﻿Data;Descrição;Valor;Tipo\n04/11/2026;"Mercado; Bom";-R$ 1.234,56;despesa\n2026-11-05;Salário;5.000,00;receita\n05/11/2026;Ruim;abc;despesa\n';
  const t1 = parseCSV(csv); const m1 = guessColumnMapping(t1.headers);
  const csv2 = 'date,description,amount\n2026-11-04,Uber,-23.90\n2026-11-04,Pix recebido,100.00';
  const t2 = parseCSV(csv2);
  const ofx = `OFXHEADER:100\nDATA:OFXSGML\n<OFX><BANKMSGSRSV1><STMTTRNRS><STMTRS><CURDEF>BRL<BANKACCTFROM><BANKID>0260<ACCTID>12345-6</BANKACCTFROM>\n<BANKTRANLIST><DTSTART>20261101<DTEND>20261130\n<STMTTRN><TRNTYPE>DEBIT<DTPOSTED>20261104120000[-3:BRT]<TRNAMT>-45.90<FITID>2026110400001<MEMO>PAG*MercadoBom</STMTTRN>\n<STMTTRN><TRNTYPE>CREDIT<DTPOSTED>20261105<TRNAMT>5000.00<FITID>2026110500002<NAME>TED SALARIO</STMTTRN>\n</BANKTRANLIST><LEDGERBAL><BALAMT>1234.56<DTASOF>20261130</LEDGERBAL></STMTRS></STMTTRNRS></BANKMSGSRSV1></OFX>`;
  const LE = ledger({ accounts: [account({ id: 'a', name: 'Nubank' })], categories: [category({ id: 'c', name: 'Casa' })], transactions: [tx({ id: 'e1', kind: 'expense', amountCents: 123456, date: '2026-11-04', description: 'Luz; "nov"', accountId: 'a', categoryId: 'c' })] });
  const LD = ledger({ transactions: [tx({ id: 't1', kind: 'expense', amountCents: 4590, date: '2026-11-04', description: 'Mercado Bom', externalRef: 'ofx:X' }), tx({ id: 't2', kind: 'expense', amountCents: 10000, date: '2026-11-10', description: 'Conta de luz' })] });
  const cands = [{ rowIndex: 0, date: '2026-11-04', description: 'whatever', amountCents: 1, kind: 'expense' as const, externalRef: 'ofx:X', problems: [] }, { rowIndex: 1, date: '2026-11-11', description: 'conta de luz', amountCents: 10000, kind: 'expense' as const, problems: [] }, { rowIndex: 2, date: '2026-11-20', description: 'Novo', amountCents: 500, kind: 'expense' as const, problems: [] }, { rowIndex: 3, date: '2026-11-20', description: 'novo', amountCents: 500, kind: 'expense' as const, problems: [] }, { rowIndex: 4, date: '2026-11-10', description: 'Conta de luz', amountCents: 10000, kind: 'income' as const, problems: [] }];
  const legacy = { version: 1, prefs: { name: 'Eu', theme: 'dark', safetyCushion: 150.5 }, accounts: [{ id: 'a1', name: 'Carteira', type: 'cash', balance: 10.1 }], categories: [{ id: 'c1', name: 'Alimentação', type: 'expense', icon: '🍽️', color: '#cb856a' }], cards: [{ id: 'k1', name: 'Roxo', limit: 1500, closing: 20, due: 27 }], transactions: [{ id: 't1', type: 'expense', amount: 24.9, date: '2026-11-03', accountId: 'a1', categoryId: 'c1', description: 'Padaria', paid: true, tags: [] }, { id: 't2', type: 'card_expense', amount: 99.99, date: '2026-11-25', cardId: 'k1', categoryId: 'c1', description: 'Mercado', paid: true }, { id: 't3', type: 'card_payment', amount: 50, date: '2026-11-27', accountId: 'a1', cardId: 'k1', invoiceKey: '2026-11', paid: true }, { id: 't4', type: 'expense', amount: 1, date: 'not-a-date', accountId: 'a1' }], budgets: [{ id: 'b1', categoryId: 'c1', limit: 500 }], goals: [{ id: 'g1', name: 'Viagem', target: 3000 }], loans: [], tags: [] };
  const leg = importLegacyBackup(legacy as never, '2026-11-04T00:00:00.000Z');
  write('io', [
    c('parseCSV pt', { text: csv }, { delimiter: t1.delimiter, headers: t1.headers, rows: t1.rows }), c('guessMapping pt', { headers: t1.headers }, m1), c('candidates pt', { text: csv }, candidatesFromCSV(t1, m1)), c('candidates en no type', { text: csv2 }, candidatesFromCSV(t2, guessColumnMapping(t2.headers))),
    ...['31/12/2026', '2026-12-31T10:00:00Z', '31-12-2026', '32/12/2026', '31/12/26', '2026-02-30'].map((d) => c(`parseDateFlexible ${d}`, { text: d }, parseDateFlexible(d))),
    c('exportCSV', { ledger: LE }, exportTransactionsCSV(LE, LE.transactions)), c('parseOFX', { text: ofx }, parseOFX(ofx)), c('candidatesFromOFX', { text: ofx }, candidatesFromOFX(parseOFX(ofx))),
    c('textSimilarity', { a: 'Mercado Bom', b: 'MERCADO BOM LTDA' }, textSimilarity('Mercado Bom', 'MERCADO BOM LTDA')), c('findDuplicates', { ledger: LD, candidates: cands }, findDuplicates(LD, cands)),
    c('importLegacy', { backup: legacy }, { counts: leg.counts, warnings: leg.warnings, accounts: leg.ledger.accounts.map((x) => ({ ...x, createdAt: undefined, updatedAt: undefined })), cards: leg.ledger.cards.map((x) => ({ ...x, createdAt: undefined, updatedAt: undefined })), transactions: leg.ledger.transactions.map((x) => ({ ...x, createdAt: undefined, updatedAt: undefined })), prefs: leg.ledger.prefs }),
  ]);
  // ---- sync ----
  const base = { id: 't', amountCents: 1000, description: 'a', status: 'planned', updatedAt: '2026-11-01T00:00:00Z' };
  write('sync', [c('only changed side', { base, local: { ...base, description: 'local' }, remote: { ...base, status: 'settled' } }, mergeEntity(base, { ...base, description: 'local' }, { ...base, status: 'settled' }, 'transaction', 't', 'now')), c('monetary conflict', { base, local: { ...base, amountCents: 2000, updatedAt: '2026-11-02T00:00:00Z' }, remote: { ...base, amountCents: 3000, updatedAt: '2026-11-03T00:00:00Z' } }, mergeEntity(base, { ...base, amountCents: 2000, updatedAt: '2026-11-02T00:00:00Z' }, { ...base, amountCents: 3000, updatedAt: '2026-11-03T00:00:00Z' }, 'transaction', 't', 'now')), c('lww text', { base, local: { ...base, description: 'L', updatedAt: '2026-11-02T00:00:00Z' }, remote: { ...base, description: 'R', updatedAt: '2026-11-03T00:00:00Z' } }, mergeEntity(base, { ...base, description: 'L', updatedAt: '2026-11-02T00:00:00Z' }, { ...base, description: 'R', updatedAt: '2026-11-03T00:00:00Z' }, 'transaction', 't', 'now'))]);
});
