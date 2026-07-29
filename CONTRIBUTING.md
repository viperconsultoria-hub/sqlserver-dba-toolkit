# Contributing

Thank you for improving SQL Server DBA Toolkit. Contributions should make operational work safer, clearer, or more repeatable.

## Ways to contribute

- Add or improve a diagnostic script.
- Reproduce and fix a compatibility issue.
- Improve documentation, examples, or dashboard datasets.
- Review pull requests and validate scripts on supported versions.
- Propose a focused feature with a real operational use case.

## Before you start

Search existing issues and pull requests. For substantial changes, open an issue describing the problem, platform versions, expected result, permissions, performance impact, and alternatives.

## Development workflow

1. Fork the repository and create a branch from `main`.
2. Use a focused branch name such as `feature/query-store-regressions`, `fix/backup-time-zone`, or `docs/grafana-alerting`.
3. Make the smallest coherent change and add validation evidence.
4. Run the same checks as CI.
5. Open a pull request and complete every section of the template.

## Commit standard

Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```text
feat(indexes): add redundant index detector
fix(backup): handle copy-only full backups
docs(grafana): document connection pooling
```

Allowed common types include `feat`, `fix`, `docs`, `refactor`, `test`, `ci`, and `chore`. Use imperative, concise subjects and explain operational tradeoffs in the body.

## Naming

- Use lowercase kebab-case filenames: `top-cpu-queries.sql`.
- Put a script in the narrowest applicable folder.
- Prefer descriptive names over abbreviations.
- Do not include customer, server, database, or ticket names.

## SQL style

- Write keywords in uppercase and terminate statements with semicolons.
- Schema-qualify objects and qualify columns in joins.
- Avoid `SELECT *`, undocumented objects, and `NOLOCK`.
- Use `TRY...CATCH`, `QUOTENAME`, and parameterization where relevant.
- Make mutations opt-in with an `@Execute` or equivalent switch defaulting to `0`.
- State DMV reset semantics, permissions, compatibility, units, and limitations.
- Never embed credentials, connection strings, personal data, or environment-specific paths.

Every script must include:

```sql
/*
Name:
Description:
Author: SQL Server DBA Toolkit Contributors
Version:
Compatibility:
Permissions:
Usage:
Notes:
*/
```

## Documentation style

Use clear English, relative links for repository content, meaningful link labels, fenced code blocks with language identifiers, and tables only when they improve scanning. Add Microsoft Learn references for platform behavior.

## Local validation

Install Node.js and Python, then run:

```bash
npx --yes markdownlint-cli2 "**/*.md"
python -m pip install sqlfluff
sqlfluff lint scripts dashboards --dialect tsql
npx --yes markdown-link-check README.md
```

CI performs broader Markdown, SQL, and link checks. A SQL lint exception must be narrow and explained in the pull request.

## Pull requests

Keep pull requests focused. Include:

- the problem and approach;
- tested SQL Server/Azure SQL versions;
- required permissions;
- before/after or representative output with sensitive values removed;
- execution-plan or load impact for performance-sensitive changes;
- rollback or disablement notes for state-changing behavior.

At least one maintainer review and passing checks are required before merge. Maintainers may request changes to preserve safety and catalog consistency.

## Bugs and features

Use the issue template. A good bug report includes exact versions, a minimal reproduction, sanitized error text, expected behavior, and whether the issue is a regression. A good feature request begins with the operational problem rather than a proposed implementation.

## Conduct and license

Participation is governed by the [Code of Conduct](CODE_OF_CONDUCT.md). By contributing, you agree that your contribution is licensed under the [MIT License](LICENSE).
