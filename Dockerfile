FROM bitwalker/alpine-elixir:1.6.6

COPY . .
COPY config/prod.exs.docker config/prod.exs

ENV MIX_ENV=prod

RUN rm -Rf _build && \
    mix deps.get && \
    mix compile

USER default

CMD mix run --no-halt