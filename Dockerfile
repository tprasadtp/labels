FROM python:3.8.1-alpine as base

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
FROM base as labels-core

ARG GITCOMMIT=""
ARG ACTIONS_WORKFLOW=""
ARG VERSION=""

LABEL labels.image.maintainer="Prasad Tengse<tprasadtp@noreply.labels.github.com>" \
      labels.image.repo.uri="https://github.com/tprasadtp/labels" \
      labels.image.build.git.sha="${GITCOMMIT}" \
      labels.image.build.workflow="${ACTIONS_WORKFLOW}" \
      labels.image.build.version="${VERSION}"

COPY --from=builder /install /usr/local

# Action Image. Used in GitHub Actions
FROM labels-core as action

# hadolint ignore=DL3018
RUN apk add --no-cache curl && rm -rf /var/cache/apk/*
COPY --from=builder /src/entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]


# DockerHub Image. Used to Run as User
FROM labels-core as hub

RUN addgroup -g 1000 labels \
    && adduser -G labels -u 1000 -D -h /home/labels labels \
    && mkdir -p /home/labels \
    && chown -R 1000:1000 /home/labels

WORKDIR /home/labels/
USER labels

ENTRYPOINT [ "labels"]
CMD [ "-v", "--help" ]
