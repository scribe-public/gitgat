FROM alpine

ARG OPA_VERSION="v0.41.0"

WORKDIR /opt/opa

COPY bin/docker-entrypoint.sh /opt/opa/docker-entrypoint.sh
COPY data/empty-input.json /var/opt/opa/input.json
COPY license-artifacts /opt/opa

RUN apk --no-cache add curl &&\
    adduser -D opa &&\
    curl -L -o opa https://openpolicyagent.org/downloads/${OPA_VERSION}/opa_linux_amd64_static &&\
    chmod u+x /opt/opa/opa &&\
    chmod u+x /opt/opa/docker-entrypoint.sh &&\
    chown -R opa:opa /opt/opa &&\
    chown -R opa:opa /var/opt/opa

COPY github /opt/opa/github

USER opa

ENTRYPOINT ["/opt/opa/docker-entrypoint.sh"]
CMD ["data.gh.eval"]
