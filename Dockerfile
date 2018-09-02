FROM ruby:2.5

RUN mkdir /api
WORKDIR /api

COPY Gemfile* /api/

RUN bundle install

COPY . /api
