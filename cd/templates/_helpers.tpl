{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{- define "name" -}}
{{- default .Values.appName .Values.nameOverride | trunc 63 | trimSuffix "-" | replace "_" "-" -}}
{{- end -}}

{{- define "serviceName" -}}
{{- default .Values.appName .Values.nameOverride | trunc 63 | trimSuffix "-" | replace "_" "-" -}}-internal
{{- end -}}

{{- define "canaryName" -}}
{{- default .Values.appName .Values.nameOverride | trunc 63 | trimSuffix "-" | replace "_" "-" -}}-canary
{{- end -}}

{{- define "baselineName" -}}
{{- default .Values.appName .Values.nameOverride | trunc 63 | trimSuffix "-" | replace "_" "-" -}}-baseline
{{- end -}}

{{- define "externalGateway" -}}
{{- default .Values.appName .Values.istio.external.gateway | trunc 63 | trimSuffix "-" | replace "_" "-" -}}
{{- end -}}


{{- define "internalGateway" -}}
{{- default .Values.appName .Values.istio.internal.gateway | trunc 63 | trimSuffix "-" | replace "_" "-" -}}
{{- end -}}


{{- define "vpnGateway" -}}
{{- default .Values.appName .Values.istio.vpn.gateway | trunc 63 | trimSuffix "-" | replace "_" "-" -}}
{{- end -}}


{{- define "customGateway" -}}
{{- default .Values.appName .Values.istio.custom.gateway | trunc 63 | trimSuffix "-" | replace "_" "-" -}}
{{- end -}}

{{- define "albGateway" -}}
{{- default .Values.appName .Values.istio.alb.gateway | trunc 63 | trimSuffix "-" | replace "_" "-" -}}
{{- end -}}

{{- define "secretName" -}}
{{- printf "%s/%s/k8s-%s" .Values.appEnv .Values.deployment.labels.billing (index .Values "deployment" "labels" "sub-billing") | trunc 63 | trimSuffix "-" | replace "_" "-" -}}
{{- end -}}

{{- define "migrationPrefix" -}}
{{- if eq .Values.migration "true" }}
{{- printf "migration-" -}}
{{- else -}}
{{- printf "" -}}
{{- end -}}
{{- end -}}


{{- define "tlsMode" -}}
{{- if .Values.istio.tls.enabled   }}
{{- printf "ISTIO_MUTUAL" -}}
{{- else -}}
{{- printf "DISABLE" -}}
{{- end -}}
{{- end -}}

{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | replace "_" "-"}}
{{- end -}}

{{- define "DD_ENV" -}}
{{ default "stage" .Values.appEnv }}
{{- end -}}

{{- define "outboundIPInterception" -}}
{{- if eq .Values.istio.allOutboundInterception true }}
{{- printf "*" | quote -}}
{{- else -}}
{{- printf "10.100.0.0/16" | quote -}}
{{- end -}}
{{- end -}}