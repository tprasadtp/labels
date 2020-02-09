FROM python:3.7.5-alpine3.11
LABEL maintainer="Prasad Tengse<tprasadtp@noreply.user.github.com>"
LABEL "com.github.actions.description"="Sync/Manage GitHub issue labels defined in .github/labels.toml"
LABEL "com.github.actions.name"="Issue Labels"
LABEL "com.github.actions.icon"="tag"
LABEL "com.github.actions.color"="blue"

# ADD Files
COPY . ./labels/
RUN pip install \
        --upgrade --progress-bar=off -U \
        --no-cache-dir \
        ./labels \
    && mv labels/entrypoint.sh /bin/entrypoint.sh \
    && chmod +x /bin/entrypoint.sh \
    && rm -rf labels/ \
    && rm -rf /tmp/*.* /tmp/**/*.* /tmp/**/*

ENTRYPOINT [ "/bin/entrypoint.sh" ]
