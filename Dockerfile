FROM ruby:2.5
MAINTAINER Eric Musgrove <eric.musgrove@hexawise.com>

RUN apt-get update && \
    apt-get install -y net-tools

# Install gems
ENV APP_HOME /app
ENV HOME /root
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Upload source
COPY . $APP_HOME

# Run bundle install
RUN bundle install

# Set port
ENV PORT 3000
EXPOSE 3000

# Start the app
CMD ["ruby", "app.rb"]