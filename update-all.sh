git pull

for dir in */; do
  compose_file="$dir/compose.yaml"

  if [[ -f "$compose_file" ]]; then
    cd "$dir" || continue
    docker compose up --build -d --pull=always --remove-orphans --wait --wait-timeout 60 -y
    cd - > /dev/null
  fi
done

docker system prune -a --volumes -f
