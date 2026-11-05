#!/bin/bash
# Redeploys the previous image tag (runs on the EC2 host, in /opt/app)
set -euo pipefail
cd /opt/app
if [ ! -f .previous_tag ]; then
  echo "No previous tag recorded, nothing to roll back to"
  exit 1
fi
PREV=$(cat .previous_tag)
echo "Rolling back to $PREV"
./deploy.sh "$PREV"
