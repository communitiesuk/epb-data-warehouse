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

## Code Formatting

To run Rubocop on its own, run:

make format

## DataWarehouse API Service

To get this running locally run `bundle exec puma` or `bundle exec rackup -p 80 -o 0.0.0.0`.
