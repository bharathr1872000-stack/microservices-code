#!/bin/bash
# Usage: ./deploy.sh <image-tag>   (runs on the EC2 host, in /opt/app)
set -euo pipefail
cd /opt/app
NEWTAG="${1:?usage: deploy.sh <tag>}"
REGION="us-east-1"

# keep the last good tag for rollback
if [ -f .current_tag ] && [ "$(cat .current_tag)" != "$NEWTAG" ]; then
  cp .current_tag .previous_tag
fi

ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
export ECR="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com"
export TAG="$NEWTAG"
printf 'ECR=%s\nTAG=%s\n' "$ECR" "$TAG" > .env

aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ECR"

# compose file has build: entries; empty dirs keep it happy, images come from ECR
mkdir -p user-service product-service order-service

docker compose pull
docker compose up -d --no-build --remove-orphans
echo "$NEWTAG" > .current_tag
docker compose ps
