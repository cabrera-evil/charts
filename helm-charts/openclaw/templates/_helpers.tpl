{{/*
Expand the name of the chart.
*/}}
{{- define "openclaw.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "openclaw.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "openclaw.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "openclaw.labels" -}}
helm.sh/chart: {{ include "openclaw.chart" . }}
{{ include "openclaw.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "openclaw.selectorLabels" -}}
app.kubernetes.io/name: {{ include "openclaw.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "openclaw.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "openclaw.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper image name
*/}}
{{- define "openclaw.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

{{/*
Return the proper container name
*/}}
{{- define "openclaw.containerName" -}}
{{- default .Chart.Name .Values.containerName | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Generate checksum annotations for the deployment pod template.
Changes to the ConfigMap or Secret trigger a rolling update.
*/}}
{{- define "openclaw.checksumAnnotations" -}}
checksum/config: {{ merge (dict "gateway" .Values.gateway "agentsConfig" .Values.agentsConfig) .Values.extraGatewayConfig | toJson | sha256sum }}
{{- if .Values.secret.enabled }}
checksum/secret: {{ .Values.secret | toJson | sha256sum }}
{{- end }}
{{- end }}

{{/*
Validate pod disruption budget configuration
*/}}
{{- define "openclaw.validatePDB" -}}
{{- if .Values.podDisruptionBudget.enabled }}
{{- if and .Values.podDisruptionBudget.minAvailable .Values.podDisruptionBudget.maxUnavailable }}
{{- fail "Cannot set both minAvailable and maxUnavailable in podDisruptionBudget" }}
{{- end }}
{{- if and (not .Values.podDisruptionBudget.minAvailable) (not .Values.podDisruptionBudget.maxUnavailable) }}
{{- fail "Must set either minAvailable or maxUnavailable in podDisruptionBudget" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Validate that ingress is not enabled with loopback bind.
The loopback bind is not reachable by Kubernetes services or ingress controllers.
*/}}
{{- define "openclaw.validateIngressBind" -}}
{{- if and .Values.ingress.enabled (eq .Values.gateway.bind "loopback") }}
{{- fail "ingress.enabled=true requires gateway.bind=\"0.0.0.0\". The default loopback bind is not reachable by Kubernetes services or ingress controllers." }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for HPA
*/}}
{{- define "openclaw.hpa.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "autoscaling/v2" }}
{{- print "autoscaling/v2" }}
{{- else }}
{{- print "autoscaling/v2beta2" }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for PodDisruptionBudget
*/}}
{{- define "openclaw.pdb.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1/PodDisruptionBudget" }}
{{- print "policy/v1" }}
{{- else }}
{{- print "policy/v1beta1" }}
{{- end }}
{{- end }}

{{/*
Generate common pod spec fields (scheduling, DNS, etc.)
*/}}
{{- define "openclaw.podSpec" -}}
{{- with .Values.priorityClassName }}
priorityClassName: {{ . }}
{{- end }}
{{- with .Values.runtimeClassName }}
runtimeClassName: {{ . }}
{{- end }}
{{- with .Values.schedulerName }}
schedulerName: {{ . }}
{{- end }}
{{- with .Values.dnsPolicy }}
dnsPolicy: {{ . }}
{{- end }}
{{- with .Values.dnsConfig }}
dnsConfig:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.hostAliases }}
hostAliases:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.terminationGracePeriodSeconds }}
terminationGracePeriodSeconds: {{ . }}
{{- end }}
{{- end }}
