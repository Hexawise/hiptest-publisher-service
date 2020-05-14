FROM ruby:2.5
MAINTAINER Eric Musgrove <eric.musgrove@hexawise.com>

RUN apt-get update && \
    apt-get install -y net-tools

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN mkdir -p ~/.ssh
RUN ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

# Upload source
COPY . $APP_HOME

# Run bundle install
RUN bundle install --path vendor/bundle

# Start the app
CMD ["ruby", "app/server.rb"]