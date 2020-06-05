FROM ruby:2.6.6-alpine3.10

RUN apk add --no-cache \
    git \
    build-base

ENV BUNDLE_SILENCE_ROOT_WARNING=1

WORKDIR /app
COPY . .
RUN bundle install -j4 -r3
