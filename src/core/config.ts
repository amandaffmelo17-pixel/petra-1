export interface PetraRuntimeConfig {
  motorUrl: string;
  serviceToken?: string;
  databaseUrl: string;
  environment: string;
  version: string;
}

export function loadConfig(env: NodeJS.ProcessEnv = process.env): PetraRuntimeConfig {
  return {
    motorUrl: env.MOTOR_PETRA_URL ?? "",
    serviceToken: env.MOTOR_PETRA_SERVICE_TOKEN,
    databaseUrl: env.PETRA_DATABASE_URL ?? "",
    environment: env.PETRA_ENVIRONMENT ?? "development",
    version: env.PETRA_VERSION ?? "0.1.0",
  };
}
