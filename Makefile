.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.PHONY: format
format:
	@bundle exec rubocop --auto-correct --format offenses || true

.PHONY: setup-db
setup-db:
	@bundle exec rake db:create
	@bundle exec rake db:migrate
	@echo ">>>>> Migrating DB"
	@bundle exec rake seed_test_data
	@echo ">>>>> Seeded DB"





