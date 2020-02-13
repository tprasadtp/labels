FROM python:3.8.1-alpine

ARG GITCOMMIT=""
ARG ACTIONS_WORKFLOW=""
ARG VERSION=""

LABEL labels.image.maintainer="Prasad Tengse<tprasadtp@noreply.labels.github.com>" \
      labels.image.repo.uri="https://github.com/tprasadtp/labels" \
      labels.image.build.git.sha="${GITCOMMIT}" \
      labels.image.build.workflow="${ACTIONS_WORKFLOW}" \
      labels.image.build.version="${VERSION}"

# ADD Files
COPY . ./tmp
RUN apk add --update curl \
      && pip install \
      --upgrade --progress-bar=off -U \
      --no-cache-dir \
      ./tmp \
    && cp tmp/entrypoint.sh /bin/entrypoint.sh \
    && chmod +x /bin/entrypoint.sh \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*.* /tmp/*

ENTRYPOINT [ "/bin/entrypoint.sh" ]
