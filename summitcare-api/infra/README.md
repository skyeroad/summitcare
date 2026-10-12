# infra/

Infrastructure snippets from the book, kept next to the code they support. All
account IDs, ARNs, and key IDs are the AWS documentation placeholders.

| File | Solution |
|---|---|
| `rds-backups.sh` | 28: backup retention and cross-region copies |
| `s3-replication.json` | 28: replicate PHI documents to the DR bucket |
| `phi-documents-bucket-policy.json` | 9: deny non-TLS access to the documents bucket |
| `summitcare-app-policy.json` | 34: the app role's least-privilege policy |

The audit archive bucket's Object Lock (Solution 14) is set once by an
infrastructure admin:

    aws s3api put-object-lock-configuration --bucket summitcare-audit-archive \
      --object-lock-configuration \
      '{"ObjectLockEnabled":"Enabled","Rule":{"DefaultRetention":{"Mode":"COMPLIANCE","Years":6}}}'
