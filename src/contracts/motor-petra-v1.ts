export const MOTOR_CONTRACT_VERSION = "1.0" as const;
export type ActorType = "user" | "service" | "agent";
export interface MotorActor { id: string; type: ActorType; scopes: string[]; }
export interface MotorRequest<TPayload> {
  contractVersion: typeof MOTOR_CONTRACT_VERSION;
  requestId: string;
  correlationId: string;
  source: "PETRA" | "MOTOR-PETRA";
  target: "PETRA" | "MOTOR-PETRA";
  tenantId: string;
  actor: MotorActor;
  payload: TPayload;
}
export interface MotorResponse<TData = unknown> {
  contractVersion: typeof MOTOR_CONTRACT_VERSION;
  requestId: string;
  correlationId: string;
  ok: boolean;
  data?: TData;
  error?: { code: string; message: string; retryable?: boolean };
}
export interface MotorHandshakePayload { petraVersion: string; environment: string; capabilities: string[]; }
export interface MotorHandshakeData { service: "MOTOR PETRA"; status: "ready" | "degraded"; contractVersion: typeof MOTOR_CONTRACT_VERSION; tenantRequired: true; }
export function createRequestId(): string { return globalThis.crypto?.randomUUID?.() ?? `${Date.now()}-${Math.random().toString(16).slice(2)}`; }
export function createMotorRequest<TPayload>(payload: TPayload, tenantId: string, actor: MotorActor, options: Pick<MotorRequest<TPayload>, "source" | "target"> & { correlationId?: string }): MotorRequest<TPayload> {
  if (!tenantId) throw new Error("tenantId é obrigatório.");
  const requestId = createRequestId();
  return { contractVersion: MOTOR_CONTRACT_VERSION, requestId, correlationId: options.correlationId ?? requestId, source: options.source, target: options.target, tenantId, actor, payload };
}
