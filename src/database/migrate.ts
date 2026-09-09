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

// Versions are the complete migration filenames. The old runner used only
// the numeric prefix, which made the two existing 002 migrations collide and
// silently skipped 002_operational_completion.sql.
// Keep backward compatibility with databases that already stored 001/002/003
// while allowing every migration file to be applied exactly once.
const legacyVersions = new Set<string>();
const legacyRows = await database.query<{ version: string }>(
  "select version from petra.schema_migrations where version ~ '^[0-9]+$'",
);
for (const row of legacyRows) legacyVersions.add(row.version);

const firstFileByPrefix = new Map<string, string>();
for (const file of files) {
  const prefix = file.split("_")[0];
  if (!firstFileByPrefix.has(prefix)) firstFileByPrefix.set(prefix, file);
}

for (const file of files) {
  const version = file.replace(/\.sql$/, "");
  const prefix = file.split("_")[0];
  const exists = await database.query<{ version: string }>(
    "select version from petra.schema_migrations where version = $1",
    [version],
  );
  if (exists.length) continue;

  // If a legacy numeric version exists, it represents the first file with
  // that prefix in the old runner. Any additional file sharing that prefix
  // must still be executed.
  if (legacyVersions.has(prefix) && firstFileByPrefix.get(prefix) === file) {
    console.log(`PETRA legacy migration already applied: ${file}`);
    continue;
  }

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
