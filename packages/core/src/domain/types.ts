import type { Cents } from '../money/money';
import type { ISODate, MonthKey } from '../dates/dates';

export type Id = string;
export type CurrencyCode = 'BRL' | string;

export interface Timestamps { createdAt: string; updatedAt: string; deletedAt?: string | undefined; }

export type AccountType = 'cash' | 'checking' | 'savings' | 'digital_wallet' | 'investment' | 'other';

export interface Account extends Timestamps {
  id: Id;
  name: string;
  type: AccountType;
  currency: CurrencyCode;
  /** Opening balance at `openingDate` */
  openingBalanceCents: Cents;
  openingDate: ISODate;
  color: string;
  archived: boolean;
  /** Whether this account counts toward "pode gastar" and consolidated balance */
  includeInAvailability: boolean;
  sortOrder: number;
}

export type CategoryKind = 'income' | 'expense';
export interface Category extends Timestamps {
  id: Id;
  name: string;
  kind: CategoryKind;
  icon: string; // icon name from the app icon set, never an emoji
  color: string;
  parentId?: Id | undefined; // subcategory when set
  archived: boolean;
  sortOrder: number;
}

export interface Tag extends Timestamps { id: Id; name: string; color: string; }

export interface CreditCard extends Timestamps {
  id: Id;
  name: string;
  brand?: string | undefined;
  limitCents: Cents;
  /** Day of month (1..31) when the invoice closes. Purchases after this day go to the next invoice. */
  closingDay: number;
  /** Day of month (1..31) when the invoice is due. Must be after closingDay in the invoice cycle. */
  dueDay: number;
  /** Account normally used to pay the invoice */
  defaultPaymentAccountId?: Id | undefined;
  color: string;
  archived: boolean;
  currency: CurrencyCode;
}

export type TransactionKind =
  | 'income'
  | 'expense'
  | 'transfer'
  | 'card_purchase'
  | 'card_payment'
  | 'goal_deposit'
  | 'goal_withdrawal'
  | 'loan_disbursement'
  | 'loan_payment'
  | 'balance_adjustment';

export type TransactionStatus = 'planned' | 'settled' | 'partially_paid' | 'cancelled';

export interface Installment { number: number; of: number; groupId: Id; }

export type RecurrenceFrequency = 'daily' | 'weekly' | 'biweekly' | 'monthly' | 'bimonthly' | 'quarterly' | 'semiannual' | 'yearly';

export interface RecurrenceRule {
  id: Id;
  frequency: RecurrenceFrequency;
  /** anchor day (1..31) for monthly-like frequencies; clamped to month length */
  anchorDay?: number | undefined;
  startDate: ISODate;
  /** inclusive; undefined = until cancelled */
  endDate?: ISODate | undefined;
  /** max occurrences; undefined = unlimited */
  count?: number | undefined;
}

export interface Attachment { id: Id; fileName: string; mimeType: string; sizeBytes: number; sha256: string; }

export interface Transaction extends Timestamps {
  id: Id;
  kind: TransactionKind;
  amountCents: Cents; // always positive; direction given by kind
  currency: CurrencyCode;
  date: ISODate; // competence date (purchase date for card purchases)
  description: string;
  categoryId?: Id | undefined;
  accountId?: Id | undefined; // source account (expense, transfer-from, card_payment, deposits...)
  toAccountId?: Id | undefined; // transfer destination
  cardId?: Id | undefined; // card_purchase / card_payment
  goalId?: Id | undefined;
  loanId?: Id | undefined;
  status: TransactionStatus;
  /** For partial payments: how much has actually been paid so far */
  paidCents?: Cents | undefined;
  /** date when it was settled (may differ from competence date) */
  settledDate?: ISODate | undefined;
  dueDate?: ISODate | undefined; // for planned bills
  installment?: Installment | undefined;
  seriesId?: Id | undefined; // recurrence series
  transferGroupId?: Id | undefined;
  /** Explicit invoice month override for card purchases (normally derived) */
  invoiceMonth?: MonthKey | undefined;
  tags: Id[];
  notes?: string | undefined;
  attachments: Attachment[];
  /** Merchant / store, used by shopping integration */
  merchant?: string | undefined;
  /** Origin marker to prevent double registration (e.g. shopping session id, OFX FITID) */
  externalRef?: string | undefined;
}

export interface Budget extends Timestamps {
  id: Id;
  /** undefined categoryId = global monthly budget */
  categoryId?: Id | undefined;
  limitCents: Cents;
  /** month this budget applies to; undefined = every month (template) */
  month?: MonthKey | undefined;
  rollover: boolean;
}

export type GoalKind = 'savings' | 'emergency_fund' | 'purchase' | 'debt_payoff' | 'other';
export interface Goal extends Timestamps {
  id: Id;
  name: string;
  kind: GoalKind;
  targetCents: Cents;
  targetDate?: ISODate | undefined;
  /** Account where the money physically sits (optional) */
  accountId?: Id | undefined;
  /** If true, the saved amount is excluded from "pode gastar" */
  reserved: boolean;
  color: string;
  archived: boolean;
}

export type AmortizationSystem = 'price' | 'sac';
export interface Loan extends Timestamps {
  id: Id;
  name: string;
  lender?: string | undefined;
  principalCents: Cents;
  /** nominal monthly interest rate in percent, e.g. 1.99 */
  monthlyRatePercent: number;
  termMonths: number;
  system: AmortizationSystem;
  firstDueDate: ISODate;
  /** fixed extra monthly fees (insurance, admin) */
  monthlyFeeCents: Cents;
  /** optional IOF or upfront fees financed into the loan */
  upfrontFeesCents: Cents;
  accountId?: Id | undefined; // account that receives disbursement and pays installments
  archived: boolean;
}

export interface UserPrefs {
  locale: string;
  currency: CurrencyCode;
  theme: 'system' | 'light' | 'dark';
  privacyMode: boolean;
  safetyCushionCents: Cents;
  includePlannedIncomeInAvailability: boolean;
  availabilityHorizon: 'month_end' | 'days_30' | 'next_payday';
  firstDayOfMonth: number; // 1..28, for people paid mid-month
  hapticsEnabled: boolean;
  biometricLock: boolean;
}

/** Everything the pure domain functions need, loaded from storage. */
export interface Ledger {
  accounts: Account[];
  categories: Category[];
  tags: Tag[];
  cards: CreditCard[];
  transactions: Transaction[];
  budgets: Budget[];
  goals: Goal[];
  loans: Loan[];
  prefs: UserPrefs;
}

export const DEFAULT_PREFS: UserPrefs = {
  locale: 'pt-BR',
  currency: 'BRL',
  theme: 'system',
  privacyMode: false,
  safetyCushionCents: 0,
  includePlannedIncomeInAvailability: false,
  availabilityHorizon: 'month_end',
  firstDayOfMonth: 1,
  hapticsEnabled: true,
  biometricLock: false,
};

export function emptyLedger(prefs: Partial<UserPrefs> = {}): Ledger {
  return { accounts: [], categories: [], tags: [], cards: [], transactions: [], budgets: [], goals: [], loans: [], prefs: { ...DEFAULT_PREFS, ...prefs } };
}
