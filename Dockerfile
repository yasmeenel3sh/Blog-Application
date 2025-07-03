FROM ruby:3.4.4-slim-bookworm

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      libpq-dev \
      postgresql-client \
      nodejs \
      yarn \
      git \
      curl \
      libyaml-dev \
      tzdata && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle lock --add-platform x86_64-linux && \
    bundle lock --add-platform aarch64-linux

RUN bundle install

COPY . .

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
