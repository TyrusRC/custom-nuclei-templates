# custom-nuclei-templates

Nuclei v3 templates filling gaps in [projectdiscovery/nuclei-templates](https://github.com/projectdiscovery/nuclei-templates) and [projectdiscovery/nuclei-templates-ai](https://github.com/projectdiscovery/nuclei-templates-ai).

83 templates · evergreen **bug-class / family detection** — patterns that catch future CVEs in the same class, not single named CVEs.

## Why no `cves/`?

CVE-specific fingerprints go stale the moment upstream ships a template. We pivoted (2026-05-25) to detection that fires on *attacker-visible behavior or framework misuse*, so the same matcher replays on the next variant.

## Use

```bash
nuclei -u https://target -t /path/to/custom-nuclei-templates/templates/
nuclei -u https://target -t templates/ -tags custom
```

Every template carries the `custom` tag and a `# gap: <id>` first line documenting the upstream gap it fills.

## Categories

| Dir | Count | Scope |
|---|---|---|
| `cloud/` | 12 | AWS / GCP / Azure / Kubernetes misconfigs and unauth surfaces |
| `exposures/` | 32 | Admin panels, config files, debug endpoints, Spring Boot actuator family |
| `misconfigurations/` | 25 | CORS, security headers, OWASP WSTG, default creds |
| `takeovers/` | 9 | Subdomain-takeover fingerprints (heroku, netlify, shopify, …) |
| `vulnerabilities/` | 5 | Active-class probes (SSTI, CRLF, SSRF IMDS, OAuth redirect) |

## Develop

```bash
make validate                         # nuclei -validate
make lint                             # yamllint
make index                            # rebuild upstream dedup index
make stats                            # counts by category / severity
```

New templates must dedup against both upstream repos via the index in `docs/upstream-index/`. Family-style detection should key off behavior (reflected payloads, header divergence, response shape) rather than vendor brand strings.

## License

Apache 2.0 — see `LICENSE`.
