import pgPkg from 'pg'
const { Pool: DbPool } = pgPkg

const args = process.argv.slice(2)
if (args.length === 0) {
  console.error('Please provide, as an argument, the version_month you wish to delete')
  console.error('You can find it by running npm run list_onsud_versions')
  console.error('Example usage: npm run delete_onsud_version 2021-11')
  process.exit(1)
}
const versionMonth = args[0]
;(async () => {
  const db = await new DbPool(connectionOptions())
  try {
    const deleteDataTableSql = 'DELETE FROM ons_uprn_directory WHERE version_id=(SELECT id FROM ons_uprn_directory_versions WHERE version_month= $1 )'
    const deleteVersionTableSql = 'DELETE FROM ons_uprn_directory_versions WHERE version_month = $1'
    await db.query(deleteDataTableSql, [versionMonth])
    await db.query(deleteVersionTableSql, [versionMonth])

    console.log(`${versionMonth} version of the ONS UPRN directory has been deleted`)
  } catch (e) {
    console.error('Delete failed:', e)
  } finally {
    await db.end()
  }
})()

function connectionOptions () {
  return { connectionString: process.env.DATABASE_URL, ssl: process.env.DATABASE_URL.includes('rds') }
}
