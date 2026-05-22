# custom-nuclei-templates

Custom Nuclei v3 templates that fill coverage gaps in
[projectdiscovery/nuclei-templates](https://github.com/projectdiscovery/nuclei-templates).

Focus areas: cloud misconfigurations, web exposures, subdomain takeovers,
network-service exposures, and recent/uncovered CVEs.

## Usage

Run alongside the official templates:

```bash
nuclei -t /path/to/custom-nuclei-templates/templates/ -u https://target
```

Scope to only this repo's templates with the `custom` tag:

```bash
nuclei -t /path/to/custom-nuclei-templates/templates/ -tags custom -u https://target
```

## Local workflow

```bash
make validate      # nuclei -validate across templates/
make lint          # yamllint across templates/
make check-dup ID=CVE-2024-12345   # confirm not already upstream
make stats         # template counts per category / severity
```

## Categories

| Directory | Contents |
| --- | --- |
| `templates/cves/` | CVE templates missing from official repo |
| `templates/cloud/` | AWS / GCP / Azure misconfigurations and exposures |
| `templates/exposures/` | Exposed config files, debug pages, admin panels |
| `templates/takeovers/` | Subdomain takeover detections (DNS-based) |
| `templates/misconfigurations/` | App-level misconfigs (CORS, headers, GraphQL introspection, ...) |
| `templates/network/` | Non-HTTP services (Redis, Mongo, Elastic, K8s API, Docker, ...) |
| `templates/vulnerabilities/` | Generic vuln patterns not tied to a CVE |

## License

See `LICENSE`.
