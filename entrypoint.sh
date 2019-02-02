sleep 20 # wait for mongo and pg to come up
bundle exec rails db:create db:migrate
bundle exec rails s -b '0.0.0.0'
