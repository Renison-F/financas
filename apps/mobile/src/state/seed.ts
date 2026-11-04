import type { Category } from '@financas/core';

/** Default categories (icons from the app icon set; never emoji). */
export const DEFAULT_CATEGORIES: Omit<Category, 'id' | 'createdAt' | 'updatedAt'>[] = [
  { name: 'Alimentação', kind: 'expense', icon: 'cart', color: '#C0703E', archived: false, sortOrder: 0 },
  { name: 'Supermercado', kind: 'expense', icon: 'cart', color: '#C0703E', archived: false, sortOrder: 1 },
  { name: 'Moradia', kind: 'expense', icon: 'home', color: '#0B5563', archived: false, sortOrder: 2 },
  { name: 'Transporte', kind: 'expense', icon: 'swap', color: '#4F5E61', archived: false, sortOrder: 3 },
  { name: 'Saúde', kind: 'expense', icon: 'plus', color: '#176B4E', archived: false, sortOrder: 4 },
  { name: 'Educação', kind: 'expense', icon: 'list', color: '#8A5200', archived: false, sortOrder: 5 },
  { name: 'Lazer', kind: 'expense', icon: 'star', color: '#A93A29', archived: false, sortOrder: 6 },
  { name: 'Compras', kind: 'expense', icon: 'tag', color: '#74848A', archived: false, sortOrder: 7 },
  { name: 'Assinaturas', kind: 'expense', icon: 'receipt', color: '#0B5563', archived: false, sortOrder: 8 },
  { name: 'Outros gastos', kind: 'expense', icon: 'more', color: '#4F5E61', archived: false, sortOrder: 9 },
  { name: 'Salário', kind: 'income', icon: 'bank', color: '#176B4E', archived: false, sortOrder: 10 },
  { name: 'Trabalho extra', kind: 'income', icon: 'sparkle', color: '#176B4E', archived: false, sortOrder: 11 },
  { name: 'Rendimentos', kind: 'income', icon: 'arrow-up', color: '#176B4E', archived: false, sortOrder: 12 },
  { name: 'Reembolsos', kind: 'income', icon: 'swap', color: '#176B4E', archived: false, sortOrder: 13 },
  { name: 'Outras receitas', kind: 'income', icon: 'more', color: '#176B4E', archived: false, sortOrder: 14 },
];
