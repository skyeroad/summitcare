# SummitCare incident runbook

Fictional, for the companion code of *A Primer on HIPAA for Healthcare Systems
Developers* (Solution 31). Owner: the compliance officer (Morgan Reyes in the
book). Breach determinations are legal decisions made with counsel.

1. **Detect.** Anyone can open an incident: an alert from Solution 17, a patient complaint, a vendor notice. Record `detected_at` and who reported it.
2. **Contain.** Revoke sessions (Solution 30, `Offboarding.call` or `DeviceSession#revoke!`), rotate exposed credentials, block the source. Stop the bleeding before investigating.
3. **Preserve evidence.** Take an RDS snapshot, copy relevant logs, and keep the audit archive untouched (Object Lock protects it). Don't rebuild a compromised host before imaging it.
4. **Assess.** Scope affected patients with `IncidentScope.patient_ids`, set `discovered_at`, and complete the four-factor risk assessment (`Incident::RISK_FACTORS`) with counsel.
5. **Notify.** If it's a breach, send notices before `notification_deadline` (individuals, and HHS for 500 or more) or `hhs_annual_log_due_on` (fewer than 500). A law enforcement request can delay notice under §164.412; document it.
6. **Remediate.** Fix the root cause, not only the symptom.
7. **Learn.** Hold a blameless review, update the risk analysis, and add a test or alert that would have caught it sooner.
