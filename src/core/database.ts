import { Pool, type QueryResultRow } from "pg";
import { loadConfig } from "./config.js";

const config = loadConfig();

export const database = config.databaseUrl
  ? new Pool({ connectionString: config.databaseUrl, max: Number(process.env.PETRA_DB_POOL_MAX ?? 10) })
  : null;

export function databaseConfigured(): boolean {
  return Boolean(database);
}

export async function query<T extends QueryResultRow = QueryResultRow>(text: string, values: unknown[] = []): Promise<T[]> {
  if (!database) throw new Error("PETRA_DATABASE_URL não configurado.");
  const result = await database.query<T>(text, values);
  return result.rows;
}

export async function closeDatabase(): Promise<void> {
  if (database) await database.end();
}
