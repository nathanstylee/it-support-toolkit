# Manufacturing Application Support Runbook

## Overview

This sanitized case study describes support practices for internal applications used in a manufacturing environment. The systems supported operator workflows, quality checks, supervisor visibility, and shop-floor coordination.

All names, workflows, endpoints, database details, machine identifiers, and business rules have been removed or replaced with generic examples.

## Problem

Internal applications were important to daily production activity. When an application, Windows service, database connection, or related workstation had an issue, users needed quick triage and clear communication so production teams could keep working.

Common support needs included:

- Application launch or login issues
- Windows service restarts
- SQL Server Express connectivity checks
- Workstation or browser troubleshooting
- Log review after user-reported errors
- Smoke testing after updates
- Clear escalation notes when an issue required deeper investigation

## My Role

I supported internal applications and related tooling used by operators, quality staff, and supervisors. My work focused on practical troubleshooting, safe maintenance, documentation, and keeping support information organized enough that issues could be handled consistently.

I did not treat production changes casually. Before changes, I focused on backups, configuration checks, service status, database connectivity, and rollback planning.

## Tools / Concepts

- Windows desktop support
- Windows services
- PowerShell
- SQL Server Express
- Application logs and Event Viewer
- Internal web applications
- Shop-floor systems
- CNC / MTConnect familiarity
- Runbooks and incident notes
- Smoke tests and deployment validation

## Support Approach

1. Confirm the user impact and affected area.
2. Reproduce or verify the issue when possible.
3. Check workstation basics such as network access, browser state, permissions, and recent changes.
4. Check application health, service status, logs, and database connectivity.
5. Apply the least risky fix first, such as restarting a known service only after confirming it is safe.
6. Document the issue, action taken, verification, and follow-up items.
7. Escalate with useful details when the issue was beyond first response support.

## Health Checks

Typical checks included:

- Application page loads or desktop app opens.
- A known read-only screen or lookup works.
- SQL Server Express connection succeeds.
- Required Windows service is running.
- Recent logs do not show repeated errors.
- A basic workflow can be completed by a test or approved user.
- Users confirm the issue is resolved.

## Deployment / Rollback Thinking

For updates or maintenance, I used a practical checklist:

- Confirm the change request and deployment window.
- Confirm backup or restore point.
- Confirm configuration values for the target environment.
- Check service status before changes.
- Apply the change.
- Run smoke tests.
- Monitor logs and user feedback.
- Keep a rollback path ready if validation failed.

## What I Learned

Reliable support work is not only about fixing the immediate issue. It also depends on clear notes, repeatable checks, user communication, and knowing when to pause before making a risky change.

In manufacturing environments, small application issues can interrupt real operational work, so support needs to be calm, specific, and well documented.

## What Was Removed for Privacy

- Company names
- Real application names
- Internal URLs and hostnames
- Real IP addresses
- Machine identifiers
- Database names and table names
- Customer or production data
- Proprietary workflows and business rules
- Credentials, secrets, or environment values
