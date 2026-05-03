{{/*
Expand the name of the chart.
*/}}
{{- define "stardew-valley-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "stardew-valley-server.fullname" -}}
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
{{- define "stardew-valley-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "stardew-valley-server.labels" -}}
helm.sh/chart: {{ include "stardew-valley-server.chart" . }}
{{ include "stardew-valley-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: game-server
{{- end }}

{{/*
Selector labels
*/}}
{{- define "stardew-valley-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "stardew-valley-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "stardew-valley-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "stardew-valley-server.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper image name
Usage: include "stardew-valley-server.image" .
*/}}
{{- define "stardew-valley-server.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

{{/*
Generate checksum annotations for deployment pods to trigger rolling updates on secret changes
Usage: include "stardew-valley-server.checksumAnnotations" .
*/}}
{{- define "stardew-valley-server.checksumAnnotations" -}}
checksum/secret: {{ .Values.gameServer | toJson | sha256sum }}
{{- end }}

{{/*
Validate required values
*/}}
{{- define "stardew-valley-server.validateValues" -}}
{{- if not .Values.gameServer.steamCredentials.username }}
{{- fail "gameServer.steamCredentials.username is required. Please provide a Steam username." }}
{{- end }}
{{- if not .Values.gameServer.steamCredentials.password }}
{{- fail "gameServer.steamCredentials.password is required. Please provide a Steam password." }}
{{- end }}
{{- end }}
