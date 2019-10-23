FROM python:3.7.5-alpine3.10
LABEL "maintainer"="Prasad Tengse<code.tp@outlook.de>"

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