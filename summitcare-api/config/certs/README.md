Place the Amazon RDS global certificate bundle here as `rds-global-bundle.pem`
(download it from AWS: https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem).
`config/database.yml` uses it with `sslmode: verify-full` in production (Solution 10).
