# Container definition
FROM eidolons/openjdk:8.0.265

# Container environment variables
ENV WIREMOCK_SECURED="false" \
    WIREMOCK_CASTORE="application.castore" \
    WIREMOCK_CASTORE_PASSWORD="password" \
    WIREMOCK_KEYSTORE="application.keystore" \
    WIREMOCK_KEYSTORE_PASSWORD="password" \
    WIREMOCK_TRUSTSTORE="application.truststore" \
    WIREMOCK_TRUSTSTORE_PASSWORD="password" \
    WIREMOCK_RECORD_MAPPINGS="false" \
    WIREMOCK_REQUEST_JOURNAL="true" \
    WIREMOCK_BROWSER_PROXING="false" \
    WIREMOCK_VERBOSE="false"

ARG WIREMOCK_HOME="/opt/wiremock"
ARG WIREMOCK_VERSION="2.27.2"
ARG SLF4J_VERSION="1.7.30"
ARG LOG4J_VERSION="2.13.3"

# Update 'openssl' package
# Grab su-exec for easy step-down from root and bash
RUN apk add --update openssl && \
    apk add --no-cache 'su-exec>=0.2' bash

# Grab wiremock standalone jar
RUN mkdir -p /opt/wiremock/conf && mkdir -p /opt/wiremock/data && mkdir -p /var/wiremock/conf && mkdir -p /var/wiremock/lib && mkdir -p /var/wiremock/extensions \
  && wget https://repo1.maven.org/maven2/org/slf4j/slf4j-api/${SLF4J_VERSION}/slf4j-api-${SLF4J_VERSION}.jar \
    -O /var/wiremock/lib/slf4j-api.jar \
  && chmod 644 /var/wiremock/lib/slf4j-api.jar \
  && wget https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-slf4j-impl/${LOG4J_VERSION}/log4j-slf4j-impl-${LOG4J_VERSION}.jar \
    -O /var/wiremock/lib/log4j-slf4j-impl.jar \
  && chmod 644 /var/wiremock/lib/log4j-slf4j-impl.jar \
  && wget https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/${LOG4J_VERSION}/log4j-api-${LOG4J_VERSION}.jar \
    -O /var/wiremock/lib/log4j-api.jar \
  && chmod 644 /var/wiremock/lib/log4j-api.jar \
  && wget https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/${LOG4J_VERSION}/log4j-core-${LOG4J_VERSION}.jar \
    -O /var/wiremock/lib/log4j-core.jar \
  && chmod 644 /var/wiremock/lib/log4j-core.jar \
  && wget https://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-jre8-standalone/${WIREMOCK_VERSION}/wiremock-jre8-standalone-${WIREMOCK_VERSION}.jar \
    -O /var/wiremock/lib/wiremock-jre8-standalone.jar \
  && chmod 644 /var/wiremock/lib/wiremock-jre8-standalone.jar

# Create a user and group used to launch processes
# The user ID 1000 is the default for the first "regular" user on most of Unix systems, so there is a high chance that this ID will be equal to the current
# user making it easier to use volumes (no permission issues)
RUN addgroup -g 1000 -S wiremock && adduser -u 1000 -D -h /opt/wiremock -s /sbin/nologin -S wiremock -G wiremock && chmod 755 -R /opt/wiremock

# Copy files to container
COPY assets/log4j2.xml /var/wiremock/conf
COPY assets/docker-entrypoint.sh /
RUN chmod 755 "/docker-entrypoint.sh" && \
    chmod 644 "/var/wiremock/conf/log4j2.xml" && \
    chown -R wiremock:wiremock /opt/wiremock

# Set the working directory to wiremock's user home directory
WORKDIR /opt/wiremock

# Specify the user which should be used to execute all commands below
USER wiremock

# Expose volumes and ports
VOLUME /opt/wiremock/conf
VOLUME /opt/wiremock/data
EXPOSE 8080 8443

# Container execution definition
ENTRYPOINT [ "/docker-entrypoint.sh" ]
