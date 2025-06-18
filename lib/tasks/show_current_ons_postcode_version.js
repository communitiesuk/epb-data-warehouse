import pgPkg from 'pg'
import fs from 'fs'
const { Pool: DbPool } = pgPkg

;(async () => {
  const db = await new DbPool(connectionOptions())
  try {
    const listSql = 'SELECT version_month FROM ons_postcode_directory_versions ORDER BY created_at DESC LIMIT 1'
    const listResult = await db.query(listSql)
    if (listResult.rows.length > 0) {
      console.log(`The version of the ONS Postcode Directory currently loaded is: ${listResult.rows[0].version_month}.`)
    } else {
      console.log('No version of the ONS Postcode Directory is stored in this database.')
    }
  } catch (e) {
    console.error('Showing current version failed:', e)
  } finally {
    await db.end()
  }
})()

function connectionOptions () {
  return {
    connectionString: process.env.DATABASE_URL,
    ssl: {
      require: true,
      rejectUnauthorized: true,
      ca: fs.readFileSync("/../config/eu-west-2-bundle.pem").toString(),
    }
  }
}
