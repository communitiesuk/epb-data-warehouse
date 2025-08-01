import { XMLParser } from 'fast-xml-parser'
import fetch from 'node-fetch'
import got from 'got'
import unzipper from 'unzipper'
import csv from 'csv-stream'
import { parse as csvParse } from 'csv-parse'
import pgPromise from 'pg-promise'
import pgPkg from 'pg'
import fs from 'fs'
import path from 'path'
const { Pool: DbPool } = pgPkg
const pgp = pgPromise({})

const start = new Date()

const requestLib = options => {
  const { url, headers } = options
  const stream = got.stream(url, { headers })
  return Object.assign(stream, { abort: stream.destroy })
}

const args = process.argv.slice(2)
if (args.length === 0) {
  console.error('Please provide, as an argument, the ONS Postcode Directory resource ID for the month you are importing.')
  console.error('You can find it within the metadata for the published version - it is a 32 character length hex string.')
  console.error('Example usage: npm run populate_ons_postcode b81980b8ee1647a79bfe1abca7b14aab')
  process.exit(1)
}

const resourceId = args[0]
if (!resourceId.match(/^[0-9a-f]{32}$/)) {
  console.error(`The resource ID provided (${resourceId}) is not in the expected format of a 32 character hex string.`)
  process.exit(1)
}

const fileRegex = /ONSPD_\w{3}_\d{4}_\w{2}.csv/
const pathRegex = new RegExp(`Data\\/${fileRegex.source}`)

const bufferSize = 500

const nameTypes = {
  'Westminster parliamentary constituency': 'Westminster',
  'Local authority': 'LA_UA',
  Country: 'Country',
  Region: 'Region'
}

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

  const dbP = pgp(connectionOptions())

  const columnSet = insertDirectoryColumnSet()

  await truncateTables(dbP)

  try {
    await registerVersionMonth(versionMonth, db)

    await writeCsv(files)
  } catch (e) {
    console.log(e)
  } finally {
    await db.end()
  }

  await writeNamesTable(dbP)

  async function flushToDb () {
    const batch = buffer.splice(0, buffer.length) // grabs copy of buffer and empties it in one operation
    // console.log(`Batch to write has size ${batch.length}`)
    await insertDirectoryData(batch, dbP, columnSet)
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
    requestLib,
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
  console.log('No ONS Postcode Directory files to read in.')
}

// each release of the Postcode Directory has a metadata file in XML format - in order to find the version month automatically we can parse this to find a month string, e.g. "November 2021", and return the version month string ("2021-11")
async function versionMonthForId (resourceId) {
  const metadataResponse = await fetch(`https://www.arcgis.com/sharing/rest/content/items/${resourceId}/info/metadata/metadata.xml`)
  const metadata = new XMLParser().parse(
    await metadataResponse.text()
  )
  // the following node in the metadata XML may change any time - it may be necessary to change this path to find the document title
  const resourceDescription = metadata?.metadata?.dataIdInfo?.idCitation?.resTitle
  if (!resourceDescription) {
    throw new Error('The month of the Postcode Directory release could not be read from the metadata XML - please check the lookup path, which is currently metadata->metadata->dataIdInfo->idCitation->resTitle')
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
  const sql = 'INSERT INTO ons_postcode_directory_versions (version_month, created_at, updated_at) VALUES ($1, NOW(), NOW()) RETURNING id'
  const params = [month]

  const result = await db.query(sql, params)

  return result.rows[0].id
}

async function insertDirectoryData (data, db, cs) {
  try {
    const dataToInsert = data.map(lowercaseObjectKeys).map(row => {
      const { pcds, ctry, rgn, oslaua, pcon, ...rowRest } = row
      return {
        postcode: pcds.trim(),
        country_code: ctry,
        region_code: rgn,
        local_authority_code: oslaua,
        westminster_parliamentary_constituency_code: pcon,
        other_areas: rowRest
      }
    })
    const query = pgp.helpers.insert(dataToInsert, cs)

    await db.none(query)
  } catch (e) {
    console.error(e)
  }
}

function insertDirectoryColumnSet () {
  return new pgp.helpers.ColumnSet(['postcode', 'country_code', 'region_code', 'local_authority_code', 'westminster_parliamentary_constituency_code', 'other_areas:json'], { table: 'ons_postcode_directory' })
}

function lowercaseObjectKeys (obj) {
  return Object.fromEntries(Object.entries(obj).map(([k, v]) => [k.toLowerCase(), v]))
}

function connectionOptions () {
  const directoryPath = path.join(process.cwd(), '/config/eu-west-2-bundle.pem');
  return {
    connectionString: process.env.DATABASE_URL,
    ssl: {
      require: true,
      rejectUnauthorized: true,
      ca: fs.readFileSync(directoryPath).toString(),
    }
  }
}

async function writeNamesTable (db) {
  const nameData = await getNamesData()
  const columnSet = directoryNamesColumnSet()
  return nameData.map(async (typeData) => {
    const { name: typeName, typeCode } = typeData
    const dataToInsert = typeData.data.map(record => ({
      area_code: record[0],
      name: record[1],
      type: typeName,
      type_code: typeCode.toLowerCase()
    }))
    const query = pgp.helpers.insert(dataToInsert, columnSet)
    await db.none(query)
  })
}

async function getNamesData () {
  const directory = await fetchDirectory()
  return Promise.all(Object.entries(nameTypes).map(async ([name, filePrefix]) => {
    const nameFileEntries = directory.files.filter(entry => entry.path.match(new RegExp(`Documents\\/${filePrefix}.*.csv$`)))
    if (nameFileEntries.length === 0) {
      return null
    }
    const csvFile = fileFromPath(nameFileEntries[0].path)
    const records = []
    let hasParsedHeaders = false
    let namePosition
    let typeCode
    const readStream = await readStreamForFile(csvFile)
    const parser = readStream.pipe(csvParse({ bom: true }))
    for await (const record of parser) {
      if (!hasParsedHeaders) {
        namePosition = record.findIndex(element => element.endsWith('NM')) // the name field codes (generally) end in 'NM'
        typeCode = record[0]
        hasParsedHeaders = true
        continue
      }
      if (!record[0]) {
        continue
      }
      records.push([record[0], record[namePosition]])
    }
    return { name, data: records, typeCode }
  })).then(namesData => namesData.filter(x => x))
}

function directoryNamesColumnSet () {
  return new pgp.helpers.ColumnSet(['area_code', 'name', 'type', 'type_code'], { table: 'ons_postcode_directory_names' })
}

async function truncateTables (db) {
  console.log('Truncating existing tables')
  const sql = 'TRUNCATE ons_postcode_directory, ons_postcode_directory_names'
  await db.none(sql)
}
