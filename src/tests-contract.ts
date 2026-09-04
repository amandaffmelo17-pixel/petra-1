import { createMotorRequest, MOTOR_CONTRACT_VERSION } from "./contracts/motor-petra-v1.js";

export function contractSelfCheck(): { ok: boolean; contractVersion: string; tenantGuard: boolean } {
  const request = createMotorRequest(
    { petraVersion: "0.1.0", environment: "test", capabilities: ["health"] },
    "test-tenant",
    { id: "test-service", type: "service", scopes: ["motor:handshake"] },
    { source: "PETRA", target: "MOTOR-PETRA" },
  );
  return {
    ok: request.contractVersion === MOTOR_CONTRACT_VERSION && request.tenantId === "test-tenant",
    contractVersion: request.contractVersion,
    tenantGuard: request.tenantId.length > 0,
  };
}
