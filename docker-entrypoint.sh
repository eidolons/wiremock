#!/bin/sh

set -e

# Add `java -jar wiremock-jre8-standalone.jar` as command if needed
if [ "${1}" = "" ]; then
    WIREMOCK_OPTS="--root-dir \"${WIREMOCK_HOME}/data\""
    # Check whether to enable HTTPS or use HTTP.
    if [ "${WIREMOCK_SECURED}" = "true" ]; then
        WIREMOCK_OPTS="${WIREMOCK_OPTS} --disable-http --https-port 8443"

        # Check the certificate authority keystore configuration.
        if [ ! "${WIREMOCK_CASTORE}" = "" ] && [ -f "${WIREMOCK_HOME}/${WIREMOCK_CASTORE}" ]; then
            WIREMOCK_OPTS="${WIREMOCK_OPTS} --ca-keystore \"${WIREMOCK_HOME}/${WIREMOCK_CASTORE}\""
            if [ ! "${WIREMOCK_TRUSTSTORE_PASSWORD}" = "" ]; then
                WIREMOCK_OPTS="${WIREMOCK_OPTS} --ca-keystore-type pkcs12 --ca-keystore-password \"${WIREMOCK_CASTORE_PASSWORD}\""
            fi
        fi
        # Check the keystore configuration.
        if [ ! "${WIREMOCK_KEYSTORE}" = "" ] && [ -f "${WIREMOCK_HOME}/${WIREMOCK_KEYSTORE}" ]; then
            WIREMOCK_OPTS="${WIREMOCK_OPTS} --https-keystore \"${WIREMOCK_HOME}/${WIREMOCK_KEYSTORE}\""
            if [ ! "${WIREMOCK_KEYSTORE_PASSWORD}" = "" ]; then
                WIREMOCK_OPTS="${WIREMOCK_OPTS} --keystore-type pkcs12 --keystore-password \"${WIREMOCK_KEYSTORE_PASSWORD}\" --key-manager-pasword \"${WIREMOCK_KEYSTORE_PASSWORD}\""
            fi
        fi
        # Check the truststore configuration.
        if [ ! "${WIREMOCK_TRUSTSTORE}" = "" ] && [ -f "${WIREMOCK_HOME}/${WIREMOCK_TRUSTSTORE}" ]; then
            WIREMOCK_OPTS="${WIREMOCK_OPTS} --disable-http --https-port 8443 --https-truststore \"${WIREMOCK_HOME}/${WIREMOCK_TRUSTSTORE}\""
            if [ ! "${WIREMOCK_TRUSTSTORE_PASSWORD}" = "" ]; then
                WIREMOCK_OPTS="${WIREMOCK_OPTS} --truststore-type pkcs12 --truststore-password \"${WIREMOCK_TRUSTSTORE_PASSWORD}\""
            fi
        fi
    else
        WIREMOCK_OPTS="${WIREMOCK_OPTS} --port 8080"
    fi
    # Check whether to record mappings or to disable request journal to enable performance or even to enable as browser proxying.
    if [ "${WIREMOCK_RECORD_MAPPINGS}" = "true" ]; then
        WIREMOCK_OPTS="${WIREMOCK_OPTS} --record-mappings"
    elif [ "${WIREMOCK_REQUEST_JOURNAL}" != "true" ]; then
        WIREMOCK_OPTS="${WIREMOCK_OPTS} --no-request-journal"
    fi
    # Check proxy request configuration.
    if [ "${WIREMOCK_BROWSER_PROXING}" = "true" ]; then
        WIREMOCK_OPTS="${WIREMOCK_OPTS} --enable-browser-proxying --proxy-all --preserve-host-header"
    fi
    # Check if you want to enable verbose logging.
    if [ "${WIREMOCK_VERBOSE}" = "true" ]; then
        WIREMOCK_OPTS="${WIREMOCK_OPTS} --verbose"
    fi
    # Default command line configuration.
    set -- java ${JAVA_OPTS} -cp /var/wiremock/lib/*:/var/wiremock/extensions/* com.github.tomakehurst.wiremock.standalone.WireMockServerRunner ${WIREMOCK_OPTS} "${@}"
fi

exec "${@}"
