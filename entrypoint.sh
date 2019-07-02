sleep 10 # wait for mongo and pg to come up
rm -rf tmp/
bundle exec rails db:create db:migrate
bundle exec rails s -b '0.0.0.0'
