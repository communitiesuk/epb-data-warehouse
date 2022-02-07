import { XMLParser } from 'fast-xml-parser'
import fetch from 'node-fetch'
import request from 'request'
import unzipper from 'unzipper'
import csv from 'csv-stream'
import pgPromise from 'pg-promise'
import pgPkg from 'pg'
const { Pool: DbPool } = pgPkg
const pgp = pgPromise({})

const start = new Date()

const args = process.argv.slice(2)
if (args.length === 0) {
  console.error('Please provide, as an argument, the ONS UPRN Directory resource ID for the month you are importing.')
  console.error('You can find it within the metadata for the published version - it is a 32 character length hex string.')
  console.error('Example usage: npm run populate_onsud b81980b8ee1647a79bfe1abca7b14aab')
  process.exit(1)
}

const resourceId = args[0]
if (!resourceId.match(/^[0-9a-f]{32}$/)) {
  console.error(`The resource ID provided (${resourceId}) is not in the expected format of a 32 character hex string.`)
  process.exit(1)
}

const fileRegex = /ONSUD_\w{3}_\d{4}_\w{2}.csv/
const pathRegex = new RegExp(`Data\\/${fileRegex.source}`)

const bufferSize = 500

;(async () => {
  try {
    let directory
    try {
      directory = await fetchDirectory()
    } catch (e) {
      console.error(`Cannot resolve to a resource on the ArcGIS servers - please check the resource ID ${resourceId} is correct.`)
      throw e
    }
    const targetEntries = directory.files.filter(entry => entry.path.match(pathRegex))
    if (targetEntries.length === 0) {
      noFilesToRead()
      return
    }
    const csvFiles = targetEntries.map(entry => fileFromPath(entry.path))
    directory = undefined
    await writeFiles(csvFiles)
  } catch (e) {
    console.error('Import failed:', e)
  }
})()

async function writeFiles (files) {
  const versionMonth = await versionMonthForId(resourceId)

  const buffer = []

  const dbFn = () => new DbPool(connectionOptions())
  const db = await dbFn().connect()

  let versionId = null

  try {
    versionId = await registerVersionMonth(versionMonth, db)

    await writeCsv(files)
  } catch (e) {
    console.log(e)
  } finally {
    await db.end()
  }

  const dbP = pgp(connectionOptions())

  const columnSet = insertDirectoryColumnSet()

  async function flushToDb () {
    const batch = buffer.splice(0, buffer.length) // grabs copy of buffer and empties it in one operation
    // console.log(`Batch to write has size ${batch.length}`)
    await insertDirectoryData(batch, versionId, dbP, columnSet)
  }

  async function writeCsv (files) {
    const file = files[0]
    const readStream = await readStreamForFile(file)

    console.log(`Starting to read ${file} into the table`)

    const csvStream = csv.createStream({ enclosedChar: '"' })
    readStream
      .on('error', err => {
        console.error(err)
      })
      .on('end', async () => {
        await flushToDb()
        console.log(`ended reading ${file}`)
        const remainingFiles = files.filter(remainingFile => fileFromPath(file) !== fileFromPath(remainingFile))
        if (remainingFiles.length > 0) {
          readStream.destroy()
          setTimeout(writeCsv, 5000, remainingFiles)
        } else {
          console.log(`completed in ${Math.round(((new Date()) - start) / 1000)}s`)
        }
      })
      .pipe(csvStream)
      .on('data', data => {
        buffer.push(data)
        if (buffer.length === bufferSize) {
          flushToDb()
        }
      })
      .on('error', err => {
        console.error(err)
      })
  }
}

function fetchDirectory () {
  return unzipper.Open.url(
    request,
    {
      url: `https://ons.maps.arcgis.com/sharing/rest/content/items/${resourceId}/data`,
      callback: (_error, _response, _body) => {
        // just ignore any error as they are likely connection resets at the beginning or end of a file
      }
    }
  )
}

async function readStreamForFile (file) {
  const directory = await fetchDirectory()
  const matchedFiles = directory.files.filter(entry => entry.path.includes(file))
  return matchedFiles[0].stream()
}

function fileFromPath (path) {
  return path.split('/').slice(-1)[0]
}

function noFilesToRead () {
  console.log('No ONS UPRN Directory files to read in.')
}

async function versionMonthForId (resourceId) {
  const metadataResponse = await fetch(`https://www.arcgis.com/sharing/rest/content/items/${resourceId}/info/metadata/metadata.xml`)
  const metadata = new XMLParser().parse(
    await metadataResponse.text()
  )
  // the following node in the metadata XML may change any time - it may be necessary to change this path to find the document title
  const resourceDescription = metadata?.metadata?.dataIdInfo?.idCitation?.resTitle
  if (!resourceDescription) {
    throw new Error('The month of the UPRN Directory release could not be read from the metadata XML - please check the lookup path, which is currently metadata->metadata->dataIdInfo->idCitation->resTitle')
  }
  const monthRegex = /\((\w*)\s(\d{4})\)/
  const [monthName, year] = resourceDescription.match(monthRegex).slice(1, 3)
  const monthDate = new Date(`${monthName} 10, ${year}`)

  return `${monthDate.getFullYear()}-${(monthDate.getMonth() + 1).toString().padStart(2, '0')}`
}

async function registerVersionMonth (month, db) {
  if (!month.match(/^2\d{3}-[0-1]\d$/)) {
    throw new Error(`The month "${month}" does not have the expected format`)
  }
  const sql = 'INSERT INTO ons_uprn_directory_versions (version_month) VALUES ($1) RETURNING id'
  const params = [month]

  const result = await db.query(sql, params)

  return result.rows[0].id
}

async function insertDirectoryData (data, versionId, db, cs) {
  try {
    const dataToInsert = data.map(row => {
      const { uprn, pcds, ...rowRest } = row
      return {
        uprn: canonicaliseUprn(row.uprn),
        postcode: row.pcds,
        areas: rowRest,
        version_id: versionId
      }
    })
    const query = pgp.helpers.insert(dataToInsert, cs)

    await db.none(query)
  } catch (e) {
    console.error(e)
  }
}

function insertDirectoryColumnSet () {
  return new pgp.helpers.ColumnSet(['uprn', 'postcode', 'areas:json', 'version_id'], { table: 'ons_uprn_directory' })
}

function canonicaliseUprn (uprn) {
  if (!uprn.match(/^\d*$/)) {
    return uprn
  }

  return `UPRN-${uprn.padStart(12, '0')}`
}

function connectionOptions () {
  return { connectionString: process.env.DATABASE_URL, ssl: process.env.DATABASE_URL.includes('rds') }
}
