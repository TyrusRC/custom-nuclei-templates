# custom-nuclei-templates

[![validate](https://github.com/TyrusRC/custom-nuclei-templates/actions/workflows/validate.yml/badge.svg)](https://github.com/TyrusRC/custom-nuclei-templates/actions/workflows/validate.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Templates](https://img.shields.io/badge/templates-155-brightgreen)](templates/)
[![Tested with nuclei](https://img.shields.io/badge/tested%20with-nuclei%20v3.4.7-orange)](https://github.com/projectdiscovery/nuclei)

> **Unaffiliated.** Independent, community-maintained YAML detection templates that run on the [nuclei](https://github.com/projectdiscovery/nuclei) scanner. Not produced, endorsed, or maintained by [ProjectDiscovery](https://projectdiscovery.io). "Nuclei" and "nuclei-templates" are projects of ProjectDiscovery and referenced here only as the runtime / coverage baseline this repo complements.

Evergreen **bug-class / family detection** templates — patterns that catch *future* CVEs in the same class, not single named CVEs. Built to fill gaps in the upstream [nuclei-templates](https://github.com/projectdiscovery/nuclei-templates) and [nuclei-templates-ai](https://github.com/projectdiscovery/nuclei-templates-ai) collections.

## Why bug-class detection?

CVE-specific fingerprints go stale the moment upstream ships a template. Every template here keys off **attacker-visible behavior** or **framework-stable response shape** (HAL `_links`, propertySources, route_id, JWKS structure, HTTP status differentials, etc.) — not vendor brand strings or version markers. The same matcher replays on the next variant in the same family.

Examples:

- `http-cl0-desync-probe` keys off a **status-shape invariant** (200/404 differential on a pipelined follow-up) — fires on any CL.0-vulnerable FE/BE pair regardless of vendor.
- `jwt-none-algorithm-accepted` keys off **canary acceptance** with an `alg:none` JWT carrying a sub claim of `nuclei-jwt-canary` — fires on any verifier that omits algorithm validation.
- `spring-actuator-heapdump-exposed` keys off the **HPROF magic bytes** + `Content-Disposition: attachment*heapdump` — fires on any Spring Boot heap dump regardless of version banner.

## Install

```bash
git clone https://github.com/TyrusRC/custom-nuclei-templates.git
```

Requires the [nuclei](https://github.com/projectdiscovery/nuclei) scanner — `v3.4.7+` tested.

## Use

```bash
# Scan a single target with the full custom set
nuclei -u https://target.example.com -t custom-nuclei-templates/templates/

# Filter by custom tag (every template carries 'custom')
nuclei -u https://target.example.com -t custom-nuclei-templates/templates/ -tags custom

# Scope by category
nuclei -u https://target.example.com -t custom-nuclei-templates/templates/vulnerabilities/
nuclei -u https://target.example.com -t custom-nuclei-templates/templates/cloud/

# Scope by severity
nuclei -u https://target.example.com -t custom-nuclei-templates/templates/ -severity critical,high
```

Every template starts with a `# gap: <id>` first line documenting the upstream gap it fills.

## Categories

| Directory | Count | Coverage |
|---|---|---|
| [`cloud/`](templates/cloud/) | 14 | AWS / GCP / Azure / Kubernetes misconfigurations and unauth surfaces (IMDS, kubelet, etcd, anon API, OpenAPI discovery, ECR, S3, Cloud Run, Lambda, OPA Gatekeeper bypass) |
| [`exposures/`](templates/exposures/) | 68 | Spring Boot actuator, Elasticsearch, Jenkins, Prometheus `/api/v1/targets`, Alertmanager, GraphQL, WEB-INF, `.git`/`.svn`, env files, dev tools, Envoy admin, OpenTelemetry zPages, Vault seal-status, Grafana Loki / Tempo, Linkerd dataplane, ArgoCD applications, Nomad jobs, Boundary auth-methods, Tekton PipelineRuns, Spinnaker applications, Istio Pilot debug, Flux CD HelmReleases, Crossplane Providers, LangServe Runnable, vLLM model list, n8n workflows, Backstage catalog, Kestra flows, Pulsar tenants, APISIX admin, Trino cluster, Druid coordinator, Redpanda brokers, Dify console, Flowise chatflows, Doris FE, InfluxDB v2 buckets, QuestDB /exec, Kafka Connect, Apache Pinot, SigNoz services, Milvus REST API (CVE-2026-26190) |
| [`misconfigurations/`](templates/misconfigurations/) | 35 | CORS, security headers, OWASP WSTG, default creds, h2c upgrade, JWKS symmetric keys, GraphQL field-suggestion, OAuth PKCE plain / implicit / password-grant advertised, OAuth dynamic client registration, OAuth jwks_uri over HTTP, OIDC userinfo anonymous, CSP effectively disabled, CSP frame-ancestors permissive, Service Worker root-scope |
| [`takeovers/`](templates/takeovers/) | 9 | Subdomain takeover fingerprints (Heroku, Netlify, Shopify, …) |
| [`vulnerabilities/`](templates/vulnerabilities/) | 29 | Active behavior-class probes — SSTI (active arithmetic + error-engine + boolean error-differential + `.zxy.zxy` polyglot, Vladko312 2026), SQL injection error (MySQL/Postgres/MSSQL/Oracle/SQLite/DB2/Sybase), OS command injection time-blind, JWT kid path traversal, CRLF, SSRF/IMDS, open redirect (URL / Referer / wildcard redirect_uri), JWT alg-none, NoSQL operator injection, XPath / LDAP injection error disclosure, PHP unserialize error disclosure, WebDAV PROPFIND listing, XXE, prototype pollution, Milvus /expr RCE (CVE-2026-26190), host-header password-reset poisoning, request smuggling family (CL.TE, CL.0, CSD, host-header obfuscation, Expect-header 0.CL leak from PortSwigger 2025), web cache deception |

## Detection paradigm

| Layer | What we key on | Examples |
|---|---|---|
| **Behavior** | Canary echoes, response-shape invariants, parser-differential status codes | JWT canary sub, prototype-pollution `nucleiPollute`, CL.0 follow-up 404 |
| **Framework shape** | API contracts that don't change across versions | HAL `_links`, Spring `propertySources`, K8s `NamespaceList` |
| **Magic bytes / standard formats** | File-format invariants | HPROF `JAVA PROFILE 1.0.2`, JSON Web Key Set structure |
| **Severity discipline** | `critical` only for unauth RCE, in-memory secret leak, source disclosure, takeover, auth bypass, cluster-admin RBAC | Severity-lint enforces justifying keywords (see [`scripts/severity-lint.sh`](scripts/severity-lint.sh)) |

What we **avoid**:

- Vendor brand strings (`Powered by Foo 1.2.3`)
- Version banners (`Server: Apache/2.4.41`) as primary detection
- CVE-ID-specific paths (`/vuln-2024-xxxxx`)
- Loose `contains(both)` matches that fire on docs/debug pages

## Develop

```bash
make help                  # list targets
make validate              # nuclei -validate -t templates/
make lint                  # yamllint
make severity-lint         # flag critical without justifying keyword
make template-meta-lint    # enforce # gap line / id / author / tags
make test                  # bats unit tests
make ci                    # all of the above

make index                 # rebuild docs/upstream-index/ from both upstream repos
make check-dup ID=<id>     # confirm an id is not already upstream
make stats                 # counts by category and severity
```

New templates must:

1. **Dedup** against both upstream repos via `make check-dup ID=<id>` (rebuild index first with `make index`).
2. **Key off behavior**, not vendor brand strings or single CVE markers.
3. **Pass `make ci`** (validate + yamllint + severity-lint + meta-lint + bats).
4. Start with a `# gap: <id>` first line.
5. Use the `custom` tag plus a category tag (`vulnerabilities`, `misconfig`, `cloud`, `exposure`, `takeover`).

Severity calibration is enforced — `critical` requires a description keyword in the family of `unauth.*rce`, `in-memory secret`, `heap dump`, `source disclosure`, `account takeover`, `auth bypass`, `cluster-admin`, `arbitrary command`, etc. See [`scripts/severity-lint.sh`](scripts/severity-lint.sh) for the full regex.

## CI

Every push / PR to `main` runs the full pipeline via [`.github/workflows/validate.yml`](.github/workflows/validate.yml):

- `yamllint` syntax check
- `nuclei -validate` semantic check
- `severity-lint` calibration check
- `template-meta-lint` metadata convention check
- `bats` dedup-script unit tests

## License

[Apache 2.0](LICENSE).

## Acknowledgments

- [ProjectDiscovery](https://github.com/projectdiscovery) — for the `nuclei` scanner and the upstream template ecosystem this repo complements
- [PortSwigger Research](https://portswigger.net/research) — request smuggling, desync, JWT, and cache-poisoning research backing the desync-family templates
- [OWASP WSTG](https://owasp.org/www-project-web-security-testing-guide/) — methodology for the misconfiguration probes
- [Reversec Labs](https://labs.reversec.com/) — OPA Gatekeeper bypass research

## Trademarks

"Nuclei" and "nuclei-templates" are projects of [ProjectDiscovery](https://projectdiscovery.io). All references are nominative and for interoperability only.
