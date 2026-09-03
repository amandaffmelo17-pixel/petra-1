export const MOTOR_CONTRACT_VERSION = "1.0";

export type ActorType = "user" | "service" | "agent";

export interface MotorActor {
  id: string;
  type: ActorType;
  name?: string;
}

export interface MotorRequest<TPayload> {
  contractVersion: string;
  requestId: string;
  correlationId: string;
  source: string;
  target: string;
  tenantId: string;
  actor: MotorActor;
  payload: TPayload;
}

export interface MotorResponse<TData = unknown> {
  ok: boolean;
  correlationId: string;
  contractVersion: string;
  data?: TData;
  error?: { code: string; message: string; retryable: boolean };
}

export interface MotorHandshakePayload {
  petraVersion: string;
  environment: string;
  capabilities: string[];
}

export interface MotorHandshakeData {
  motor: string;
  version: string;
  contractVersion: string;
  accepted: boolean;
}

export function createRequestId(): string {
  return globalThis.crypto?.randomUUID?.() ?? `${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

export function createMotorRequest<TPayload>(input: Omit<MotorRequest<TPayload>, "contractVersion" | "requestId" | "correlationId"> & { correlationId?: string }): MotorRequest<TPayload> {
  if (!input.tenantId) throw new Error("tenantId é obrigatório.");
  const requestId = createRequestId();
  return {
    ...input,
    contractVersion: MOTOR_CONTRACT_VERSION,
    requestId,
    correlationId: input.correlationId ?? requestId,
  };
}
