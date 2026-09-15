# epb-data-warehouse

EPBR Data storage application. Takes data stored in EPB-Register-Api database and stores it a database constructed on the [EAV data model](https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model)

## Prerequisites

* [Ruby](https://www.ruby-lang.org/en/)
* [PostgreSQL](https://www.postgresql.org/)
* Bundler (run `gem install bundler`)

## Installing

`bundle install`

### Creating a local database

Ensure you have Postgres 18 installed and available on localhost.  Additional ensure that `pg_dump` is in your path.

If your database is not on the default port, or requires a password these can be set by exporting `PGPORT` and `DOCKER_POSTGRES_PASSWORD`

```bash
# Setup the database
make setup-db

# setup seed data
make seed-test-data
make seed-stats-data
```

## Code Formatting

To run Rubocop on its own, run:

```bash
make format
```

## DataWarehouse API Service

To get this running locally run `bundle exec puma` or `bundle exec rackup -p 80 -o 0.0.0.0`.

## Adding XSD enumerable data to the database as attribute lookups

An EPC data point (attribute) can often be saved as a value that represents a string 
e.g for the attribute _energy_tariff_ the value 1 is stored. It can be any value between 1-5 for RdSAP (1-4 for SAP). The enumerable representations of 1 is _dual_.
The enum values are loaded into the database using the following command

`rake import_enums_xsd`

This rake parses the relevant XSD/XML files that hold the enumerable values as saves them to the database as attribute lookup data

The configuration for the enums import rake can be found in this file `/config/attribute_enum_map.json`
The configuration tells the application which data point the enumerable is for, which XML node contains the enumerable values and in which location for a certificate type

If any changes need to made to the enum data you will need to update the config file, push the changes and then run the import rake in all environments. 
This deletes all the attribute look ups and reloads them from the XSD.

NB To load all the enums into the database takes few minutes to run.
If you need to access this data for testing purposes there is a rake that loads the values into the development database and then creates a csv file in the /spec/fixtures/  
This file can then be used to load data into the test database in seconds.
To generate the test file run

`rake generate_enum_csv`

NB This will only need to be run if you want to change the existing test data.

## JSON Samples 

The code base contains code samples of every type of EPC certificate type and schema version that is supported for publication

The json samples matches the output of the API endpoint `/api/certificate/` which will vary depending on the certificate type and schema version

The files can be found at `/spec/fixtures/json_samples/`

The data for the samples is based on the corresponding XML sample. These files can be found at `/spec/fixtures/samples/`

To recreate the data in the json samples run the following command: 

`rake dev_setup:generate_json_examples`

This will delete the existing file and recreate based on any changes made to XML samples.

If changes are made to json being exported the rake will need to updated to reflect these changes.

## Environmental variables

#### `APP_ENV`

Set the [Sintra environment](https://sinatrarb.com/intro.html#environments).
Should be one of "production", "development" or "test".

Sinatra will fallback to `RACK_ENV` or "development" if unset.

#### `RAILS_ENV`

Sets the active record environment. This should be one of "production", "development" or "test".  It will default to
"development" if unset.

#### `RACK_ENV`

Used by rackup to choose the [default middleware stack](https://github.com/rack/rackup/blob/f3fa1d6ada90e9e7aa1f712488ddde87ea2a2075/lib/rackup/server.rb#L273).
Should be one of "development" (default) or "deployment". If set to any other value no middleware stack is loaded.

#### `STAGE`

The EPB environment. Can be one of "test", "development", "integration", "staging" or "production".

- Sets the unleash feature flag service app name to `toggles-#{stage}`
- Sets the Sentry environment
- When "production" prevents some destructive rake tasks from running

#### `DATABASE_URL`

The postgres URL of the database.

This is set in some of the `make` tasks and not overridable
 
#### `DOCKER_POSTGRES_PASSWORD`

The database password. Only used to build the `DATABASE_URL` in some `make` tasks

#### `PGPORT`

The database port. Only used to build the `DATABASE_URL` in some `make` tasks

#### `EPB_API_URL`

The url of the register api service.
 
#### `EPB_AUTH_CLIENT_ID`

The client id for connecting to the API services.

#### `EPB_AUTH_CLIENT_SECRET`

The client secret for connecting to the API services.

#### `EPB_AUTH_SERVER`

The URL of the auth server for connecting to the API services.

#### `EPB_UNLEASH_URI`

The URL of the unleash feature flag service.

#### `EPB_UNLEASH_AUTH_TOKEN`

Authentication token for the unleash feature flag service.

#### `EPB_DATA_USER_CREDENTIAL_TABLE_NAME`

DynamoDB table name containing the user credentials.

#### `EPB_QUEUES_URI`

URI of the redis server used for queues

#### `JWT_ISSUER`

Issuer for the JWT encoded auth token.

#### `JWT_SECRET`

Secret for the JWT encoded auth token.

#### `AWS_S3_USER_DATA_BUCKET_NAME`

S3 bucket containing the generated data downloads.

If `APP_ENV` is not set to "production" then a stubbed S3 client will be used.
