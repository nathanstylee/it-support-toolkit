# IT Support Toolkit

Sanitized examples of support tooling, documentation templates, and case studies for IT Support, Application Support, Systems Support, and Internal Tools roles.

## Overview

This repository demonstrates how I approach hands-on IT and application support work: safe maintenance, practical troubleshooting, production readiness, documentation, health checks, and support automation.

The examples are intentionally generic. They do not contain company code, private business logic, internal hostnames, real database names, credentials, customer data, or proprietary workflows.

## What This Demonstrates

- Dry-run-first maintenance scripts
- PowerShell automation for common support tasks
- Basic secret scanning before publishing or sharing code
- SQL Server Express schema inventory concepts
- Windows service and application support thinking
- Deployment validation, smoke tests, and rollback planning
- Clear runbooks and incident documentation
- Support habits for manufacturing and shop-floor systems

## Repository Contents

| Path | Purpose |
| --- | --- |
| `powershell/safe-project-cleanup.ps1` | Dry-run-first cleanup script for generated folders and temporary files |
| `powershell/scan-secrets.ps1` | Generic scanner for common secret patterns before publishing or sharing files |
| `powershell/sql-schema-inventory.ps1` | Generic SQL Server schema inventory script that exports JSON and Markdown |
| `templates/support-runbook-template.md` | Reusable support runbook template for applications and systems |
| `templates/deployment-checklist.md` | Practical deployment checklist for support and validation work |
| `templates/incident-notes-template.md` | Incident note template for troubleshooting and follow-up |
| `case-studies/manufacturing-app-support-runbook.md` | Sanitized case study for manufacturing application support |
| `case-studies/internal-tools-support-case-study.md` | Sanitized case study for internal tools support and ownership |

## How To Use

Review the templates and adapt the placeholders to your own lab, demo, or training environment. The PowerShell scripts are designed to be read first and run cautiously.

Examples:

```powershell
# Preview cleanup candidates only
.\powershell\safe-project-cleanup.ps1 -Path C:\Repos\SampleProject

# Apply cleanup after reviewing the dry run
.\powershell\safe-project-cleanup.ps1 -Path C:\Repos\SampleProject -Apply

# Scan a project before publishing or sharing it
.\powershell\scan-secrets.ps1 -Path C:\Repos\SampleProject

# Inventory a local SQL Server Express sample database
.\powershell\sql-schema-inventory.ps1 -Server ".\SQLEXPRESS" -Database "SampleDatabase" -UseWindowsAuth
```

## Skills Reflected

- Windows support and troubleshooting
- PowerShell scripting
- SQL Server Express support
- Windows service support
- Internal web application support
- Manufacturing and shop-floor application support
- Deployment validation and smoke testing
- Documentation, runbooks, and incident notes
- Safe maintenance and change control habits

## Privacy / Sanitization Note

This repository contains sanitized examples only. It does not include private company repositories, production code, real hostnames, real IP addresses, internal URLs, credentials, customer data, machine names, database names, or proprietary business workflows.

