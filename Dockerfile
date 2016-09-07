FROM alpine:3.4

ENV PORT=8080
ENV M2_HOME=/usr/lib/mvn
ENV M2=$M2_HOME/bin
ENV PATH $PATH:$M2_HOME:$M2

WORKDIR /app
COPY . .

RUN apk --update upgrade && \
    # install Maven, JRE, and JDK
    apk add curl openjdk8-jre openjdk8 && \
    curl http://mirrors.sonic.net/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz | tar -zx && \
    mv apache-maven-3.3.9 /usr/lib/mvn && \
    # build the application into a single JAR, including dependencies
    mvn package && \
    rm target/original-*.jar && \
    mv target/*.jar app.jar && \
    # remove all build artifacts & dependencies, Maven, and the JDK
    rm -rf /root/.m2 && \
    rm -rf /usr/lib/mvn && \
    rm -rf target && \
    apk del openjdk8

CMD java -Ddw.server.connector.port=$PORT -jar app.jar server config.yml
