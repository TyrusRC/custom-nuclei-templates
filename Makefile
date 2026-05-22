.PHONY: help validate lint check-dup stats index test

help:
	@echo "Targets:"
	@echo "  validate           nuclei -validate across templates/"
	@echo "  lint               yamllint across templates/"
	@echo "  check-dup ID=<id>  scripts/check-not-upstream.sh <id>"
	@echo "  index              (re)build docs/upstream-index/ from upstream"
	@echo "  test               run bats tests"
	@echo "  stats              template counts per category and severity"

validate:
	nuclei -validate -t templates/

lint:
	yamllint -d '{extends: default, rules: {line-length: disable, document-start: disable}}' templates/

check-dup:
	@if [ -z "$(ID)" ]; then echo "Usage: make check-dup ID=<id-or-cve>"; exit 2; fi
	@./scripts/check-not-upstream.sh $(ID)

index:
	./scripts/build-upstream-index.sh

test:
	bats tests/

stats:
	@echo "Templates per category:"
	@for d in templates/*/; do \
	  count=$$(find $$d -name '*.yaml' | wc -l); \
	  printf "  %-22s %s\n" "$$(basename $$d)" "$$count"; \
	done
	@echo ""
	@echo "Severity breakdown:"
	@grep -rhE '^[[:space:]]*severity:' templates/ 2>/dev/null \
	  | awk '{print $$2}' | sort | uniq -c | sort -rn
