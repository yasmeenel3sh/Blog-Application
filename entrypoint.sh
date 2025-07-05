#!/bin/bash
set -e

#Delete leftover server PID file so Rails doesn't crash
rm -f /app/tmp/pids/server.pid

echo "RAILS_ENV=$RAILS_ENV"

#Run migrations
echo "Running db:prepare..."
bundle exec rails db:prepare

#Run seeds only if this is the web server
if [[ "$RAILS_ENV" == "development" ]] && ([[ "$*" == *"rails s"* ]] || [[ "$*" == *"rails server"* ]]); then
  echo "Running db:seed..."
  bundle exec rails db:seed
fi

#Run the original command (Rails or Sidekiq)
exec "$@"