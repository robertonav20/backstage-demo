FROM openjdk:17-alpine

ADD target/${{values.artifactId}}.jar /app/app.jar

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
