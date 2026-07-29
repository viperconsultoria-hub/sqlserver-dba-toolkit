# Roadmap

The roadmap communicates direction, not a guarantee. Priorities may change based on community feedback, platform changes, maintainer capacity, and security needs.

## Principles

- Keep diagnostic queries observable, explainable, and safe by default.
- Prefer portable T-SQL and document version-specific behavior.
- Treat dashboards as optional views over auditable query datasets.
- Add automation only when it remains easy to review and reverse.

## Milestones

| Release | Theme | Planned outcomes |
| --- | --- | --- |
| v1.0 | Reliable foundation | Core script catalog, consistent headers, documentation, CI, Power BI and Grafana starter datasets |
| v1.1 | Cloud observability | Azure Monitor integration, richer Azure SQL metrics, Prometheus exporter guidance, dashboard versioning |
| v2.0 | Automated operations | Docker-based validation lab, Kubernetes examples, signed releases, script metadata index, regression fixtures |
| v3.0 | Data-platform breadth | PostgreSQL, MySQL, and Oracle adapters; Elastic and OpenTelemetry pipelines; cross-platform service-level views |

## v1.0 — Foundation

- [x] Performance, monitoring, backup, maintenance, security, and availability scripts
- [x] Preview-first state-changing scripts
- [x] Contributor guide, security policy, Code of Conduct, and MIT license
- [x] Markdown, SQL, link, and release workflows
- [x] Power BI and Grafana documentation and query datasets
- [ ] Validate scripts against a public version matrix

## v1.1 — Azure and metrics

- [ ] Azure Monitor workbook examples
- [ ] Azure SQL Database watcher examples
- [ ] Prometheus exporter reference deployment
- [ ] Versioned dashboard schemas and backward-compatibility notes
- [ ] Automated compatibility metadata report

## v2.0 — Automation and platforms

- [ ] Reproducible Docker validation lab
- [ ] Kubernetes deployment and secret-management examples
- [ ] Policy-as-code checks for risky T-SQL
- [ ] Signed release artifacts and generated checksums
- [ ] Machine-readable script catalog

## v3.0 — Unified data observability

- [ ] PostgreSQL, MySQL, and Oracle diagnostic packs
- [ ] Elastic ingestion examples
- [ ] OpenTelemetry semantic conventions for database operations
- [ ] Cross-engine SLO and capacity dashboards
- [ ] Pluggable collectors with stable output contracts

## Propose an item

Open a [feature request](https://github.com/viperconsultoria-hub/sqlserver-dba-toolkit/issues/new) with the operational problem, target platforms, expected output, permissions, and validation evidence.
