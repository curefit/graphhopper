# GraphHopper Secret Mapping

Secret values are provisioned by the deployment or build environment and are intentionally not committed to this repository.

## PRODUCTION

| Environment variable | Purpose |
|---|---|
| NEW_RELIC_LICENSE_KEY | New Relic agent license |
| CUREFIT_API_GRAPHHOPPER_KEY | GraphHopper integration-test API key |
| CUREFIT_API_LYRK_KEY | Lyrk tile-provider API key for the web bundle |
| CUREFIT_API_OMNISCALE_KEY | Omniscale tile-provider API key for the web bundle |

## ALPHA

| Environment variable | Purpose |
|---|---|
| NEW_RELIC_LICENSE_KEY | New Relic agent license |
| CUREFIT_API_GRAPHHOPPER_KEY | GraphHopper integration-test API key |
| CUREFIT_API_LYRK_KEY | Lyrk tile-provider API key for the web bundle |
| CUREFIT_API_OMNISCALE_KEY | Omniscale tile-provider API key for the web bundle |

## STAGE

| Environment variable | Purpose |
|---|---|
| NEW_RELIC_LICENSE_KEY | New Relic agent license |
| CUREFIT_API_GRAPHHOPPER_KEY | GraphHopper integration-test API key |
| CUREFIT_API_LYRK_KEY | Lyrk tile-provider API key for the web bundle |
| CUREFIT_API_OMNISCALE_KEY | Omniscale tile-provider API key for the web bundle |

## Wiring

- `newrelic/newrelic.yml` reads `NEW_RELIC_LICENSE_KEY` at runtime.
- `client-hc/src/test/java/com/graphhopper/api/GraphHopperWebIT.java` reads `CUREFIT_API_GRAPHHOPPER_KEY`.
- `web/src/main/resources/assets/js/config/options.js` reads the tile-provider variables during the Browserify build.
- The web UI falls back to OpenStreetMap when `CUREFIT_API_OMNISCALE_KEY` is not supplied.
