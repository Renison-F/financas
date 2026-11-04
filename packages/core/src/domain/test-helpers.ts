import type { Account, Category, CreditCard, Ledger, Transaction, Goal, Loan, Budget } from './types';
import { emptyLedger } from './types';

const now = '2026-11-04T12:00:00.000Z';
let seq = 0;
export const nextId = (prefix = 'id'): string => `${prefix}_${++seq}`;

export function account(p: Partial<Account> = {}): Account {
  return { id: nextId('acc'), name: 'Conta', type: 'checking', currency: 'BRL', openingBalanceCents: 0, openingDate: '2026-01-01', color: '#0F5C45', archived: false, includeInAvailability: true, sortOrder: 0, createdAt: now, updatedAt: now, ...p };
}
export function category(p: Partial<Category> = {}): Category {
  return { id: nextId('cat'), name: 'Categoria', kind: 'expense', icon: 'tag', color: '#5B6962', archived: false, sortOrder: 0, createdAt: now, updatedAt: now, ...p };
}
export function card(p: Partial<CreditCard> = {}): CreditCard {
  return { id: nextId('card'), name: 'Cartão', limitCents: 500000, closingDay: 20, dueDay: 27, color: '#0F5C45', archived: false, currency: 'BRL', createdAt: now, updatedAt: now, ...p };
}
export function tx(p: Partial<Transaction> & Pick<Transaction, 'kind' | 'amountCents' | 'date'>): Transaction {
  return { id: nextId('tx'), currency: 'BRL', description: '', status: 'settled', tags: [], attachments: [], createdAt: now, updatedAt: now, ...p };
}
export function goal(p: Partial<Goal> = {}): Goal {
  return { id: nextId('goal'), name: 'Meta', kind: 'savings', targetCents: 100000, reserved: true, color: '#0F5C45', archived: false, createdAt: now, updatedAt: now, ...p };
}
export function loan(p: Partial<Loan> = {}): Loan {
  return { id: nextId('loan'), name: 'Empréstimo', principalCents: 1000000, monthlyRatePercent: 2, termMonths: 12, system: 'price', firstDueDate: '2026-12-10', monthlyFeeCents: 0, upfrontFeesCents: 0, archived: false, createdAt: now, updatedAt: now, ...p };
}
export function budget(p: Partial<Budget> = {}): Budget {
  return { id: nextId('bud'), limitCents: 50000, rollover: false, createdAt: now, updatedAt: now, ...p };
}
export function ledger(p: Partial<Ledger> = {}): Ledger { return { ...emptyLedger(), ...p }; }
