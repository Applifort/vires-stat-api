FROM ruby:2.7-alpine3.15

ARG APP_ROOT=/app

ARG PACKAGES="vim build-base git bash"

RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $PACKAGES

RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

COPY Gemfile Gemfile.lock  ./
RUN bundle install --jobs 5

ADD . $APP_ROOT
ENV PATH=$APP_ROOT/bin:${PATH}

EXPOSE 3000

CMD [""]
