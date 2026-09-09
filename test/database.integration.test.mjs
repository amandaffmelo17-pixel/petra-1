import test from "node:test";
import assert from "node:assert/strict";
import pg from "pg";

const { Client } = pg;
const url = process.env.PETRA_DATABASE_URL;

test("PETRA: produção exige medição aprovada", { skip: !url }, async () => {
  const db = new Client({ connectionString: url });
  await db.connect();

  try {
    const company = await db.query(`insert into petra.companies(legal_name, trade_name) values ('Teste PETRA', 'Teste PETRA') returning id`);
    const companyId = company.rows[0].id;
    const customer = await db.query(`insert into petra.customers(company_id, name) values ($1, 'Cliente Teste') returning id`, [companyId]);
    const customerId = customer.rows[0].id;
    const order = await db.query(`insert into petra.orders(company_id, customer_id, number) values ($1, $2, 'TEST-001') returning id`, [companyId, customerId]);
    const orderId = order.rows[0].id;

    const measurement = await db.query(`insert into petra.measurements(company_id, order_id, measured_at, status) values ($1, $2, now(), 'approved') returning id`, [companyId, orderId]);
    const measurementId = measurement.rows[0].id;

    await assert.rejects(
      db.query(`insert into petra.production_releases(company_id, order_id, measurement_id) values ($1, $2, gen_random_uuid())`, [companyId, orderId]),
      /approved measurement/i,
    );

    await db.query(`insert into petra.production_releases(company_id, order_id, measurement_id) values ($1, $2, $3)`, [companyId, orderId, measurementId]);
    await db.query(`update petra.orders set status = 'production', production_released_at = now() where id = $1`, [orderId]);

    const result = await db.query(`select status from petra.orders where id = $1`, [orderId]);
    assert.equal(result.rows[0].status, "production");
  } finally {
    await db.end();
  }
});
