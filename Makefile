.PHONY: help foreman-download foreman-version cleanup

help:
	@echo "Foreman API Documentation Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make foreman-version VERSION=X.Y         - Add or update Foreman version (auto-detects)"
	@echo "  make foreman-download VERSION=X.Y        - Download apidoc artifact from GitHub Actions"
	@echo "  make cleanup                             - Run cleanup script"
	@echo ""
	@echo "Example:"
	@echo "  make foreman-version VERSION=3.18"

foreman-download:
	@./scripts/foreman-download.sh $(VERSION)

cleanup:
	@./scripts/cleanup.sh

foreman-version: foreman-download
	@./scripts/foreman-process-version.sh $(VERSION)
	@$(MAKE) cleanup
	@echo ""
	@echo "Please review the changes and commit them."
