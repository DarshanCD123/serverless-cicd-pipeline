.PHONY: help setup venv test lint format type-check clean build-docker security-scan deploy rollback

help:
	@echo "Serverless CI/CD Pipeline - Development Commands"
	@echo "================================================="
	@echo "Setup:     make setup, make venv"
	@echo "Testing:   make test, make test-unit, make test-coverage"
	@echo "Quality:   make lint, make format, make type-check"
	@echo "Security:  make security-scan-local, make check-deps"
	@echo "Docker:    make build-docker, make run-docker, make stop-docker"
	@echo "Deploy:    make deploy, make rollback"
	@echo "Terraform: make terraform-init, make terraform-plan, make terraform-apply"
	@echo "Cleanup:   make clean, make clean-docker"

setup: venv
	$(VENV)/pip install -r requirements.txt

VENV = venv
PYTHON = $(VENV)/bin/python
PIP = $(VENV)/bin/pip

venv:
	python3 -m venv $(VENV)

test:
	$(PYTHON) -m pytest tests/ -v --tb=short

test-unit:
	$(PYTHON) -m pytest tests/ -v -m unit

test-coverage:
	$(PYTHON) -m pytest tests/ --cov=src --cov-report=html

lint:
	$(PYTHON) -m flake8 src/ tests/
	format
	$(PYTHON) -m pylint src/

format:
	$(PYTHON) -m black src/ tests/

type-check:
	$(PYTHON) -m mypy src/ --ignore-missing-imports

security-scan-local:
	@echo "Running local security scan..."
	$(PYTHON) -m pip list > /tmp/requirements.txt
	@echo "Check dependencies in /tmp/requirements.txt"

build-docker:
	docker build -t serverless-cicd-pipeline:latest .

run-docker: build-docker
	docker run -it serverless-cicd-pipeline:latest

stop-docker:
	docker stop $$(docker ps -q --filter ancestor=serverless-cicd-pipeline:latest) || true
	deploy:
	@echo "Deploying to Lambda..."
	bash scripts/deploy.sh

rollback:
	@echo "Rolling back deployment..."
	bash scripts/rollback.sh

terraform-init:
	cd terraform && terraform init

terraform-plan:
	cd terraform && terraform plan

terraform-apply:
	cd terraform && terraform apply

clean:
	rm -rf venv build dist *.egg-info __pycache__ .pytest_cache .coverage htmlcov

clean-docker:
	docker rmi serverless-cicd-pipeline:latest || true
