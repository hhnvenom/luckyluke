#!/bin/bash

# Make this script executable with: chmod +x dev.sh

# Function to check if Docker is running
check_docker() {
  if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Please start Docker and try again."
    exit 1
  fi
}

# Function to build and start containers
start_services() {
  echo "Building and starting services..."
  docker-compose up -d --build
  echo "Services started!"
  echo "- Frontend: http://localhost:3000"
  echo "- API: http://localhost:8080"
  echo "- Database: localhost:5432"
}

# Function to stop containers
stop_services() {
  echo "Stopping services..."
  docker-compose down
  echo "Services stopped."
}

# Function to show logs
show_logs() {
  service=$1
  if [ -z "$service" ]; then
    docker-compose logs -f
  else
    docker-compose logs -f "$service"
  fi
}

# Function to run database migrations manually
run_migrations() {
  echo "Running database migrations..."
  docker-compose exec db psql -U postgres -d lottery -f /docker-entrypoint-initdb.d/init.sql
  echo "Migrations completed."
}

# Function to open a PostgreSQL shell
db_shell() {
  echo "Opening PostgreSQL shell..."
  docker-compose exec db psql -U postgres -d lottery
}

# Help message
show_help() {
  echo "Lottery App Development Helper"
  echo ""
  echo "Usage: ./dev.sh [command]"
  echo ""
  echo "Commands:"
  echo "  start       Build and start all services"
  echo "  stop        Stop all services"
  echo "  restart     Restart all services"
  echo "  logs        Show logs from all services"
  echo "  logs:api    Show logs from API service"
  echo "  logs:front  Show logs from Frontend service"
  echo "  logs:db     Show logs from Database service"
  echo "  migrate     Run database migrations"
  echo "  db:shell    Open PostgreSQL shell"
  echo "  help        Show this help message"
}

# Main logic
check_docker

case "$1" in
  start)
    start_services
    ;;
  stop)
    stop_services
    ;;
  restart)
    stop_services
    start_services
    ;;
  logs)
    show_logs
    ;;
  logs:api)
    show_logs api
    ;;
  logs:front)
    show_logs frontend
    ;;
  logs:db)
    show_logs db
    ;;
  migrate)
    run_migrations
    ;;
  db:shell)
    db_shell
    ;;
  help|*)
    show_help
    ;;
esac
