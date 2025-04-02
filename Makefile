.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help format test run setup-db seed-test-data generate-manifest deploy-app migrate-db-and-wait-for-success

help: ## Print help documentation
	@echo -e "Makefile Help for epb-data-warehouse"
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

format: ## Runs Rubocop with the GOV.UK rules
	@bundle exec rubocop --autocorrect

setup-db: ## Creates local development and test databases
	@echo ">>>>> Creating DB"
	@bundle exec rake db:create DATABASE_URL="postgresql://postgres:${DOCKER_POSTGRES_PASSWORD}@localhost:5432/epb_eav_test"
	@bundle exec rake db:create DATABASE_URL="postgresql://postgres:${DOCKER_POSTGRES_PASSWORD}@localhost:5432/epb_eav_development"
	@echo ">>>>> Migrating DB"
	@bundle exec rake db:migrate DATABASE_URL="postgresql://postgres:${DOCKER_POSTGRES_PASSWORD}@localhost:5432/epb_eav_test"
	@bundle exec rake db:migrate DATABASE_URL="postgresql://postgres:${DOCKER_POSTGRES_PASSWORD}@localhost:5432/epb_eav_development"


drop-db:
	@echo ">>>>> Dropping test db"
	@bundle exec rake db:drop DATABASE_URL="postgresql://postgres:${DOCKER_POSTGRES_PASSWORD}@localhost:5432/epb_eav_test"
	@echo ">>>>> Dropping dev db"
	@bundle exec rake db:drop DATABASE_URL="postgresql://postgres:${DOCKER_POSTGRES_PASSWORD}@localhost:5432/epb_eav_development"

seed-test-data:
	@echo ">>>>> Seeding DB with test data"
	@bundle exec rake seed_test_data DATABASE_URL="postgresql://postgres:${DOCKER_POSTGRES_PASSWORD}@localhost:5432/epb_eav_development"

test:
	@bundle exec rspec

run:
	@bundle exec rake

seed-stats-data:
	@bundle exec rake seed_countries
	@bundle exec rake seed_average_co2_emissions
	@bundle exec rake refresh_average_co2_emissions
