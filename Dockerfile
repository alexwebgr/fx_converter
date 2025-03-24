# Use official Ruby image with minimal dependencies
FROM ruby:3.4.2-alpine3.21

# Set working directory
WORKDIR /

# Copy dependencies first for layer caching
COPY Gemfile* ./

RUN apk add --update ruby-dev build-base
RUN bundle install

# Copy application code
COPY . .

# Run command when container starts
CMD ["ruby", "app/main.rb"]
