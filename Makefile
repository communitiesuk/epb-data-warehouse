.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help format test run setup-db seed-test-data generate-manifest deploy-app migrate-db-and-wait-for-success

PAAS_API ?= api.london.cloud.service.gov.uk
PAAS_ORG ?= mhclg-energy-performance
PAAS_SPACE ?= ${STAGE}

define check_space
	@echo "Checking PaaS space is active..."
	$(if ${PAAS_SPACE},,$(error Must specify PAAS_SPACE))
	@[ $$(cf target | grep -i 'space' | cut -d':' -f2) = "${PAAS_SPACE}" ] || (echo "${PAAS_SPACE} is not currently active cf space" && exit 1)
endef

help: ## Print help documentation
	@echo -e "Makefile Help for epb-data-warehouse"
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

format: ## Runs Rubocop with the GOV.UK rules
	@bundle exec rubocop --auto-correct

setup-db: ## Creates local development and test databases
	@echo ">>>>> Creating DB"
	@bundle exec rake db:create DATABASE_URL="postgresql://postgres:${DOCKER_POSTGRES_PASSWORD}@localhost:5432/epb_eav_test"
	@bundle exec rake db:create DATABASE_URL="postgresql://postgres:${DOCKER_POSTGRES_PASSWORD}@localhost:5432/epb_eav_development"
	@echo ">>>>> Migrating DB"
	@bundle exec rake db:migrate DATABASE_URL="postgresql://postgres:${DOCKER_POSTGRES_PASSWORD}@localhost:5432/epb_eav_test"
	@bundle exec rake db:migrate DATABASE_URL="postgresql://postgres:${DOCKER_POSTGRES_PASSWORD}@localhost:5432/epb_eav_development"

seed-test-data:
	@echo ">>>>> Seeding DB with test data"
	@bundle exec rake seed_test_data DATABASE_URL="postgresql://postgres:${DOCKER_POSTGRES_PASSWORD}@localhost:5432/epb_eav_development"

test:
	@bundle exec rspec

run:
	@bundle exec ruby app.rb

generate-manifest: ## Generate manifest file for PaaS
	$(if ${DEPLOY_APPNAME},,$(error Must specify DEPLOY_APPNAME))
	$(if ${PAAS_SPACE},,$(error Must specify PAAS_SPACE))
	@scripts/generate-manifest.sh ${DEPLOY_APPNAME} ${PAAS_SPACE} > manifest.yml

deploy-app: ## Deploys the app to PaaS
	$(call check_space)
	$(if ${DEPLOY_APPNAME},,$(error Must specify DEPLOY_APPNAME))

	@$(MAKE) generate-manifest

	cf apply-manifest -f manifest.yml

	cf set-env "${DEPLOY_APPNAME}" BUNDLE_WITHOUT "test"
	cf set-env "${DEPLOY_APPNAME}" STAGE "${PAAS_SPACE}"

	cf push "${DEPLOY_APPNAME}" --strategy rolling

migrate-db-and-wait-for-success:
	$(if ${DEPLOY_APPNAME},,$(error Must specify DEPLOY_APPNAME))
	cf run-task ${DEPLOY_APPNAME} --command "rake db:migrate" --name migrate
	@scripts/check-for-migration-result.sh

