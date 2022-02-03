import pgPkg from 'pg'
const { Pool: DbPool } = pgPkg

;(async () => {
  const db = await new DbPool(connectionOptions())
  try {
    const listSql = 'SELECT version_month FROM ons_uprn_directory_versions'
    const listResult = await db.query(listSql)
    const versionMonths = listResult.rows.map(row => row.version_month)
    console.log(`There are ${versionMonths.length} version(s) of the ONS UPRN Directory in the data warehouse currently.`)
    if (versionMonths.length > 0) {
      console.log(`These are: ${versionMonths.join(', ')}.`)
    }
  } catch (e) {
    console.error('List failed:', e)
  } finally {
    await db.end()
  }
})()

function connectionOptions () {
  return { connectionString: process.env.DATABASE_URL, ssl: process.env.DATABASE_URL.includes('rds') }
}
