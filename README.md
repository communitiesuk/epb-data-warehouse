# epb-data-warehouse
EPBR Data storage application. Takes data stored in EPB-Register-Api database and stores it a database constructed on the [EAV data model](https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model)

## Prerequisites

* [Ruby](https://www.ruby-lang.org/en/)
* [PostgreSQL](https://www.postgresql.org/)
* Bundler (run `gem install bundler`)

## Installing
`bundle install`

## Creating a local database

Ensure you have Postgres 11 installed. If you are working on a Mac, [this tutorial](https://www.codementor.io/engineerapart/getting-started-with-postgresql-on-mac-osx-are8jcopb) will take you through the process.

Be sure that `DATABASE_URL` is set, for example
```
DATABASE_URL="postgresql://postgres@localhost:5432/epb_eav_development"
```

Once you have set this up, run the command

`make setup-db`

This creates the database schema and runs the migrations scripts.

To seed the development database with attribute data and attribute values for the three test certificates stored in the local directory  `/spec/fixtures/json_export/`, please run the following cmd:

`bundle exec rake seed_test_data`

Once that database is set up and seed data has been imported you can use the crosstab function of postgres to extract data into a 2-d dataset. Examples can be found in `lib/gateway/assessment_attributes_gateway.rb`
A more comprehensive example can be found in the db migrations `db/migrate/20210802122736_add_open_data_export_view.rb` This creates a postgres view called 

that export the data in the format required by Open Data Communities. The run this view use the following psql command:

`SELECT * FROM vw_open_data_export`

## Running Code against Postgres In Container

If want to run your code against a version of postgres other than that already installed, you can specifiy a port in your nake commands

E.g To run the code base against Postgres v17 and you have Postgres 14 installed:

Installed Postgres 17 docker image:

`docker run -d -p 5431:5432  --name postgres-17 -e POSTGRES_PASSWORD=mysecretpassword -e POSTGRES_USER=postgres  postgres:17`

This command exposes postgres 17 on port 5431

To run code against this version 

`PGPORT=5431 make setup-db
PGPORT=5431 make test`


## Code Formatting

To run Rubocop on its own, run:

make format

## DataWarehouse API Service

To get this running locally run `bundle exec puma` or `bundle exec rackup -p 80 -o 0.0.0.0`.

## Adding XSD enumerable data to the database as attribute lookups

An EPC data point (attribute) can often be saved as a value that represents a string 
e.g for the attribute _energy_tariff_ the value 1 is stored. It can be any value between 0-5. The enumerable representations of 1 is_Very Poor_
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