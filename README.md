# custom-nuclei-templates

Nuclei v3 templates filling gaps in [projectdiscovery/nuclei-templates](https://github.com/projectdiscovery/nuclei-templates) and [projectdiscovery/nuclei-templates-ai](https://github.com/projectdiscovery/nuclei-templates-ai).

102 templates · KEV CVEs, cloud misconfigs, subdomain takeovers, OWASP WSTG, exposed panels.

## Use

```bash
# all custom templates
nuclei -u https://target -t /path/to/custom-nuclei-templates/templates/

# scope by tag
nuclei -u https://target -t templates/ -tags custom,cve,kev
```

Every template carries the `custom` tag and a `# gap: <id>` first line documenting the upstream gap it fills.

## Categories

| Dir | Count | Scope |
|---|---|---|
| `cves/` | 25 | KEV-listed CVEs absent from both upstream repos |
| `cloud/` | 12 | AWS / GCP / Azure / Kubernetes misconfigs and unauth surfaces |
| `exposures/` | 26 | Admin panels, config files, debug endpoints |
| `misconfigurations/` | 25 | CORS, security headers, OWASP WSTG, default creds |
| `takeovers/` | 9 | Subdomain-takeover fingerprints (heroku, netlify, shopify, …) |
| `vulnerabilities/` | 5 | Active-injection probes (SSTI, CRLF, SSRF, OAuth redirect) |

## Develop

```bash
make validate                         # nuclei -validate
make lint                             # yamllint
make check-dup ID=CVE-YYYY-NNNNN      # check both upstream repos
make index                            # rebuild upstream dedup index
make stats                            # counts by category / severity
```

CVE templates: always run `make index` then `make check-dup` before adding — the index covers both `nuclei-templates` and `nuclei-templates-ai`.

## License

Apache 2.0 — see `LICENSE`.
