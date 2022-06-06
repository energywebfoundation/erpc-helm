{{/*
Expand the name of the chart.
*/}}
{{- define "erpc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "erpc.fullname" -}}
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
{{- define "erpc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "erpc.labels" -}}
helm.sh/chart: {{ include "erpc.chart" . }}
{{ include "erpc.selectorLabels" . }}
{{ include "erpc.serviceLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
chain: {{ .Values.node.chain }}
mode: {{ include "chain.syncMode" . }} 
{{- end }}

{{/*
Selector labels
*/}}
{{- define "erpc.selectorLabels" -}}
app.kubernetes.io/name: {{ include "erpc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service labels
*/}}
{{- define "erpc.serviceLabels" -}}
chain: {{ .Values.node.chain | quote }}
release: {{ .Release.Name | quote }}
mode: {{ include "chain.syncMode" . | quote }}
{{- with .Values.extraLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "erpc.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "erpc.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate pseudo random value based on EBS snapshot ID
*/}}
{{- define "erpc.uuid" -}}
{{- trimPrefix "snap-" .Values.node.volume.snapshot -}}
{{- end }}

{{/*
Create ConfigMap name to store Volimesnapshot related names
*/}}
{{- define "erpc.volumeSnapshotConfigMapName" -}}
{{ printf "%s-snapshot-config" (include "erpc.fullname" .) }}
{{- end }}

{{/*
Create VolumeSnapshotClass name
*/}}
{{- define "erpc.volumeSnapshotClassName" -}}
{{- printf "%s-vs-class-%s" (include "erpc.fullname" .) (include "erpc.uuid" .) | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create VolumeSnapshot name
*/}}
{{- define "erpc.volumeSnapshotName" -}}
{{- printf "%s-vs-%s" (include "erpc.fullname" .) (include "erpc.uuid" .) | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create VolumeSnapshotContent name
*/}}
{{- define "erpc.volumeSnapshotContentName" -}}
{{- printf "%s-vs-content-%s" (include "erpc.fullname" .) (include "erpc.uuid" .) | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chain config name
*/}}
{{- define "chain.configName" -}}
{{- printf "%s.cfg" .Values.node.chain }}
{{- end }}

{{/*
Create chain spec name
*/}}
{{- define "chain.specName" -}}
{{- printf "%s.json" .Values.node.chain }}
{{- end }}

{{/*
Chain sync mode
*/}}
{{- define "chain.syncMode" -}}
{{- if .Values.node.fastSync }}
{{- default "Fast" }}
{{- else }}
{{- default "Archive" }}
{{- end }}
{{- end }}

{{/*
Create chain node name
*/}}
{{- define "chain.nodeName" -}}
{{- printf "%s %s ERPC" .Values.node.chain (include "chain.syncMode" .) | title | quote }}
{{- end }}
