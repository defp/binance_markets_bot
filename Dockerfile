FROM bitwalker/alpine-elixir:1.6.6

COPY . .
COPY config/prod.exs.docker config/prod.exs

RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix deps.get && \
    mix compile

CMD ["mix run --no-halt "]