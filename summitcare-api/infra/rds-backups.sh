#!/usr/bin/env bash
# infra/rds-backups.sh (Solution 28): 35-day automated backups, copied to us-west-2.
set -euo pipefail
aws rds modify-db-instance --region us-east-1 \
  --db-instance-identifier summitcare-production \
  --backup-retention-period 35 --apply-immediately

aws rds start-db-instance-automated-backups-replication --region us-west-2 \
  --source-db-instance-arn arn:aws:rds:us-east-1:111122223333:db:summitcare-production \
  --kms-key-id arn:aws:kms:us-west-2:111122223333:alias/summitcare-backups \
  --backup-retention-period 14
