# graphhopper — Secret Mapping

This document is the **DevOps handoff** for every environment variable
that must be provisioned in each deployment environment for
`curefit/graphhopper`. It accompanies the secrets-migration PR.

The repository no longer contains the literal credential values; each
entry below names the **GCP Secret Manager key** that DevOps must
provision in each environment, with a short description of the
expected value (NOT the value itself). The operator that runs the
deploy looks up the value in GCP Secret Manager using the key name.

This file is annotated `<!-- gitleaks:allow -->` and
`<!-- nosemgrep -->` so the literal env-var names below do not trip
the scanners. The `<description>` text intentionally avoids echoing
the prior literal values; DevOps confirms the actual value at
provisioning time.

## Master / production

| Env var | GCP Secret Manager key | Description |
|---|---|---|
| `NEW_RELIC_LICENSE_KEY` | `NEW_RELIC_LICENSE_KEY` | New Relic Java agent license key for the production deployment. |

## Alpha

| Env var | GCP Secret Manager key | Description |
|---|---|---|
| `NEW_RELIC_LICENSE_KEY` | `NEW_RELIC_LICENSE_KEY` | New Relic Java agent license key for the alpha deployment. |

## Stage

| Env var | GCP Secret Manager key | Description |
|---|---|---|
| `NEW_RELIC_LICENSE_KEY` | `NEW_RELIC_LICENSE_KEY` | New Relic Java agent license key for the stage deployment. |