import {
  createMotorRequest,
  type MotorHandshakeData,
  type MotorHandshakePayload,
  type MotorResponse,
} from "../contracts/motor-petra-v1.js";

export interface MotorClientOptions {
  baseUrl: string;
  serviceToken?: string;
  timeoutMs?: number;
}

export class MotorPetraClient {
  constructor(private readonly options: MotorClientOptions) {}

  async handshake(input: {
    tenantId: string;
    actorId: string;
    actorType: "user" | "service" | "agent";
    petraVersion: string;
    environment: string;
    capabilities: string[];
  }): Promise<MotorResponse<MotorHandshakeData>> {
    const payload: MotorHandshakePayload = {
      petraVersion: input.petraVersion,
      environment: input.environment,
      capabilities: input.capabilities,
    };

    const request = createMotorRequest(
      payload,
      input.tenantId,
      { id: input.actorId, type: input.actorType, scopes: ["motor:handshake"] },
      { source: "PETRA", target: "MOTOR-PETRA" },
    );

    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), this.options.timeoutMs ?? 5000);

    try {
      const response = await fetch(`${this.options.baseUrl.replace(/\/$/, "")}/api/v1/handshake`, {
        method: "POST",
        headers: {
          "content-type": "application/json",
          ...(this.options.serviceToken ? { authorization: `Bearer ${this.options.serviceToken}` } : {}),
        },
        body: JSON.stringify(request),
        signal: controller.signal,
      });

      const result = (await response.json()) as MotorResponse<MotorHandshakeData>;
      if (!response.ok) {
        throw new Error(result.error?.message ?? `MOTOR PETRA retornou HTTP ${response.status}.`);
      }
      return result;
    } finally {
      clearTimeout(timer);
    }
  }
}
