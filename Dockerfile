# stage 1 
FROM gradle:4.7.0-jdk8-alpine AS build
WORKDIR /opt/backend
USER root
COPY --chown=0:0 . .
RUN ./gradlew build -x test 

# stage 2
FROM openjdk:8-jre-alpine AS prod
ENV BUILD_PATH=/opt/backend/build
ENV DB_USERNAME=db_user
ENV DB_PASSWORD=db_password
ENV DB_NAME=realworld
ENV DB_URL=localhost
ENV DB_PORT=3306 
ENV spring.datasource.url=jdbc:mysql://${DB_URL}:${DB_PORT}/${DB_NAME}
ENV spring.datasource.username=${DB_USERNAME}
ENV spring.datasource.password=${DB_PASSWORD}

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
WORKDIR /opt/backend
COPY --chown=0:0 --from=build ${BUILD_PATH}/libs/* ${WORKDIR}
COPY --chown=0:0 --from=build ${BUILD_PATH}/resources/main/application.properties ${WORKDIR}
HEALTHCHECK --interval=5m --timeout=3s \
CMD curl -f http://localhost:8080/tags || exit 1
EXPOSE 8080
CMD ["java", "-Dspring.config.location=./", "-jar", "backend.jar"]
