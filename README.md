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


Once you have set this up, run the command

`make setup-db`

This creates the development and test databases referenced in the `config/database.yml`  
It also seeds the development database with attribute data and attribute values for the three test certificates stored in the local directory  `/spec/fixtures/json_export/`

You can re-run the seed command independently using the following cmd:

`rake seed_test_data`

Code Formatting

To run Rubocop on its own, run:

make format



