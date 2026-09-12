#!/bin/bash
cd "$(dirname "$0")"

# Source the .env file
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Start the backend
mvn spring-boot:run -Dspring-boot.run.profiles=h2 -DskipTests
