#!/bin/bash
cd $(dirname "$0")
echo "Updating monitoring stack..."
docker compose pull
docker compose down
docker compose up -d