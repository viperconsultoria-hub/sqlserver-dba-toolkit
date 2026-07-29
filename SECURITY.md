# Security policy

## Supported versions

Security fixes are applied to the latest release line and the default branch.

| Version | Supported |
| --- | --- |
| Latest release | Yes |
| `main` | Yes |
| Older releases | No |

## Report a vulnerability

Do not open a public issue for a suspected vulnerability. Use [GitHub private vulnerability reporting](https://github.com/viperconsultoria-hub/sqlserver-dba-toolkit/security/advisories/new).

Include:

- affected file and revision;
- SQL Server or Azure SQL version;
- required permissions and execution context;
- impact and reproduction steps;
- suggested mitigation, if known.

Expect an acknowledgement within five business days. Maintainers will validate the report, agree on disclosure timing, prepare a fix, and credit the reporter unless anonymity is requested.

## Operational safety

Scripts are provided without warranty. Review every script, use least privilege, test restores, protect exported diagnostic data, and never paste secrets or production data into issues. State-changing scripts must remain preview-first and clearly describe rollback considerations.
