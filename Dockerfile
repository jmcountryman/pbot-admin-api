FROM ruby:2.5

WORKDIR /api
ENV RAILS_LOG_TO_STDOUT=true

COPY Gemfile* ./
RUN bundle install

COPY . .

CMD ["/bin/bash", "entrypoint.sh"]
