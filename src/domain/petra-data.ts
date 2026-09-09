export type Status = string;

export interface Customer { id: string; name: string; phone?: string; email?: string; createdAt: string; }
export interface Quote { id: string; customerId: string; status: Status; total: number; validUntil?: string; createdAt: string; }
export interface Order { id: string; customerId: string; quoteId?: string; status: Status; measurementDate?: string; createdAt: string; closedAt?: string; }
export interface Measurement { id: string; orderId: string; scheduledAt: string; measuredAt?: string; responsible?: string; notes?: string; }
export interface Production { id: string; orderId: string; status: Status; releasedAt?: string; }
export interface Installation { id: string; orderId: string; scheduledAt: string; status: Status; }

export interface PetraStore {
  customers: Customer[];
  quotes: Quote[];
  orders: Order[];
  measurements: Measurement[];
  productions: Production[];
  installations: Installation[];
}

export const emptyStore = (): PetraStore => ({ customers: [], quotes: [], orders: [], measurements: [], productions: [], installations: [] });

export function canReleaseCut(order: Order): boolean {
  return Boolean(order.measurementDate) && order.status !== "closed";
}

export function canEditOrder(order: Order): boolean {
  return order.status !== "closed";
}
