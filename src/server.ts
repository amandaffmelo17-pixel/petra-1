import { createServer } from "node:http";
import { loadConfig } from "./core/config.js";
import { databaseConfigured } from "./core/database.js";
import { MotorPetraClient } from "./integrations/motor-client.js";
import { handleApi } from "./api/routes.js";

const config = loadConfig();
const motor = config.motorUrl
  ? new MotorPetraClient({ baseUrl: config.motorUrl, serviceToken: config.serviceToken })
  : null;

const json = (response: import("node:http").ServerResponse, status: number, body: unknown) => {
  response.writeHead(status, { "Content-Type": "application/json; charset=utf-8", "Cache-Control": "no-store" });
  response.end(JSON.stringify(body));
};

const html = `<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8" /><meta name="viewport" content="width=device-width, initial-scale=1" />
<title>PETRA — Gestão</title>
<style>
:root{font-family:Inter,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;color:#171717;background:#f5f5f3}*{box-sizing:border-box}body{margin:0}.app{display:flex;min-height:100vh}.side{width:250px;background:#171717;color:#fff;padding:24px 16px;position:fixed;inset:0 auto 0 0}.brand{font-size:25px;font-weight:800;letter-spacing:.08em;padding:4px 12px 28px}.sub{color:#a3a3a3;font-size:12px;margin:-20px 12px 22px}.nav{display:grid;gap:6px}.nav button{border:0;background:transparent;color:#d4d4d4;text-align:left;padding:12px;border-radius:9px;font-size:14px}.nav button.active{background:#303030;color:#fff}.main{margin-left:250px;width:calc(100% - 250px);padding:30px;max-width:1500px}.top{display:flex;justify-content:space-between;align-items:center;margin-bottom:26px}.top h1{margin:0;font-size:28px}.status{font-size:13px;background:#fff;border:1px solid #e5e5e5;padding:9px 13px;border-radius:999px}.dot{display:inline-block;width:8px;height:8px;border-radius:50%;background:#22c55e;margin-right:7px}.cards{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:16px}.card{background:#fff;border:1px solid #e5e5e5;border-radius:14px;padding:20px}.label{color:#737373;font-size:13px}.num{font-size:30px;font-weight:750;margin-top:8px}.section{margin-top:24px}.section h2{font-size:18px;margin:0 0 14px}.flow{display:grid;grid-template-columns:repeat(7,1fr);gap:8px}.step{background:#fff;border:1px solid #e5e5e5;border-radius:12px;padding:14px 10px;text-align:center;font-size:12px}.step strong{display:block;font-size:18px;margin-bottom:7px}.notice{margin-top:16px;background:#fff;border-left:4px solid #171717;border-radius:10px;padding:15px}@media(max-width:850px){.side{width:72px;padding:18px 8px}.brand{font-size:17px;padding:5px 7px 25px}.sub,.nav button span{display:none}.nav button{text-align:center}.main{margin-left:72px;width:calc(100% - 72px);padding:20px}.cards{grid-template-columns:repeat(2,1fr)}.flow{grid-template-columns:repeat(2,1fr)}.top h1{font-size:22px}}
</style></head>
<body><div class="app"><aside class="side"><div class="brand">PETRA</div><div class="sub">GESTÃO DE MARMORARIA</div><nav class="nav">
<button class="active">⌂ <span>Painel</span></button><button>◉ <span>Clientes</span></button><button>▣ <span>Orçamentos</span></button><button>□ <span>Pedidos</span></button><button>⌁ <span>Medições</span></button><button>◇ <span>Desenho Técnico</span></button><button>▤ <span>Produção</span></button><button>⇢ <span>Expedição</span></button><button>⚒ <span>Instalação</span></button><button>R$ <span>Financeiro</span></button><button>▦ <span>Estoque</span></button><button>◈ <span>Documentos</span></button><button>✦ <span>Assistente</span></button></nav></aside>
<main class="main"><div class="top"><div><h1>Painel do Petra</h1><div style="color:#737373;margin-top:5px">Gestão central da marmoraria</div></div><div class="status"><i class="dot"></i>Petra online</div></div>
<div class="cards"><div class="card"><div class="label">Clientes</div><div class="num">—</div></div><div class="card"><div class="label">Orçamentos em aberto</div><div class="num">—</div></div><div class="card"><div class="label">Pedidos em andamento</div><div class="num">—</div></div><div class="card"><div class="label">Instalações previstas</div><div class="num">—</div></div></div>
<section class="section"><h2>Fluxo operacional</h2><div class="flow"><div class="step"><strong>01</strong>Orçamento</div><div class="step"><strong>02</strong>Pedido</div><div class="step"><strong>03</strong>Medição</div><div class="step"><strong>04</strong>Desenho</div><div class="step"><strong>05</strong>Produção</div><div class="step"><strong>06</strong>Instalação</div><div class="step"><strong>07</strong>Finalizado</div></div></section>
<div class="notice"><strong>Regra de produção:</strong> uma ordem de corte só poderá ser liberada quando houver medição aprovada com data registrada.</div>
</main></div></body></html>`;

const server = createServer(async (request, response) => {
  const url = request.url?.split("?", 1)[0] ?? "/";
  if (request.method === "GET" && url === "/") {
    response.writeHead(200, { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store" });
    response.end(html);
    return;
  }
  if (request.method === "GET" && url === "/api") {
    json(response, 200, { service: "PETRA", version: config.version, modules: ["commercial","quotes","orders","measurements","technical-drawings","production","finishing","logistics","installation","finance","stock","documents","automations","assistant"] });
    return;
  }
  if (request.method === "GET" && url === "/health") {
    json(response, 200, { service: "PETRA", status: "online", version: config.version, environment: config.environment, databaseConfigured: databaseConfigured(), motorConfigured: Boolean(motor) });
    return;
  }
  if (request.method === "POST" && url === "/api/v1/motor/handshake") {
    if (!motor) { json(response, 503, { ok: false, error: { code: "MOTOR_NOT_CONFIGURED", message: "MOTOR_PETRA_URL não configurado." } }); return; }
    try {
      const result = await motor.handshake({ tenantId: "system", actorId: "petra-runtime", actorType: "service", petraVersion: config.version, environment: config.environment, capabilities: ["health", "tenant-context", "motor-handshake"] });
      json(response, result.ok ? 200 : 502, result);
    } catch (error) { json(response, 502, { ok: false, error: { code: "MOTOR_UNREACHABLE", message: error instanceof Error ? error.message : "Falha na comunicação com o MOTOR PETRA." } }); }
    return;
  }
  if (request.method && url.startsWith("/api/v1/")) {
    const handled = await handleApi(request, response, url);
    if (handled) return;
  }
  json(response, 404, { ok: false, error: { code: "NOT_FOUND", message: "Rota não encontrada." } });
});

const port = Number(process.env.PORT ?? 3000);
server.listen(port, () => console.log(`PETRA ativo na porta ${port}`));
