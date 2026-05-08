# Support Runbook Template

## System Overview

- System name: `<ProductionApp>`
- Purpose: `<Brief description of what the system supports>`
- Business area: `<Operations, quality, shipping, maintenance, or other area>`
- Criticality: `<Low / Medium / High>`

## Owners / Contacts

| Role | Name / Team | Contact Method | Notes |
| --- | --- | --- | --- |
| Business owner | `<name or team>` | `<email or ticket queue>` | `<notes>` |
| IT owner | `<name or team>` | `<email or ticket queue>` | `<notes>` |
| Vendor | `<vendor support>` | `<support portal or phone>` | `<contract or hours>` |

## Environments

| Environment | Purpose | Server / Host | Database | Notes |
| --- | --- | --- | --- | --- |
| Production | Live users | `<server-name>` | `SampleDatabase` | `<notes>` |
| Test | Validation | `<server-name>` | `SampleDatabase_Test` | `<notes>` |

## Service Names

- Windows service: `<ServiceName>`
- Scheduled task: `<TaskName>`
- IIS site or app pool: `<SiteName>` / `<AppPoolName>`

## URLs / Access Paths

- User access: `<https://app.example.local>`
- Admin access: `<admin path or tool>`
- File share: `<\\server-name\share>`

## Ports

| Port | Protocol | Purpose | Notes |
| --- | --- | --- | --- |
| `<port>` | TCP | `<application traffic>` | `<firewall or access notes>` |

## Health Checks

- Confirm application page loads.
- Confirm Windows service is running.
- Confirm database connection succeeds.
- Confirm recent logs do not show repeated errors.
- Confirm a basic user workflow or smoke test passes.

## Logs

| Log Location | What To Look For | Retention |
| --- | --- | --- |
| `<path-to-log-folder>` | Startup errors, connection errors, failed jobs | `<retention>` |
| Windows Event Viewer | Service crashes, authentication issues | `<retention>` |

## Restart Procedure

1. Notify affected users or the support channel.
2. Confirm no active critical process is running.
3. Stop the related service, app pool, or scheduled task.
4. Wait for the process to exit cleanly.
5. Start the service, app pool, or scheduled task.
6. Run health checks and smoke tests.
7. Record the restart time and result.

## Common Issues

| Symptom | Initial Checks | Likely Next Step |
| --- | --- | --- |
| Application will not load | Service status, app pool, disk space, logs | Restart service or escalate |
| Users cannot save records | Database connectivity, permissions, recent changes | Validate database and app logs |
| Background job stopped | Scheduled task history, service logs | Restart job and monitor |

## Escalation Steps

1. Gather incident notes, screenshots, timestamps, and affected users.
2. Confirm whether the issue is isolated or system-wide.
3. Escalate to `<team or vendor>` with logs and reproduction steps.
4. Track updates in the ticket until resolution.

## Backup / Restore Notes

- Backup location: `<backup path or job name>`
- Backup schedule: `<schedule>`
- Restore owner: `<team or vendor>`
- Restore validation steps: `<steps>`

## Rollback Plan

- Last known good version: `<version or deployment package>`
- Rollback owner: `<name or team>`
- Rollback steps:
  1. Stop application traffic or notify users.
  2. Restore previous package or configuration.
  3. Restart services.
  4. Run smoke tests.
  5. Monitor logs and user reports.

## Go / No-Go Checklist

- [ ] Backup completed or restore point confirmed.
- [ ] Configuration reviewed.
- [ ] Service status checked.
- [ ] Database connectivity tested.
- [ ] Smoke tests passed.
- [ ] Rollback path confirmed.
- [ ] Stakeholders notified.

## Change History

| Date | Change | Updated By | Notes |
| --- | --- | --- | --- |
| `<yyyy-mm-dd>` | `<summary>` | `<name>` | `<notes>` |
