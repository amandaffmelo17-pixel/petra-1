import { readdir, readFile } from "node:fs/promises";
import { join } from "node:path";
import { database, closeDatabase } from "../core/database.js";

if (!database) {
  throw new Error("PETRA_DATABASE_URL não configurado.");
}

await database.query(`
  create table if not exists petra.schema_migrations (
    version text primary key,
    applied_at timestamptz not null default now()
  )
`);

const migrationsDir = join(process.cwd(), "database", "migrations");
const files = (await readdir(migrationsDir))
  .filter((file) => file.endsWith(".sql"))
  .sort();

for (const file of files) {
  const version = file.split("_")[0];
  const exists = await database.query<{ version: string }>(
    "select version from petra.schema_migrations where version = $1",
    [version],
  );
  if (exists.length) continue;

  const sql = await readFile(join(migrationsDir, file), "utf8");
  const client = await database.connect();
  try {
    await client.query("begin");
    await client.query(sql);
    await client.query("insert into petra.schema_migrations(version) values($1)", [version]);
    await client.query("commit");
    console.log(`PETRA migration applied: ${file}`);
  } catch (error) {
    await client.query("rollback");
    throw error;
  } finally {
    client.release();
  }
}

await closeDatabase();
