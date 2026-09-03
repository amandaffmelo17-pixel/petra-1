export interface PetraEvent<T = unknown> {
  id: string;
  name: string;
  version: string;
  occurredAt: string;
  tenantId: string;
  correlationId: string;
  sourceModule: string;
  payload: T;
}

export type EventHandler<T = unknown> = (event: PetraEvent<T>) => Promise<void> | void;

export class EventBus {
  private readonly handlers = new Map<string, EventHandler[]>();

  subscribe<T>(eventName: string, handler: EventHandler<T>): void {
    const current = this.handlers.get(eventName) ?? [];
    current.push(handler as EventHandler);
    this.handlers.set(eventName, current);
  }

  async publish<T>(event: PetraEvent<T>): Promise<void> {
    const handlers = this.handlers.get(event.name) ?? [];
    for (const handler of handlers) await handler(event);
  }
}
