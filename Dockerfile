FROM python:3.8.5-alpine as base

# Builder Stage
FROM base as builder

COPY . ./src
# hadolint ignore=DL3018
RUN apk add --no-cache curl libffi-dev openssl-dev python3-dev gcc musl-dev
RUN pip install \
      --upgrade --progress-bar=off -U \
      --no-cache-dir \
      --prefix=/install \
      ./src
RUN chmod +x src/entrypoint.sh

# Base Labels Image
FROM base as release

# hadolint ignore=DL3018
RUN apk add --no-cache curl

COPY --from=builder /install /usr/local
COPY --from=builder /src/entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "labels"]
CMD [ "-v", "--help" ]
