export const PETRA_MODULES = [
  "dashboard",
  "commercial",
  "quotes",
  "orders",
  "measurement",
  "technical",
  "production",
  "finishing",
  "logistics",
  "installation",
  "finance",
  "inventory",
  "customers",
  "documents",
  "reports",
  "marketing",
  "automations",
  "assistant",
] as const;

export type PetraModule = typeof PETRA_MODULES[number];

export function isKnownModule(value: string): value is PetraModule {
  return (PETRA_MODULES as readonly string[]).includes(value);
}
