FROM python:3.8.0-alpine
LABEL maintainer="Prasad Tengse<code.tp@outlook.de>"
LABEL "com.github.actions.name"="Manage gitHub Issue Labels"
LABEL "com.github.actions.description"="Sync/Manage GitHub Issue labels"
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