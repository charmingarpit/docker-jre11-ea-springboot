# First stage: Runs JLink to create the custom JRE
FROM alpine:3.7 AS builder
 
ENV JAVA_HOME=/opt/jdk \
    PATH=${PATH}:/opt/jdk/bin \
    LANG=C.UTF-8
 
RUN set -ex && \
    apk add --no-cache bash && \
    wget https://download.java.net/java/early_access/alpine/11/binaries/openjdk-11-ea+11_linux-x64-musl_bin.tar.gz -O jdk.tar.gz && \
    mkdir -p /opt/jdk && \
    tar zxvf jdk.tar.gz -C /opt/jdk --strip-components=1 && \
    rm jdk.tar.gz && \
    rm /opt/jdk/lib/src.zip
 
WORKDIR /app
 
RUN jlink --module-path $JAVA_HOME/jmods \
        --verbose \
	--add-modules java.base,java.logging,java.xml,jdk.unsupported,java.sql,java.naming,java.desktop,java.management,java.security.jgss,java.instrument \
	--compress 2 \
	--no-header-files \
	--output /opt/jre-11-minimal

#second stage

FROM alpine:3.7
COPY --from=builder /opt/jre-11-minimal /opt/jre-11-minimal
COPY target/Java10TestSpring-0.0.1-SNAPSHOT.jar /opt/

ENV JAVA_HOME=/opt/jre-11-minimal
ENV PATH="$PATH:$JAVA_HOME/bin"

EXPOSE 8080
CMD java -jar /opt/Java10TestSpring-0.0.1-SNAPSHOT.jar
