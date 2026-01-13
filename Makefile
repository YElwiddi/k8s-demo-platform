.PHONY: help lint template deploy-dev deploy-staging deploy-prod delete-dev delete-staging delete-prod deps

NAMESPACE_DEV ?= demo-dev
NAMESPACE_STAGING ?= demo-staging
NAMESPACE_PROD ?= demo-prod
RELEASE_NAME ?= platform

help:
	@echo "Available targets:"
	@echo "  deps            - Update Helm dependencies"
	@echo "  lint            - Lint all charts"
	@echo "  template-dev    - Template dev environment"
	@echo "  template-staging- Template staging environment"
	@echo "  template-prod   - Template prod environment"
	@echo "  deploy-dev      - Deploy to dev environment"
	@echo "  deploy-staging  - Deploy to staging environment"
	@echo "  deploy-prod     - Deploy to prod environment"
	@echo "  delete-dev      - Delete dev deployment"
	@echo "  delete-staging  - Delete staging deployment"
	@echo "  delete-prod     - Delete prod deployment"

deps:
	cd charts/platform && helm dependency update

lint:
	helm lint charts/frontend
	helm lint charts/backend-api
	helm lint charts/redis
	helm lint charts/postgresql
	cd charts/platform && helm dependency update && helm lint .

template-dev: deps
	helm template $(RELEASE_NAME) charts/platform \
		--namespace $(NAMESPACE_DEV) \
		--values environments/values-dev.yaml

template-staging: deps
	helm template $(RELEASE_NAME) charts/platform \
		--namespace $(NAMESPACE_STAGING) \
		--values environments/values-staging.yaml

template-prod: deps
	helm template $(RELEASE_NAME) charts/platform \
		--namespace $(NAMESPACE_PROD) \
		--values environments/values-prod.yaml

deploy-dev: deps
	helm upgrade --install $(RELEASE_NAME) charts/platform \
		--namespace $(NAMESPACE_DEV) \
		--create-namespace \
		--values environments/values-dev.yaml \
		--wait --timeout 10m

deploy-staging: deps
	helm upgrade --install $(RELEASE_NAME) charts/platform \
		--namespace $(NAMESPACE_STAGING) \
		--create-namespace \
		--values environments/values-staging.yaml \
		--wait --timeout 10m

deploy-prod: deps
	helm upgrade --install $(RELEASE_NAME) charts/platform \
		--namespace $(NAMESPACE_PROD) \
		--create-namespace \
		--values environments/values-prod.yaml \
		--wait --timeout 15m

delete-dev:
	helm uninstall $(RELEASE_NAME) --namespace $(NAMESPACE_DEV) || true
	kubectl delete namespace $(NAMESPACE_DEV) || true

delete-staging:
	helm uninstall $(RELEASE_NAME) --namespace $(NAMESPACE_STAGING) || true
	kubectl delete namespace $(NAMESPACE_STAGING) || true

delete-prod:
	@echo "WARNING: This will delete the production deployment!"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ]
	helm uninstall $(RELEASE_NAME) --namespace $(NAMESPACE_PROD) || true
