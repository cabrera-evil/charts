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
