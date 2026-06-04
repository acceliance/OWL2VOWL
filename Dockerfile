ARG OWL2VOWL_VERSION=0.3.7
ARG MAVEN_IMAGE=3.9.16-eclipse-temurin-8-noble
ARG JRE_IMAGE=8-jre-noble

FROM maven:${MAVEN_IMAGE} AS build

WORKDIR /var/lib/owl2vowl
COPY pom.xml .
RUN mvn -B dependency:go-offline -P war-release

COPY src src
RUN mvn -B package -P war-release -DskipTests

FROM eclipse-temurin:${JRE_IMAGE}

ARG OWL2VOWL_VERSION=0.3.7

LABEL org.opencontainers.image.title="OWL2VOWL" \
      org.opencontainers.image.description="OWL to VOWL JSON converter (Spring Boot WAR)" \
      org.opencontainers.image.version="${OWL2VOWL_VERSION}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r owl2vowl --gid=10001 \
    && useradd -r -g owl2vowl --uid=10001 --home-dir=/owl2vowl owl2vowl \
    && mkdir -p /owl2vowl \
    && chown -R owl2vowl:owl2vowl /owl2vowl

WORKDIR /owl2vowl
COPY --from=build --chown=owl2vowl:owl2vowl /var/lib/owl2vowl/target/owl2vowl.war .

USER owl2vowl

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=3 \
    CMD curl -f http://127.0.0.1:8080/serverTimeStamp || exit 1

CMD ["java", "-jar", "owl2vowl.war"]
