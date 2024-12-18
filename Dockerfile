# Use Ruby 3.3.6 as the base image
FROM ruby:3.3.6-slim

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy gemfiles first to leverage Docker caching
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Set the default command
ENTRYPOINT ["ruby", "main.rb"]

# Default to running all receipts
CMD [] 