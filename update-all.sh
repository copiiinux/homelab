#!/bin/bash

FAILED_STACKS=()

echo "Pulling latest changes from git..."
git pull || { echo "git pull failed, aborting"; exit 1; }

for dir in */; do
  compose_file="$dir/compose.yaml"

  if [[ ! -f "$compose_file" ]]; then
    continue
  fi

  echo "Updating stack: $dir"
  cd "$dir" || continue

  if docker compose up -d --pull=always --remove-orphans --wait; then
    echo "  ✓ $dir updated successfully"
  else
    echo "  ✗ $dir failed to update — skipping"
    FAILED_STACKS+=("$dir")
  fi

  cd - > /dev/null
done

echo ""
echo "Cleaning up unused Docker resources..."
docker system prune -a -f --volumes

echo ""
if [[ ${#FAILED_STACKS[@]} -eq 0 ]]; then
  echo "All stacks updated successfully."
else
  echo "Update complete with errors. Failed stacks:"
  for s in "${FAILED_STACKS[@]}"; do
    echo "  - $s"
  done
  exit 1
fi
