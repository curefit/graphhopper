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
| `LYRK_API_KEY` | `LYRK_API_KEY` | Lyrk tile-server API key for the production frontend bundle. |
| `OMNISCALE_API_KEY` | `OMNISCALE_API_KEY` | Omniscale tile-server API key for the production frontend bundle. |

## Alpha

| Env var | GCP Secret Manager key | Description |
|---|---|---|
| `NEW_RELIC_LICENSE_KEY` | `NEW_RELIC_LICENSE_KEY` | New Relic Java agent license key for the alpha deployment. |
| `LYRK_API_KEY` | `LYRK_API_KEY` | Lyrk tile-server API key for the alpha frontend bundle. |
| `OMNISCALE_API_KEY` | `OMNISCALE_API_KEY` | Omniscale tile-server API key for the alpha frontend bundle. |

## Stage

| Env var | GCP Secret Manager key | Description |
|---|---|---|
| `NEW_RELIC_LICENSE_KEY` | `NEW_RELIC_LICENSE_KEY` | New Relic Java agent license key for the stage deployment. |
| `LYRK_API_KEY` | `LYRK_API_KEY` | Lyrk tile-server API key for the stage frontend bundle. |
| `OMNISCALE_API_KEY` | `OMNISCALE_API_KEY` | Omniscale tile-server API key for the stage frontend bundle. |

## Build-time injection

`LYRK_API_KEY` and `OMNISCALE_API_KEY` are referenced via `process.env.*`
inside `web/src/main/resources/assets/js/config/options.js`. They are
**resolved at browserify-build time** by the new `envify` transform
(added to `web/package.json` browserify transforms). The deploy job
must therefore export these two env vars in the build environment
before running `npm run bundleProduction` (or the equivalent CI step).

The `New Relic` agent reads `${NEW_RELIC_LICENSE_KEY}` directly from
`newrelic/newrelic.yml` at JVM startup; the deploy job must set this
env var in the container's environment (or pass it via
`-Dnewrelic.environment=${NEW_RELIC_LICENSE_KEY}` to the JVM args).