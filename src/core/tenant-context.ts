export interface TenantContext {
  tenantId: string;
  actorId: string;
  actorType: "user" | "service" | "agent";
  permission: string;
  correlationId: string;
}

export function assertTenantContext(context: TenantContext): void {
  for (const [key, value] of Object.entries(context)) {
    if (!value) throw new Error(`Contexto obrigatório ausente: ${key}.`);
  }
}

export function assertSameTenant(requestedTenantId: string, authenticatedTenantId: string): void {
  if (!requestedTenantId || !authenticatedTenantId || requestedTenantId !== authenticatedTenantId) {
    throw new Error("Acesso negado: contexto de empresa inválido.");
  }
}
