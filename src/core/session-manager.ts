import { createRequestId } from '../contracts/motor-petra-v1.js';
import { AccessRecord, createAccessEvent } from './access-registry.js';

export interface SessionRecord extends AccessRecord {
  sessionId: string;
  expiresAt: string;
}

export class SessionManager {
  private readonly sessions = new Map<string, SessionRecord>();

  createSession(input: Omit<SessionRecord, 'sessionId' | 'startedAt' | 'lastActivityAt' | 'status' | 'correlationId'>): SessionRecord {
    const now = new Date().toISOString();
    const session: SessionRecord = {
      ...input,
      sessionId: createRequestId(),
      startedAt: now,
      lastActivityAt: now,
      status: 'active',
      correlationId: createRequestId(),
    };
    this.sessions.set(session.sessionId, session);
    return session;
  }

  get(sessionId: string): SessionRecord | undefined {
    return this.sessions.get(sessionId);
  }

  touch(sessionId: string): SessionRecord | undefined {
    const session = this.sessions.get(sessionId);
    if (!session || session.status !== 'active') return undefined;
    session.lastActivityAt = new Date().toISOString();
    return session;
  }

  end(sessionId: string): SessionRecord | undefined {
    const session = this.sessions.get(sessionId);
    if (!session) return undefined;
    session.status = 'ended';
    session.endedAt = new Date().toISOString();
    return session;
  }

  listActive(): SessionRecord[] {
    return [...this.sessions.values()].filter((session) => session.status === 'active');
  }
}

export function sessionLoginEvent(session: SessionRecord) {
  return createAccessEvent({
    ...session,
    eventType: 'login',
  });
}
