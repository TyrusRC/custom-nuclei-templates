.PHONY: help validate lint severity-lint template-meta-lint check-dup stats index test ci

help:
	@echo "Targets:"
	@echo "  validate           nuclei -validate across templates/"
	@echo "  lint               yamllint across templates/"
	@echo "  severity-lint      flag critical-severity templates without justifying keywords"
	@echo "  template-meta-lint enforce # gap line / id / author / tags / no classification"
	@echo "  ci                 run all checks (validate + lint + severity-lint + meta-lint + test)"
	@echo "  check-dup ID=<id>  scripts/check-not-upstream.sh <id>"
	@echo "  index              (re)build docs/upstream-index/ from upstream"
	@echo "  test               run bats tests"
	@echo "  stats              template counts per category and severity"

validate:
	nuclei -validate -t templates/

lint:
	yamllint -d '{extends: default, rules: {line-length: disable, document-start: disable}}' templates/

severity-lint:
	@./scripts/severity-lint.sh

template-meta-lint:
	@./scripts/template-meta-lint.sh

ci: validate lint severity-lint template-meta-lint test

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
