import { MotorPetraClient } from "../src/integrations/motor-client.js";
import { loadConfig } from "../src/core/config.js";

const config = loadConfig();
const motor = config.motorUrl
  ? new MotorPetraClient({ baseUrl: config.motorUrl, serviceToken: config.serviceToken })
  : null;

const dashboard = `<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>PETRA — Gestão</title>
<style>
*{box-sizing:border-box}body{margin:0;font-family:Inter,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;background:#f5f5f3;color:#171717}.app{display:flex;min-height:100vh}.side{width:240px;background:#171717;color:#fff;padding:24px 16px}.brand{font-size:24px;font-weight:800;letter-spacing:.08em;padding:0 12px 28px}.nav{display:grid;gap:6px}.nav div{padding:11px 12px;border-radius:9px;color:#d6d6d6}.nav .active{background:#fff;color:#171717}.main{flex:1;padding:28px;max-width:1400px}.top{display:flex;justify-content:space-between;align-items:center;margin-bottom:28px}.top h1{margin:0;font-size:28px}.status{background:#e9f7ee;color:#18723c;padding:8px 12px;border-radius:999px;font-size:13px;font-weight:700}.grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:16px}.card{background:#fff;border:1px solid #e6e6e2;border-radius:14px;padding:20px}.label{color:#737373;font-size:13px}.value{font-size:30px;font-weight:800;margin-top:8px}.section{margin-top:24px}.section h2{font-size:18px}.flow{display:grid;grid-template-columns:repeat(6,1fr);gap:10px}.step{background:#fff;border:1px solid #e6e6e2;border-radius:12px;padding:16px;min-height:92px}.step b{display:block;margin-bottom:7px}.step span{font-size:12px;color:#777}.notice{margin-top:20px;padding:16px;border-radius:12px;background:#fff;border:1px solid #e6e6e2;color:#555}@media(max-width:900px){.side{width:72px}.brand{font-size:0}.brand:after{content:"P";font-size:24px}.nav div{font-size:0;text-align:center}.nav div:before{content:"•";font-size:18px}.grid{grid-template-columns:repeat(2,1fr)}.flow{grid-template-columns:repeat(2,1fr)}}@media(max-width:560px){.side{display:none}.main{padding:18px}.grid{grid-template-columns:1fr 1fr}}
</style></head>
<body><div class="app"><aside class="side"><div class="brand">PETRA</div><nav class="nav"><div class="active">Painel</div><div>Clientes</div><div>Orçamentos</div><div>Pedidos</div><div>Medições</div><div>Desenho Técnico</div><div>Produção</div><div>Instalação</div><div>Financeiro</div><div>Estoque</div><div>Documentos</div><div>Assistente</div></nav></aside><main class="main"><div class="top"><h1>Painel de Gestão</h1><span class="status">● PETRA online</span></div><section class="grid"><div class="card"><div class="label">Clientes</div><div class="value">0</div></div><div class="card"><div class="label">Orçamentos</div><div class="value">0</div></div><div class="card"><div class="label">Pedidos</div><div class="value">0</div></div><div class="card"><div class="label">Produção</div><div class="value">0</div></div></section><section class="section"><h2>Fluxo operacional</h2><div class="flow"><div class="step"><b>Orçamento</b><span>Proposta comercial</span></div><div class="step"><b>Pedido</b><span>Pedido aprovado</span></div><div class="step"><b>Medição</b><span>Conferência registrada</span></div><div class="step"><b>Desenho</b><span>Liberação técnica</span></div><div class="step"><b>Produção</b><span>Fabricação e acabamento</span></div><div class="step"><b>Instalação</b><span>Entrega e finalização</span></div></div></section><div class="notice"><b>Regra de segurança:</b> uma ordem de corte só poderá ser liberada para produção quando houver data de medição registrada.</div></main></div></body></html>`;

export default async function handler(request: any, response: any) {
  const url = request.url || "/";
  if (request.method === "GET" && (url === "/" || url.startsWith("/?"))) {
    response.setHeader("Content-Type", "text/html; charset=utf-8");
    response.statusCode = 200;
    response.end(dashboard);
    return;
  }
  if (request.method === "GET" && url.startsWith("/health")) {
    response.setHeader("Content-Type", "application/json; charset=utf-8");
    response.statusCode = 200;
    response.end(JSON.stringify({service:"PETRA",status:"online",version:config.version,motorConfigured:Boolean(motor)}));
    return;
  }
  response.statusCode = 404;
  response.end(JSON.stringify({ok:false,error:{code:"NOT_FOUND",message:"Rota não encontrada."}}));
}
