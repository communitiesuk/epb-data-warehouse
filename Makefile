.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help format test run setup-db

help: ## Print help documentation
	@echo -e "Makefile Help for epb-data-warehouse"
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

format: ## Runs Rubocop with the GOV.UK rules
	@bundle exec rubocop --auto-correct

setup-db: ## Creates local development and test databases
	@echo ">>>>> Creating DB"
	@bundle exec rake db:create DATABASE_URL="postgresql://postgres@localhost:5432/epb_eav_development"
	@bundle exec rake db:create DATABASE_URL="postgresql://postgres@localhost:5432/epb_eav_test"
	@echo ">>>>> Migrating DB"
	@bundle exec rake db:migrate DATABASE_URL="postgresql://postgres@localhost:5432/epb_eav_development"
	@bundle exec rake db:migrate DATABASE_URL="postgresql://postgres@localhost:5432/epb_eav_test"

test:
	@bundle exec rspec

run:
	@bundle exec ruby app.rb
