.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help format setup-db

help: ## Print help documentation
		@echo -e "Makefile Help for epb-data-warehouse"
		@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

format: ## Runs Rubocop with the GOV.UK rules
	@bundle exec rubocop --auto-correct --format offenses || true

setup-db: ## Creates local development and test databases
	@bundle exec rake db:create

	@bundle exec rake db:migrate
	@bundle exec rake db:migrate
	@echo ">>>>> Migrating DB"
	@bundle exec rake seed_test_data
	@echo ">>>>> Seeded DB"
