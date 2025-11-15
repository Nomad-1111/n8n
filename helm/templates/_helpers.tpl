{{- define "n8n.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "n8n.fullname" -}}
{{- if .Release.Name }}
{{ .Release.Name }}
{{- else }}
{{ include "n8n.name" . }}
{{- end }}
{{- end }}

{{- define "n8n.labels" -}}
app.kubernetes.io/name: {{ include "n8n.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: n8n
{{- end }}
