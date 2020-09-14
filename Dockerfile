# Container definition
FROM eidolons/openjdk:8.0.265

# Container environment variables
ENV WIREMOCK_HOME="/opt/wiremock" \
    WIREMOCK_VERSION="2.27.0" \
    WIREMOCK_OPTS="--root-dir \"${WIREMOCK_HOME}/data\""

# Update 'openssl' package
# Fix "No Server ALPNProcessors" when using https
# Grab su-exec for easy step-down from root and bash
RUN apk add --update openssl && \
#   apk add --update libc6-compat && \
#   ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2 && \
    apk add --no-cache 'su-exec>=0.2' bash

# Grab wiremock standalone jar
RUN mkdir -p /opt/wiremock/conf && mkdir -p /opt/wiremock/data && mkdir -p /var/wiremock/lib && mkdir -p /var/wiremock/extensions \
  && wget https://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-jre8-standalone/${WIREMOCK_VERSION}/wiremock-jre8-standalone-${WIREMOCK_VERSION}.jar \
    -O /var/wiremock/lib/wiremock-jre8-standalone.jar \
  && chmod 644 /var/wiremock/lib/wiremock-jre8-standalone.jar

# Create a user and group used to launch processes
# The user ID 1000 is the default for the first "regular" user on most of Unix systems, so there is a high chance that this ID will be equal to the current
# user making it easier to use volumes (no permission issues)
RUN addgroup -g 1000 -S wiremock && adduser -u 1000 -D -h /opt/wiremock -s /sbin/nologin -S wiremock -G wiremock && chmod 755 -R /opt/wiremock

# Copy files to container
COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh && \
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
CMD java ${JAVA_OPTS} -cp /var/wiremock/lib/*:/var/wiremock/extensions/* com.github.tomakehurst.wiremock.standalone.WireMockServerRunner ${WIREMOCK_OPTS}
