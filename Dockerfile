FROM ruby:2.5

WORKDIR /api

COPY Gemfile* ./
RUN bundle install

COPY . .
