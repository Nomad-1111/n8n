# Use official n8n image
FROM n8nio/n8n:latest

# Do NOT override entrypoint
# Do NOT copy any entrypoint
# The base image already correctly starts n8n

# (Optional) install extra packages here if needed
# RUN apk add --no-cache ...

# Ensure working directory exists
WORKDIR /data

# n8n Base image already:
# ✔ sets correct entrypoint
# ✔ exposes port 5678
# ✔ runs 'n8n start'
