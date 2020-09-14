#!/bin/sh

set -e

# Add `java -jar wiremock-jre8-standalone.jar` as command if needed
if [ "${1#-}" != "$1" ]; then
    set -- java ${JAVA_OPTS} -cp /var/wiremock/lib/*:/var/wiremock/extensions/* com.github.tomakehurst.wiremock.standalone.WireMockServerRunner ${WIREMOCK_OPTS} "${@}"
fi

exec "$@"
