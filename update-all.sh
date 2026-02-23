#!/bin/bash
set -e

# Update from git
echo "Pulling latest changes from git..."
git pull

# Update all services
for dir in */; do
  compose_file="$dir/compose.yaml"

  if [[ -f "$compose_file" ]]; then
    echo "Updating service: $dir"
    cd "$dir" || continue
    docker compose up --build -d --pull=always --remove-orphans --wait --wait-timeout 60 -y
    cd - > /dev/null
  fi
done

echo "All services updated successfully."

# Cleanup unused images and containers (but NOT volumes)
echo "Cleaning up unused Docker resources..."
docker system prune -a -f

echo "Update complete!"

