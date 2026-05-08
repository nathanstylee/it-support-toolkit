# Deployment Checklist

## Pre-Deployment

- [ ] Confirm deployment request, ticket, or change record.
- [ ] Confirm deployment window and affected users.
- [ ] Complete pre-deploy backup or restore point.
- [ ] Verify deployment package, script, or installer source.
- [ ] Review configuration values for the target environment.
- [ ] Confirm rollback package or prior version is available.

## System Checks

- [ ] Confirm disk space is healthy.
- [ ] Confirm required Windows services are running.
- [ ] Confirm scheduled tasks are not mid-run.
- [ ] Confirm database connectivity.
- [ ] Confirm required file paths or shares are accessible.
- [ ] Confirm antivirus or endpoint tooling will not block deployment steps.

## Deployment

- [ ] Notify users or support channel that deployment is starting.
- [ ] Stop services, app pools, or scheduled tasks if required.
- [ ] Apply package, script, configuration, or database change.
- [ ] Start services, app pools, or scheduled tasks.
- [ ] Confirm service status after start.

## Validation

- [ ] Application login or launch test completed.
- [ ] Database read/write smoke test completed.
- [ ] Main user workflow smoke test completed.
- [ ] Logs checked for startup errors.
- [ ] User acceptance check completed with a representative user or requester.
- [ ] Performance or response time appears normal.

## Rollback Path

- [ ] Rollback owner identified.
- [ ] Prior version or backup location confirmed.
- [ ] Rollback steps documented.
- [ ] Criteria for rollback agreed before deployment.

## Post-Deployment

- [ ] Monitor logs for errors.
- [ ] Monitor support channel or ticket queue for user reports.
- [ ] Update documentation or runbook.
- [ ] Record deployment time, version, result, and any follow-up items.
- [ ] Close or update the change ticket.
