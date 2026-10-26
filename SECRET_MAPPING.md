# GraphHopper secret migration

This migration removes the six Gitleaks matches on `master`: the New Relic
license, the GraphHopper test key in Java and Travis, the Lyrk tile key in source
and the shipped bundle, and the unused Mapbox example token. Unreported
credentials and integrations are outside this change.

## Runtime: New Relic

Ensure the environment's GCP Secret Manager JSON secret contains
`NEW_RELIC_LICENSE_KEY` before deployment. The values files enable External
Secrets and name the JSON secrets using the convention in
[cult-web-api-proxy](https://github.com/curefit/cult-web-api-proxy/pull/697).

| Environment | GCP Secret Manager secret | JSON field / pod environment variable |
| --- | --- | --- |
| alpha | `alpha_eat_k8s-graphhopper` | `NEW_RELIC_LICENSE_KEY` |
| stage | `stage_eat_k8s-graphhopper` | `NEW_RELIC_LICENSE_KEY` |
| prod | `prod_cult_k8s-graphhopper` | `NEW_RELIC_LICENSE_KEY` |

The names follow this repository's existing `billing` and `sub-billing` labels.
Create the secret if absent; otherwise add the field while preserving existing
fields. These names refer to JSON secret bundles, not standalone secrets named
after the environment variable. Their existence, IAM access, and live External
Secrets sync have not been verified from this workstation.

The bundled New Relic agent (3.40.0) reads `NEW_RELIC_LICENSE_KEY` directly;
`newrelic.yml` has an empty license setting. No YAML placeholder interpolation,
agent upgrade, or startup-script substitution is needed. Both the foreground
container launch and background launch attach `newrelic.jar` and select the
requested New Relic environment. Before rollout, confirm External Secrets sync
succeeds and the pod receives a nonempty variable. After rollout, confirm the
running JVM has the agent attached and New Relic reporting continues.

## CI: GraphHopper integration tests

Set `GRAPHHOPPER_API_KEY` in the CI secret settings for builds running the live
GraphHopper integration tests. Travis also accepts its existing `API_KEY`
variable and exports it under the new name. Local tests support the same
environment variable and retain the existing `-Dkey=...` override.

This key is for vendor integration tests; it does not belong in the application
pod's runtime secret bundle. Builds without a key still run unit tests; only the
GraphHopper vendor integration tests are skipped, with a message naming the
required environment variable and system-property overrides. Empty or
whitespace-only keys are also treated as unconfigured. A configured key enables
these tests automatically. Live vendor calls require a valid provisioned key
and were not run as part of this migration.

## Optional browser tile provider: Lyrk

The UI now reads `lyrk.api_key` from its existing options configuration, matching
`thunderforest.api_key` and `omniscale.api_key`. Lyrk is offered only when a key
is configured; the existing default Omniscale layer is unchanged.

To enable Lyrk, configure a browser-safe, restricted tile key in the ignored
`web/src/main/resources/assets/js/config/options_prod.js` override and build
using the existing `BROWSERIFYSWAP_ENV=production npm run bundleProduction`
command from `web/`. The committed source and bundle leave this field empty.
The key becomes visible to browsers, so never put a private server credential
there. A pod environment variable or a new GCP runtime entry will not configure
this static browser bundle.

The Mapbox match was in a commented example; it now uses an example placeholder
and needs no GCP entry. No scanner exclusions were added.

## Credential rotation

Rotate the previously committed New Relic, GraphHopper, and Lyrk credentials
through their owners and provision replacements in the appropriate locations
above. Obtain the old values from the existing credential vault or the base
revision when needed; this document deliberately contains no credential values.
The code migration does not erase Git history or perform credential rotation.
