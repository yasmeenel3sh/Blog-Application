#!/bin/bash
set -e

#Delete leftover server PID file so Rails doesn't crash
rm -f /app/tmp/pids/server.pid

echo "RAILS_ENV=$RAILS_ENV"

#Run migrations
echo "Running db:prepare..."
bundle exec rails db:prepare

#Run the original command
exec "$@"