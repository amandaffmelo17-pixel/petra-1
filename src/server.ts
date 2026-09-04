import { createServer } from "node:http";
import { loadConfig } from "./core/config.js";
import { MotorPetraClient } from "./integrations/motor-client.js";

const config = loadConfig();
const motor = config.motorUrl
  ? new MotorPetraClient({ baseUrl: config.motorUrl, serviceToken: config.serviceToken })
  : null;

const json = (response: import("node:http").ServerResponse, status: number, body: unknown) => {
  response.writeHead(status, { "Content-Type": "application/json; charset=utf-8" });
  response.end(JSON.stringify(body));
};

const server = createServer(async (request, response) => {
  if (request.method === "GET" && request.url === "/health") {
    json(response, 200, {
      service: "PETRA",
      status: "online",
      version: config.version,
      environment: config.environment,
      motorConfigured: Boolean(motor),
    });
    return;
  }

  if (request.method === "GET" && request.url === "/") {
    json(response, 200, {
      service: "PETRA",
      status: "online",
      motorConfigured: Boolean(motor),
      contractVersion: "1.0",
      endpoints: ["/health", "/api/v1/motor/handshake"],
    });
    return;
  }

  if (request.method === "POST" && request.url === "/api/v1/motor/handshake") {
    if (!motor) {
      json(response, 503, {
        ok: false,
        error: { code: "MOTOR_NOT_CONFIGURED", message: "MOTOR_PETRA_URL não configurado." },
      });
      return;
    }

    try {
      const result = await motor.handshake({
        tenantId: "system",
        actorId: "petra-runtime",
        actorType: "service",
        petraVersion: config.version,
        environment: config.environment,
        capabilities: ["health", "tenant-context", "motor-handshake"],
      });
      json(response, result.ok ? 200 : 502, result);
    } catch (error) {
      json(response, 502, {
        ok: false,
        error: {
          code: "MOTOR_UNREACHABLE",
          message: error instanceof Error ? error.message : "Falha na comunicação com o MOTOR PETRA.",
        },
      });
    }
    return;
  }

  json(response, 404, { ok: false, error: { code: "NOT_FOUND", message: "Rota não encontrada." } });
});

const port = Number(process.env.PORT ?? 3000);
server.listen(port, () => console.log(`PETRA ativo na porta ${port}`));
