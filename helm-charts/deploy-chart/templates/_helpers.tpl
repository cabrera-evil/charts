{{/*
Expand the name of the chart.
*/}}
{{- define "deploy-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "deploy-chart.fullname" -}}
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
{{- define "deploy-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "deploy-chart.labels" -}}
helm.sh/chart: {{ include "deploy-chart.chart" . }}
{{ include "deploy-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "deploy-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "deploy-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "deploy-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "deploy-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate checksum annotations for job pods to trigger restarts on config changes
*/}}
{{- define "deploy-chart.jobChecksumAnnotations" -}}
{{- if .Values.configMap.enabled }}
checksum/config: {{ .Values.configMap.data | toJson | sha256sum }}
{{- end }}
{{- if .Values.secret.enabled }}
checksum/secret: {{ .Values.secret.data | toJson | sha256sum }}
{{- end }}
{{- end }}

{{/*
Merge labels from multiple sources for jobs
Usage: include "deploy-chart.jobLabels" (dict "root" $ "job" $job "jobsDefaults" $jobsDefaults)
*/}}
{{- define "deploy-chart.jobLabels" -}}
{{- $labels := dict }}
{{- range $src := (list .jobsDefaults.labels .job.labels) }}
{{- if $src }}
{{- range $key, $val := $src }}
{{- $_ := set $labels $key $val }}
{{- end }}
{{- end }}
{{- end }}
{{- toYaml $labels }}
{{- end }}

{{/*
Merge annotations from multiple sources for jobs
Usage: include "deploy-chart.jobAnnotations" (dict "root" $ "job" $job "jobsDefaults" $jobsDefaults)
*/}}
{{- define "deploy-chart.jobAnnotations" -}}
{{- $annotations := dict }}
{{- range $src := (list .jobsDefaults.annotations .job.annotations) }}
{{- if $src }}
{{- range $key, $val := $src }}
{{- $_ := set $annotations $key $val }}
{{- end }}
{{- end }}
{{- end }}
{{- toYaml $annotations }}
{{- end }}

{{/*
Merge pod labels from multiple sources for jobs
Usage: include "deploy-chart.jobPodLabels" (dict "root" $ "job" $job "jobsDefaults" $jobsDefaults)
*/}}
{{- define "deploy-chart.jobPodLabels" -}}
{{- $labels := dict }}
{{- range $src := (list .root.Values.podLabels .jobsDefaults.podLabels .job.podLabels) }}
{{- if $src }}
{{- range $key, $val := $src }}
{{- $_ := set $labels $key $val }}
{{- end }}
{{- end }}
{{- end }}
{{- toYaml $labels }}
{{- end }}

{{/*
Merge pod annotations from multiple sources for jobs
Usage: include "deploy-chart.jobPodAnnotations" (dict "root" $ "job" $job "jobsDefaults" $jobsDefaults)
*/}}
{{- define "deploy-chart.jobPodAnnotations" -}}
{{- $annotations := dict }}
{{- range $src := (list .root.Values.podAnnotations .jobsDefaults.podAnnotations .job.podAnnotations) }}
{{- if $src }}
{{- range $key, $val := $src }}
{{- $_ := set $annotations $key $val }}
{{- end }}
{{- end }}
{{- end }}
{{- toYaml $annotations }}
{{- end }}

{{/*
Return the proper image name
Usage: include "deploy-chart.image" .
*/}}
{{- define "deploy-chart.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

{{/*
Return the proper container name
Usage: include "deploy-chart.containerName" .
*/}}
{{- define "deploy-chart.containerName" -}}
{{- default .Chart.Name .Values.containerName | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Generate checksum annotations for deployment pods
Usage: include "deploy-chart.checksumAnnotations" .
*/}}
{{- define "deploy-chart.checksumAnnotations" -}}
{{- if .Values.configMap.enabled }}
checksum/config: {{ .Values.configMap.data | toJson | sha256sum }}
{{- end }}
{{- if .Values.secret.enabled }}
checksum/secret: {{ .Values.secret.data | toJson | sha256sum }}
{{- end }}
{{- end }}

{{/*
Validate pod disruption budget configuration
*/}}
{{- define "deploy-chart.validatePDB" -}}
{{- if and .Values.podDisruptionBudget.enabled }}
{{- if and .Values.podDisruptionBudget.minAvailable .Values.podDisruptionBudget.maxUnavailable }}
{{- fail "Cannot set both minAvailable and maxUnavailable in podDisruptionBudget" }}
{{- end }}
{{- if and (not .Values.podDisruptionBudget.minAvailable) (not .Values.podDisruptionBudget.maxUnavailable) }}
{{- fail "Must set either minAvailable or maxUnavailable in podDisruptionBudget" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for HPA
*/}}
{{- define "deploy-chart.hpa.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "autoscaling/v2" }}
{{- print "autoscaling/v2" }}
{{- else }}
{{- print "autoscaling/v2beta2" }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for PodDisruptionBudget
*/}}
{{- define "deploy-chart.pdb.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1/PodDisruptionBudget" }}
{{- print "policy/v1" }}
{{- else }}
{{- print "policy/v1beta1" }}
{{- end }}
{{- end }}

{{/*
Generate common pod spec fields
Usage: include "deploy-chart.podSpec" .
*/}}
{{- define "deploy-chart.podSpec" -}}
{{- with .Values.priorityClassName }}
priorityClassName: {{ . }}
{{- end }}
{{- with .Values.runtimeClassName }}
runtimeClassName: {{ . }}
{{- end }}
{{- with .Values.schedulerName }}
schedulerName: {{ . }}
{{- end }}
{{- if kindIs "bool" .Values.shareProcessNamespace }}
shareProcessNamespace: {{ .Values.shareProcessNamespace }}
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
