# GraphHopper Secret Mapping

This document maps the New Relic license key used by GraphHopper to the environment variables DevOps must provision. It contains no secret values.

## PRODUCTION

| GCP secret key | Expected value |
|---|---|
| NEW_RELIC_LICENSE_KEY | New Relic license key used by the production deployment |

## ALPHA

| GCP secret key | Expected value |
|---|---|
| NEW_RELIC_LICENSE_KEY | New Relic license key used by the alpha deployment |

## STAGE

| GCP secret key | Expected value |
|---|---|
| NEW_RELIC_LICENSE_KEY | New Relic license key used by the stage deployment |

## Runtime wiring reference

| GCP secret key | Configuration path(s) |
|---|---|
| NEW_RELIC_LICENSE_KEY | `newrelic/newrelic.yml` -> `common.license_key` |
