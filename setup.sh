#!/bin/bash

echo "Setup .env file..."

if [ -f ./backend/.env ]; then
  echo ".env file already exists. Checking for missing values..."

  declare -A env_vars=(
    ["POSTGRES_USER"]="PostgreSQL User"
    ["POSTGRES_PASSWORD"]="PostgreSQL Password"
    ["POSTGRES_DB"]="PostgreSQL Database Name"
    ["DATABASE_ADMIN_PASSWORD"]="Database Admin Password"
  )

  for var in "${!env_vars[@]}"; do
    if ! grep -q "^${var}=" ./backend/.env; then
      read -s -p "Enter value for ${env_vars[$var]} ($var): " value
      echo "${var}=${value}" >>./backend/.env
      echo "Added ${var} to .env file."
    fi
  done

  echo ".env file updated successfully."
else
  echo ".env file does not exist. Creating a new one..."

  read -s -p "Enter value for PostgreSQL User (POSTGRES_USER): " POSTGRES_USER
  echo
  read -s -p "Enter value for PostgreSQL Password (POSTGRES_PASSWORD): " POSTGRES_PASSWORD
  echo
  read -s -p "Enter value for PostgreSQL Database Name (POSTGRES_DB): " POSTGRES_DB
  echo
  read -s -p "Enter value for Database Admin Password (DATABASE_ADMIN_PASSWORD): " DATABASE_ADMIN_PASSWORD

  cat <<EOL >./backend/.env
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=$POSTGRES_DB
DATABASE_ADMIN_PASSWORD=$DATABASE_ADMIN_PASSWORD
EOL

  echo ".env file created successfully."
fi

source ./backend/.env

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  DOCKER_HOST="unix:///var/run/docker.sock"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
  DOCKER_HOST="npipe:////./pipe/docker_engine"
else
  echo "Unsupported OS type: $OSTYPE"
  exit 1
fi

export DOCKER_HOST

echo "Setup infrastructure..."

cd ./terraform && terraform init &&
  terraform plan \
    -var="POSTGRES_USER=$POSTGRES_USER" \
    -var="POSTGRES_PASSWORD=$POSTGRES_PASSWORD" \
    -var="POSTGRES_DB=$POSTGRES_DB" \
    -var="DATABASE_ADMIN_PASSWORD=$DATABASE_ADMIN_PASSWORD" \
    -var="DOCKER_HOST=$DOCKER_HOST" &&
  terraform apply -auto-approve \
    -var="POSTGRES_USER=$POSTGRES_USER" \
    -var="POSTGRES_PASSWORD=$POSTGRES_PASSWORD" \
    -var="POSTGRES_DB=$POSTGRES_DB" \
    -var="DATABASE_ADMIN_PASSWORD=$DATABASE_ADMIN_PASSWORD" \
    -var="DOCKER_HOST=$DOCKER_HOST"

echo "Setup finished."
