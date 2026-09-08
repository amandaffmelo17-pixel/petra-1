export type AccessSubjectType = 'user' | 'service' | 'agent' | 'integration';
export type AccessEventType =
  | 'login'
  | 'logout'
  | 'connection'
  | 'disconnection'
  | 'permission_change'
  | 'access_denied'
  | 'token_rotation';

export interface AccessRecord {
  companyId?: string;
  subjectType: AccessSubjectType;
  subjectId?: string;
  subjectName: string;
  accessRole?: string;
  source: string;
  target: string;
  permissions: string[];
  status: 'active' | 'ended' | 'denied' | 'revoked';
  startedAt: string;
  lastActivityAt: string;
  endedAt?: string;
  correlationId?: string;
}

export interface AccessEvent extends AccessRecord {
  eventType: AccessEventType;
  occurredAt: string;
  permission?: string;
  metadata?: Record<string, unknown>;
}

export function createAccessEvent(input: Omit<AccessEvent, 'occurredAt'>): AccessEvent {
  return { ...input, occurredAt: new Date().toISOString() };
}
