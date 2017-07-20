FROM ruby:2.3.0
MAINTAINER Zdenko Nevrala <nevralaz@gmail.com>

RUN apt-get update && apt-get -y install sudo netcat

# Add Gemfile
COPY .ruby-version /challenge-calcs/.ruby-version
COPY Gemfile /challenge-calcs/Gemfile
COPY Gemfile.lock /challenge-calcs/Gemfile.lock
COPY wait-for /challenge-calcs/wait-for

WORKDIR /challenge-calcs/

# install dependencies
RUN bundle install

ADD ./ /challenge-calcs/
